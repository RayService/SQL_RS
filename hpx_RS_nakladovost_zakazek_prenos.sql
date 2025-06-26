USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_nakladovost_zakazek_prenos]    Script Date: 26.06.2025 13:03:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_nakladovost_zakazek_prenos] @CisloTarifu NVARCHAR(8), /*@Prepsat BIT, */@IDZak INT
AS

--procedura pro vkládání z Tabx_RS_kalkulace a položek EP přes zakázky do TabZakKalPlanH a TabZakKalPlanR
--MŽ, 11.4.2022, přidáno vkládání nových 4 řádků, kvůli rozšíření kalkulačního vzorce.
--toto se pak automatem bude dostávat do Tabx_RS_NakladyZakazky
/*
MŽ, 3.6.2022, přidáno vkládání dalších řádků
8 - Odbytová režie = řádek 5 * 0,127
9 - Správní režie =  řádek 5 * 0,132
10 - ZISK VÝROBKU =  (řádek 5 + řádek 8 + řádek 9)*0,1765
11 - % ZISKU = řádek 10/(řádek 5 + řádek 8 + řádek 9) 
6 - TRŽBA za vlastní výrobky + služby =  řádek 5 + řádek 8 + řádek 9 + řádek 10
7 - MARŽE VÝROBKU = řádek 6 – řádek 5
*/
DECLARE @CisloZakazky NVARCHAR(15);
DECLARE @IDPol INT;
DECLARE @MnoPol NUMERIC(19,6);
DECLARE @Radek1 NUMERIC(19,6);
DECLARE @Radek2 NUMERIC(19,6);
DECLARE @Radek3 NUMERIC(19,6);
DECLARE @Radek5 NUMERIC(19,6);
DECLARE @Radek6 NUMERIC(19,6);
DECLARE @Radek7 NUMERIC(19,6);
DECLARE @Radek8 NUMERIC(19,6);
DECLARE @Radek9 NUMERIC(19,6);
DECLARE @Radek10 NUMERIC(19,6);
DECLARE @Radek30 NUMERIC(19,6);
DECLARE @Radek11 NUMERIC(19,6);
DECLARE @Radek1Puv NUMERIC(19,6);
DECLARE @Radek2Puv NUMERIC(19,6);
DECLARE @Radek3Puv NUMERIC(19,6);
DECLARE @Radek5Puv NUMERIC(19,6);
DECLARE @Radek6Puv NUMERIC(19,6);
DECLARE @Radek7Puv NUMERIC(19,6);
DECLARE @Radek8Puv NUMERIC(19,6);
DECLARE @Radek9Puv NUMERIC(19,6);
DECLARE @Radek10Puv NUMERIC(19,6);
DECLARE @Radek30Puv NUMERIC(19,6);
DECLARE @Radek11Puv NUMERIC(19,6);
DECLARE @Tarif NUMERIC(19,6);
DECLARE @IDHlava INT;
DECLARE @DatPorizeniZak DATETIME;

SET @Tarif=(SELECT (CONVERT(NUMERIC(19,6),(tarp.koef * CASE tarp.koef_ZT WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)))
			FROM TabTarH tarh
			LEFT OUTER JOIN TabTarP tarp ON tarp.IDTarif=tarh.ID AND EXISTS(SELECT * FROM TabCZmeny Zod
			LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=tarp.zmenaDo)
			WHERE Zod.ID=tarp.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (tarp.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
			WHERE tarh.Tarif=@CisloTarifu
			)

--zjistím číslo zakázky
SET @CisloZakazky=(SELECT tz.CisloZakazky FROM TabZakazka tz WITH(NOLOCK) WHERE tz.ID=@IDZak)
SET @DatPorizeniZak=(SELECT tz.DatPorizeni FROM TabZakazka tz WITH(NOLOCK) WHERE tz.ID=@IDZak)
--SELECT @CisloZakazky,@CisloTarifu,@Tarif

--vymažeme původní výpočet
BEGIN
DELETE TabZakKalPlanR FROM TabZakKalPlanR JOIN TabZakKalPlanH ON (TabZakKalPlanR.IDHlava=TabZakKalPlanH.ID)
WHERE (TabZakKalPlanH.IDZak=@IDZak)/* AND (TabZakKalPlanR.CisloR>17)*/
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END

--tady začneme kurzorem pro položky pro označenou zakázku
DECLARE CurZak CURSOR FAST_FORWARD LOCAL FOR

SELECT tkz.ID,SUM(tpz.Mnozstvi)
FROM TabPohybyZbozi tpz WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WITH(NOLOCK) WHERE tss.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad
--nevím, proč to tu bylo: LEFT OUTER JOIN Tabx_RS_ZKalkulace tzcal WITH(NOLOCK) ON tzcal.Dilec=tkz.ID
WHERE(tkz.Dilec=1)
AND(tdz.DruhPohybuZbo=9)
AND(tdz.CisloZakazky=@CisloZakazky/*'20212777'*/)
GROUP BY tkz.ID
ORDER BY tkz.ID
;

OPEN CurZak
FETCH NEXT FROM CurZak INTO @IDPol,@MnoPol
WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
BEGIN
--SELECT @IDPol

SET @Radek1=(SELECT ISNULL(rsk.mat,0)+ISNULL(rsk.koop,0)+ISNULL(rsk.OPN,0) FROM Tabx_RS_ZKalkulace rsk WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)*@MnoPol
SET @Radek2=(SELECT ((ISNULL(rsk.TAC,0))/CASE rsk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END
					+(ISNULL(rsk.TBC,0))/CASE rsk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END
					+(ISNULL(rsk.TEC,0))/CASE rsk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)
					*@Tarif
			FROM Tabx_RS_ZKalkulace rsk WHERE rsk.Dilec=@IDPol AND rsk.CisloZakazky=@CisloZakazky)*@MnoPol
--pokud jsou náklady nulové (není zkalkulováno)
IF ISNULL(@Radek1,0)=0 AND @DatPorizeniZak>='20220101'
SET @Radek1=ISNULL((SELECT ISNULL(tzk.mat,0)+ISNULL(tzk.koop,0)+ISNULL(tzk.OPN,0) FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)*@MnoPol,0)
IF ISNULL(@Radek2,0)=0 AND @DatPorizeniZak>='20220101'
SET @Radek2=ISNULL((SELECT ((ISNULL(tzk.TAC_KC,0))+(ISNULL(tzk.TBC_KC,0))+(ISNULL(tzk.TEC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaDo IS NULL)*@MnoPol,0)
IF ISNULL(@Radek1,0)=0 AND @DatPorizeniZak<'20220101'
SET @Radek1=ISNULL((SELECT ISNULL(tzk.mat,0)+ISNULL(tzk.koop,0)+ISNULL(tzk.OPN,0) FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaOd=62454)*@MnoPol,0)
IF ISNULL(@Radek2,0)=0 AND @DatPorizeniZak<'20220101'
SET @Radek2=ISNULL((SELECT ((ISNULL(tzk.TAC_KC,0))+(ISNULL(tzk.TBC_KC,0))+(ISNULL(tzk.TEC_KC,0)))
			FROM TabZKalkulace tzk WHERE tzk.Dilec=@IDPol AND tzk.ZmenaOd=62454)*@MnoPol,0)

SET @Radek3=4*@Radek2
SET @Radek5=@Radek1+@Radek2+@Radek3
--SELECT @Radek1,@Radek2,@Radek3,@Radek5
SET @Radek8=@Radek5*0.127
SET @Radek9=@Radek5*0.132
SET @Radek10=ISNULL((@Radek5+@Radek8+@Radek9)*0.1765,0)
--odsouvám až na konec SET @Radek11=ISNULL(@Radek10/NULLIF((@Radek5+@Radek8+@Radek9),0),0)
SET @Radek6=@Radek5+@Radek8+@Radek9+@Radek10
SET @Radek7=@Radek6-@Radek5

--IF @Prepsat=0	--toto by mělo řešit situaci, kdy se čísla z řádků kalkulace prostě přičítají (nebo vkládají) do plánů v zakázce
SET @IDHlava=(SELECT ID FROM TabZakKalPlanH
WHERE (IDZak=@IDZak)
AND (TypPlanu=0))
IF @IDHlava IS NULL
BEGIN
INSERT INTO TabZakKalPlanH(IDZak,TypPlanu,Mesic,Rok,Poznamka) VALUES (@IDZak,0,0,0,'')
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
SET @IDHlava = SCOPE_IDENTITY()
END
--vložení hodnoty do řádku 1
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=1))
BEGIN
SET @Radek1Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=1))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek1+@Radek1Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=1)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,1,CONVERT(NVARCHAR(255),ISNULL(@Radek1,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 2
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=2))
BEGIN
SET @Radek2Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=2))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek2+@Radek2Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=2)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,2,CONVERT(NVARCHAR(255),ISNULL(@Radek2,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 3
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=3))
BEGIN
SET @Radek3Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=3))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek3+@Radek3Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=3)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,3,CONVERT(NVARCHAR(255),ISNULL(@Radek3,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 5
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=5))
BEGIN
SET @Radek5Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=5))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek5+@Radek5Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=5)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,5,CONVERT(NVARCHAR(255),ISNULL(@Radek5,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--END
--nově přidané řádky kvůli rozšíření definice vzorce
--vložení hodnoty do řádku 20
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=20))
BEGIN
SET @Radek1Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=20))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek1+@Radek1Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=20)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,20,CONVERT(NVARCHAR(255),ISNULL(@Radek1,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 21
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=21))
BEGIN
SET @Radek2Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=21))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek2+@Radek2Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=21)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,21,CONVERT(NVARCHAR(255),ISNULL(@Radek2,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 22
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=22))
BEGIN
SET @Radek3Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=22))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek3+@Radek3Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=22)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,22,CONVERT(NVARCHAR(255),ISNULL(@Radek3,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 24
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=24))
BEGIN
SET @Radek5Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=24))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek5+@Radek5Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=24)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,24,CONVERT(NVARCHAR(255),ISNULL(@Radek5,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END

--nově přidané další řádky
--vložení hodnoty do řádku 6
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=6))
BEGIN
SET @Radek6Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=6))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek6+@Radek6Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=6)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,6,CONVERT(NVARCHAR(255),ISNULL(@Radek6,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 7
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=7))
BEGIN
SET @Radek7Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=7))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek7+@Radek7Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=7)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,7,CONVERT(NVARCHAR(255),ISNULL(@Radek7,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 8
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=8))
BEGIN
SET @Radek8Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=8))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek8+@Radek8Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=8)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,8,CONVERT(NVARCHAR(255),ISNULL(@Radek8,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 9
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=9))
BEGIN
SET @Radek9Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=9))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek9+@Radek9Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=9)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,9,CONVERT(NVARCHAR(255),ISNULL(@Radek9,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
--vložení hodnoty do řádku 10
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=10))
BEGIN
SET @Radek10Puv=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=10))
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek10+@Radek10Puv),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=10)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,10,CONVERT(NVARCHAR(255),ISNULL(@Radek10,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END

FETCH NEXT FROM CurZak INTO @IDPol,@MnoPol
END;
CLOSE CurZak;
DEALLOCATE CurZak; 

--nakonec vložení hodnoty do řádku 11
--pro jistotu zjištění IDHlava
SET @IDHlava=(SELECT ID FROM TabZakKalPlanH
WHERE (IDZak=@IDZak)
AND (TypPlanu=0))
IF @IDHlava IS NULL
BEGIN
INSERT INTO TabZakKalPlanH(IDZak,TypPlanu,Mesic,Rok,Poznamka) VALUES (@IDZak,0,0,0,'')
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
SET @IDHlava = SCOPE_IDENTITY()
END

DECLARE @Radek6New NUMERIC(19,6);
DECLARE @Radek10New NUMERIC(19,6);
SET @Radek6New=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=6))
SET @Radek10New=(SELECT ISNULL(TRY_CONVERT(NUMERIC(19,6),VzorecPlan),0) FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=10))
SET @Radek11=ISNULL((@Radek10New/NULLIF((@Radek6New),0)*100),0)
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=11))
BEGIN
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek11),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=11)
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,11,CONVERT(NVARCHAR(255),ISNULL(@Radek11,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END

--nakonec ještě vložení řádku 10 do řádku 30
SET @Radek30=@Radek10New
IF EXISTS(SELECT * FROM TabZakKalPlanR WHERE (IDHlava=@IDHlava) AND (CisloR=30))
BEGIN
UPDATE TabZakKalPlanR SET VzorecPlan=CONVERT(NVARCHAR(255),ISNULL((@Radek30),0))
WHERE (IDHlava=@IDHlava) AND (CisloR=30)
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END
ELSE
BEGIN
INSERT INTO TabZakKalPlanR (IDHlava,CisloR,VzorecPlan) VALUES (@IDHlava,30,CONVERT(NVARCHAR(255),ISNULL(@Radek30,0)))
IF @@ERROR <> 0 GOTO CHYBAROLLBACK
END


GOTO KONEC
CHYBAROLLBACK:
ROLLBACK
KONEC:
GO

