USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PrepocetZajisteniVsechMaterialu_pro_VD]    Script Date: 26.06.2025 10:53:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PrepocetZajisteniVsechMaterialu_pro_VD]
AS
--VD = Výkresový dílec = Materiál!!!
--inicializace dočasných tabulek
--1. požadavky k výdeji
BEGIN
if OBJECT_ID(N'tempdb..#Lokalni_Tab_PozadavkyKVydeji') is not NULL
Drop Table #Lokalni_Tab_PozadavkyKVydeji

CREATE table #Lokalni_Tab_PozadavkyKVydeji
(
	loctab_ID int primary key identity(1,1),
  local_IDKmen INT NULL,
  local_ID_PrKV_Plan INT NULL,
  local_ID_Prikaz_Plan INT NULL,
	local_mnozstvi numeric(19,6) NULL,
  local_Datum DateTime NULL,
  local_DatumZajisteni DateTime NULL,
  local_Plan BIT NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_PozadavkyKVydeji(local_IDKmen)
CREATE INDEX IX_local_Datum ON #Lokalni_Tab_PozadavkyKVydeji(local_Datum ASC)
CREATE INDEX IX_local_Plan ON #Lokalni_Tab_PozadavkyKVydeji(local_Plan)
CREATE INDEX IX_local_ID_Prikaz_Plan ON #Lokalni_Tab_PozadavkyKVydeji(local_ID_Prikaz_Plan)

--2. vykrývací tabulka stavem skladu
if OBJECT_ID(N'tempdb..#Lokalni_Tab_StavSkladuKVykryti') is not NULL
Drop Table #Lokalni_Tab_StavSkladuKVykryti

CREATE table #Lokalni_Tab_StavSkladuKVykryti
(
	loctab_ID int primary key identity(1,1),  
  local_IDKmen INT NULL,
	local_mnozstvi numeric(19,6) NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_StavSkladuKVykryti(local_IDKmen)

--3. vykrývací tabulka výrobními příkazy
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_VyrPrikazyKVykryti') IS NOT NULL
Drop Table #Lokalni_Tab_VyrPrikazyKVykryti

CREATE table #Lokalni_Tab_VyrPrikazyKVykryti
(
	loctab_ID int primary key identity(1,1),  
  local_IDKmen INT NULL,
	local_mnozstvi numeric(19,6) NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_VyrPrikazyKVykryti(local_IDKmen)

--4. vykrývací tabulka výrobními plány
IF OBJECT_ID(N'tempdb..#Lokalni_Tab_VyrPlanyKVykryti') IS NOT NULL
Drop Table #Lokalni_Tab_VyrPlanyKVykryti

CREATE table #Lokalni_Tab_VyrPlanyKVykryti
(
	loctab_ID int primary key identity(1,1),  
  local_IDKmen INT NULL,
	local_mnozstvi numeric(19,6) NULL
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_VyrPlanyKVykryti(local_IDKmen)

--5. vykrývací tabulka vydanými objednávkami
if OBJECT_ID(N'tempdb..#Lokalni_Tab_VydaneObj') is not NULL
Drop Table #Lokalni_Tab_VydaneObj

CREATE table #Lokalni_Tab_VydaneObj
(
	loctab_ID int primary key identity(1,1),  
  local_IDKmen INT NULL,
  Local_IDPohybZbo INT NULL,  
	local_mnozstvi numeric(19,6) NULL,
  local_PotvrzDatDod DateTime
)
CREATE INDEX IX_local_IDKmen ON #Lokalni_Tab_VydaneObj(local_IDKmen)
CREATE INDEX IX_local_PotvrzDatDod ON #Lokalni_Tab_VydaneObj(local_PotvrzDatDod ASC)
End

/*
--interní
Declare @poc INT, @IDKmen_P INT
SET @poc=1
*/

--exec hromadná aktualizace rozpadu pro všechny výrobní plány
EXEC hp_VyrPlan_VypocetPlanovaneVyroby @DuvodGenerovani=1

--6. naplnění dočasné tabulky: Požadavky k výdeji
Begin
  Insert INTO #Lokalni_Tab_PozadavkyKVydeji(local_IDKmen, local_ID_PrKV_Plan, local_ID_Prikaz_Plan, local_mnozstvi, local_Plan, local_Datum)
    (Select PrKV.nizsi, PrKV.ID, PrKV.IDPrikaz, PrKv.mnoz_Nevydane, 0, P.Plan_zadani
      From TabPrKVazby PrKV 
      Inner Join TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
	  --LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
      Inner join TabPrikaz P ON P.ID=PrKV.IDPrikaz
      Where PrKv.mnoz_Nevydane>0 AND 
            PrKV.Splneno=0 AND
            PrKV.Prednastaveno=1 AND
            PrKV.IDOdchylkyDo is NULL AND
            --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and 
            KZ.Dilec=1 and--původně bylo --KZ.Material=1
			--SOT.K1= N'VD' AND
            P.StavPrikazu<=40)

  Insert INTO #Lokalni_Tab_PozadavkyKVydeji(local_IDKmen, local_ID_PrKV_Plan, local_ID_Prikaz_Plan, local_mnozstvi, local_Plan, local_Datum)
    (Select PPrKV.nizsi, PPrKV.ID, PPrKV.IDPlanPrikaz, PPrKV.mnoz_zad, 1, PP.Plan_zadani
      From TabPlanPrKVazby PPrKV 
      Inner Join TabKmenZbozi KZ ON KZ.ID=PPrKV.nizsi
      Inner join TabPlanPrikaz PP ON PP.ID=PPrKV.IDPlanPrikaz
	  LEFT OUTER JOIN TabPlan TP ON TP.ID=PPrKV.IDPlan
	  LEFT OUTER JOIN TabRadyPlanu TRP ON trp.Rada=TP.Rada
	  --LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
      Where PPrKV.mnoz_zad>0 and          
            --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and
			PPrKV.RezijniMat=0 AND
			KZ.SkupZbo<>'150' AND
            KZ.Dilec=1 AND TP.StavPrevodu<>N'x' AND TRP.ZahrnoutDoBilancovaniBudPoh=2) --původně bylo KZ.Material=1)
End

--7. naplnění dočasné tabulky: Stav skladů k vykrytí (2.)
--10.11.2021 upraveno MŽ, změna dle množství skladem
--11.11.2021 upraveno MŽ, změna dle množství po příjmu
Begin
  Insert INTO #Lokalni_Tab_StavSkladuKVykryti(local_IDKmen, local_mnozstvi)
    (Select SS.IDKmenZbozi, SUM(SS.MnozSPrij)
      From TabStavSkladu SS
      Where SS.IDSklad IN (N'200',N'100',N'20000280') AND SS.MnozSPrij>0.0
	  GROUP BY SS.IDKmenZbozi )
End

--8. naplnění dočasné tabulky: Výrobní příkazy k vykrytí (3.)
/*
BEGIN
  INSERT INTO #Lokalni_Tab_VyrPrikazyKVykryti(local_IDKmen, local_mnozstvi)
    (SELECT P.IDTabKmen, P.kusy_zad
	FROM TabPrikaz P
	WHERE P.StavPrikazu IN (20,30))
END*/

--9. naplnění dočasné tabulky: Výrobní plány k vykrytí (4.)
/*
BEGIN
  INSERT INTO #Lokalni_Tab_VyrPrikazyKVykryti(local_IDKmen, local_mnozstvi)
    (SELECT P.IDTabKmen, P.mnozNeprev
	FROM TabPlan P
	LEFT OUTER JOIN TabRadyPlanu trp ON trp.Rada=P.Rada
	WHERE P.InterniZaznam=0 AND P.StavPrevodu<>N'x' AND trp.ZahrnoutDoBilancovaniBudPoh=2)
END*/

--10. naplnění dočasné tabulky: Vydané objednávky (5.)
/*
Begin
  Insert INTO #Lokalni_Tab_VydaneObj(local_IDKmen, Local_IDPohybZbo, local_mnozstvi, local_PotvrzDatDod)
    (Select KZ.ID, PZ.ID, ((PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi), PZ.PotvrzDatDod
      From TabPohybyZbozi PZ
      Inner Join TabStavSkladu SS ON SS.ID=PZ.IDZboSklad
      Inner join TabKmenZbozi KZ ON KZ.ID=SS.IDKmenZbozi AND SS.IDSklad=N'100'
      Inner Join TabDokladyZbozi DZ ON DZ.ID=PZ.IDDoklad
      Where DZ.Splneno=0 and
            DZ.DruhPohybuZbo=6 and
            PZ.PotvrzDatDod is not NULL and
            ((PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi)>0.0)
End*/
--upravený nápočet položek k vykrytí
Begin
  Insert INTO #Lokalni_Tab_VydaneObj(local_IDKmen, Local_IDPohybZbo, local_mnozstvi, local_PotvrzDatDod)
    (Select KZ.ID, PZ.ID, ((PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi), PZ.PotvrzDatDod
      From TabPohybyZbozi PZ
      Inner Join TabStavSkladu SS ON SS.ID=PZ.IDZboSklad
      Inner join TabKmenZbozi KZ ON KZ.ID=SS.IDKmenZbozi AND SS.IDSklad=N'100'
      Inner Join TabDokladyZbozi DZ ON DZ.ID=PZ.IDDoklad
      Where DZ.Splneno=0 and
            DZ.DruhPohybuZbo=6 and
            PZ.PotvrzDatDod is not NULL and
            ((PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi)>0.0
		UNION ALL
		SELECT P.IDTabKmen, P.ID, P.kusy_zive, P.Plan_ukonceni
			FROM TabPrikaz P
			WHERE P.StavPrikazu IN (20,30,40)
		UNION ALL
		SELECT P.IDTabKmen, P.ID, P.mnozNeprev, P.datum
			FROM TabPlan P
			LEFT OUTER JOIN TabRadyPlanu trp ON trp.Rada=P.Rada
			WHERE P.InterniZaznam=0 AND P.StavPrevodu<>N'x' AND trp.ZahrnoutDoBilancovaniBudPoh=2)
End

--11.zde se děje plnění data zajištění do řádků

Declare @ID INT, @IDKmen INT, @IDPrKV_Plan INT, @IDPrikaz_Plan INT, @Mnozstvi Numeric(19,6), @JePlan BIT, @DatumZajisteni DateTime, @ID_local INT, @Mnozstvi_local Numeric(19,6)
Declare PomCr CURSOR Fast_forward Local FOR 
  Select loctab_ID, local_IDKmen, local_ID_PrKV_Plan, local_ID_Prikaz_Plan, local_mnozstvi, local_Plan
    From #Lokalni_Tab_PozadavkyKVydeji
    Where local_Datum is not NULL
--původní řádek    Order By local_Plan ASC, local_IDKmen, local_Datum ASC
--nahrazen tímto řádkem:
	Order By local_IDKmen, local_Datum ASC
OPEN PomCr

while 1=1
	begin	
  FETCH NEXT FROM PomCr into @ID, @IDKmen, @IDPrKV_Plan, @IDPrikaz_Plan, @Mnozstvi, @JePlan
	if (@@FETCH_STATUS <> 0) break
	--tělo pro práci s curzorem
  SET @DatumZajisteni=NULL
  if exists(Select *
              From #Lokalni_Tab_StavSkladuKVykryti SS
              Where SS.local_mnozstvi > 0.0 and
                    SS.local_IDKmen=@IDKmen)
    Begin      
      Select @ID_local=SS.loctab_ID, @Mnozstvi_local=SS.local_mnozstvi
        From #Lokalni_Tab_StavSkladuKVykryti SS
        Where SS.local_mnozstvi > 0.0 and
              SS.local_IDKmen=@IDKmen
      If @Mnozstvi_local>=@Mnozstvi
        Begin
          SET @DatumZajisteni=GetDate()
		  Update #Lokalni_Tab_StavSkladuKVykryti Set local_mnozstvi=(@Mnozstvi_local-@Mnozstvi) Where loctab_ID=@ID_local
          Update #Lokalni_Tab_PozadavkyKVydeji Set local_DatumZajisteni=@DatumZajisteni Where loctab_ID=@ID
          SET @Mnozstvi=0.0
        End
      Else
        Begin
          SET @DatumZajisteni=NULL
		  Update #Lokalni_Tab_StavSkladuKVykryti Set local_mnozstvi=0.0 Where loctab_ID=@ID_local
          SET @Mnozstvi=@Mnozstvi-@Mnozstvi_local		  
        End
    End    
  While @Mnozstvi>0.0
    Begin
	  if exists(Select *
                  From #Lokalni_Tab_VydaneObj VO
                  Where local_mnozstvi > 0.0 and
                    local_IDKmen=@IDKmen)
        Begin
          Select TOP 1 @ID_local=VO.loctab_ID, @Mnozstvi_local=VO.local_mnozstvi, @DatumZajisteni=(CASE WHEN VO.local_PotvrzDatDod<GetDate() Then GetDate() Else VO.local_PotvrzDatDod End)
            From #Lokalni_Tab_VydaneObj VO
            Where local_mnozstvi > 0.0 and
                  local_IDKmen=@IDKmen
            Order by local_PotvrzDatDod ASC
          If @Mnozstvi_local>=@Mnozstvi  
            Begin
              Update #Lokalni_Tab_VydaneObj Set local_mnozstvi=@Mnozstvi_local-@Mnozstvi Where loctab_ID=@ID_local
              Update #Lokalni_Tab_PozadavkyKVydeji Set local_DatumZajisteni=@DatumZajisteni Where loctab_ID=@ID              
              SET @Mnozstvi=0.0
            End
          Else
            Begin
              SET @DatumZajisteni=NULL
			  Update #Lokalni_Tab_VydaneObj Set local_mnozstvi=0.0 Where loctab_ID=@ID_local
              SET @Mnozstvi=@Mnozstvi-@Mnozstvi_local
            End
        End
      Else
        Begin
          SET @Mnozstvi=0.0
        End
    End  
  If @JePlan=1
    Begin
      if NOT Exists(Select * from TabPlanPrKVazby_EXT Where ID=@IDPrKV_Plan) Insert INTO TabPlanPrKVazby_EXT(ID,_DatZajMat) Values(@IDPrKV_Plan,@DatumZajisteni)
	  else Update TabPlanPrKVazby_EXT Set _DatZajMat=@DatumZajisteni Where ID=@IDPrKV_Plan
    End
  Else
    Begin
      if NOT Exists(Select * from TabPrKVazby_EXT Where ID=@IDPrKV_Plan) Insert INTO TabPrKVazby_EXT(ID,_DatZajMat) Values(@IDPrKV_Plan,@DatumZajisteni)
	  else Update TabPrKVazby_EXT Set _DatZajMat=@DatumZajisteni Where ID=@IDPrKV_Plan
    End
	end

CLOSE PomCr
DEALLOCATE PomCr

--Samotné nastavení zjištěných zajištění na TabPrikaz a TabPlanPrikaz
Begin
Declare PomCr2 CURSOR Fast_forward Local FOR 
  Select P.ID
	From TabPrikaz P
	Inner Join TabPrKVazby PrKV ON P.ID=PrKV.IDPrikaz
	Inner Join TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
	--LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
    Where PrKv.mnoz_Nevydane>0 AND
          PrKV.Splneno=0 AND
          PrKV.IDOdchylkyDo IS NULL AND
          PrKV.Prednastaveno=1 AND
          --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and 
          KZ.Dilec=1 AND--původně bylo --KZ.Material=1
		  --SOT.K1= N'VD' AND
          P.StavPrikazu<=40
    Group by P.ID
OPEN PomCr2

while 1=1
	begin    
    FETCH NEXT FROM PomCr2 into @IDPrikaz_Plan
	  if (@@FETCH_STATUS <> 0) break
    SET @DatumZajisteni=GETDATE()
    if exists(Select *
          From TabPrikaz P
					Inner Join TabPrKVazby PrKV ON P.ID=PrKV.IDPrikaz
					Inner Join TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
					--LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
					Left Outer Join TabPrKVazby_EXT PrKVE ON PrKV.ID=PrKVE.ID
					Where PrKv.mnoz_Nevydane>0 AND
                PrKV.Splneno=0 AND
                PrKV.IDOdchylkyDo IS NULL AND
                PrKV.Prednastaveno=1 AND
                --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and 
						    KZ.Dilec=1 /*původně bylo KZ.Material=1*/ AND
							--SOT.K1= N'VD' AND
						    P.StavPrikazu<=40 AND                          
						    PrKVE._DatZajMat is NULL AND
						    P.ID=@IDPrikaz_Plan)
      Begin
		SET @DatumZajisteni=NULL
	  End
	else
	  Begin
        Select @DatumZajisteni=MAX(PrKVE._DatZajMat)
          From TabPrikaz P
			Inner Join TabPrKVazby PrKV ON P.ID=PrKV.IDPrikaz
			Inner Join TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
			--LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
			Left Outer Join TabPrKVazby_EXT PrKVE ON PrKV.ID=PrKVE.ID
			Where PrKv.mnoz_Nevydane>0 AND
				    PrKV.Splneno=0 AND
            PrKV.IDOdchylkyDo is NULL AND
            PrKV.Prednastaveno=1 and
            --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and 
--zrušena podmínka na dílec				    --KZ.Dilec=1 /*původně bylo KZ.Material=1*/AND
					--SOT.K1= N'VD' AND
				    P.StavPrikazu<=40 AND                          
				    PrKVE._DatZajMat IS NOT NULL AND
				    P.ID=@IDPrikaz_Plan
      End   
--	  Select @DatumZajisteni=(Case When COUNT(*)=0 Then GETDATE() Else @DatumZajisteni End) From TabPrKVazby P Where P.IDPrikaz=@IDPrikaz_Plan 
	if NOT Exists(Select * from TabPrikaz_EXT Where ID=@IDPrikaz_Plan) Insert INTO TabPrikaz_EXT(ID,_Material) Values(@IDPrikaz_Plan,@DatumZajisteni)
	else Update TabPrikaz_EXT Set _Material=@DatumZajisteni Where ID=@IDPrikaz_Plan 

  end
CLOSE PomCr2
DEALLOCATE PomCr2

Declare PomCr3 CURSOR Fast_forward Local FOR 
  Select P.ID
	From TabPlanPrikaz P
	Inner Join TabPlanPrKVazby PrKV ON P.ID=PrKV.IDPlanPrikaz
	Inner Join TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
	--LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
    Where PrKv.mnoz_zad>0 AND
          --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') AND
		  PrKV.RezijniMat=0 AND
          KZ.Dilec=1-- AND--původně bylo --KZ.Material=1
		  --SOT.K1= N'VD'
    Group by P.ID
OPEN PomCr3

while 1=1
	begin    
    FETCH NEXT FROM PomCr3 into @IDPrikaz_Plan
	  if (@@FETCH_STATUS <> 0) break
    
	SET @DatumZajisteni=GETDATE()
    if exists(Select *
                    From TabPlanPrikaz P
					Inner Join TabPlanPrKVazby PrKV ON P.ID=PrKV.IDPlanPrikaz
					Inner Join TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
					--LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
					Left Outer Join TabPlanPrKVazby_EXT PrKVE ON PrKV.ID=PrKVE.ID
					Where PrKv.mnoz_zad>0 AND
					      --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') AND
						  PrKV.RezijniMat=0 AND
						  KZ.Dilec=1 and--původně bylo --KZ.Material=1
						  --SOT.K1= N'VD' AND
						  PrKVE._DatZajMat IS NULL AND
						  P.ID=@IDPrikaz_Plan )
      Begin
		SET @DatumZajisteni=NULL
	  End
	else
	  Begin
        Select @DatumZajisteni=MAX(PrKVE._DatZajMat)
          From TabPlanPrikaz P
			    Inner Join TabPlanPrKVazby PrKV ON P.ID=PrKV.IDPlanPrikaz
			    Inner Join TabKmenZbozi KZ ON KZ.ID=PrKV.nizsi
				--LEFT OUTER JOIN TabSortiment SOT ON KZ.IdSortiment = SOT.ID
			    Left Outer Join TabPrKVazby_EXT PrKVE ON PrKV.ID=PrKVE.ID
			    Where PrKv.mnoz_zad>0 AND
				        --zrušeno KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and 
--zrušena podmínka na dílec				    --KZ.Dilec=1 AND--původně bylo --KZ.Material=1 
						--SOT.K1= N'VD' AND
						PrKV.RezijniMat=0 AND
				        PrKVE._DatZajMat IS NOT NULL AND
				        P.ID=@IDPrikaz_Plan
      End 

--    Select @DatumZajisteni=(Case When COUNT(*)=0 Then GETDATE() Else @DatumZajisteni End) From TabPlanPrKVazby P Where P.IDPlanPrikaz=@IDPrikaz_Plan 
	if NOT Exists(Select * from TabPlanPrikaz_EXT Where ID=@IDPrikaz_Plan) Insert INTO TabPlanPrikaz_EXT(ID,_Material) Values(@IDPrikaz_Plan,@DatumZajisteni)
	else Update TabPlanPrikaz_EXT Set _Material=@DatumZajisteni Where ID=@IDPrikaz_Plan
  end
CLOSE PomCr3
DEALLOCATE PomCr3
/*
Update TabPlanPrikaz_EXT Set _Material=GETDATE() Where ID in (Select PP.ID From TabPlanPrikaz PP Left Outer Join TabPlanPrKVazby P ON P.IDPlanPrikaz=PP.ID Where P.IDPlanPrikaz is NULL)
Update TabPrikaz_EXT Set _Material=GETDATE() Where ID in (Select PP.ID From TabPrikaz PP Left Outer Join TabPrKVazby P ON P.IDPrikaz=PP.ID Where P.IDPrikaz is NULL)
Update TabPrikaz_EXT Set _Material=GETDATE() Where 
	ID in (Select PP.ID From TabPrikaz PP Left Outer Join TabPrKVazby P ON P.IDPrikaz=PP.ID Where P.mnoz_Nevydane=0.0 AND PP.StavPrikazu<=40 )AND
	ID NOT in (Select PP.ID 
				From TabPrikaz PP 
				Left Outer Join TabPrKVazby P ON P.IDPrikaz=PP.ID 
				Left Outer Join TabKmenZbozi KZ ON KZ.ID=P.nizsi 
				Where P.mnoz_Nevydane>0.0 AND 
					  KZ.Material=1 AND
					  KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') AND
					  PP.StavPrikazu<=40)
*/
End

----smazání dočasných tabulek
if OBJECT_ID(N'tempdb..#Lokalni_Tab_PozadavkyKVydeji') is not NULL
drop table #Lokalni_Tab_PozadavkyKVydeji
if OBJECT_ID(N'tempdb..#Lokalni_Tab_StavSkladuKVykryti') is not NULL
drop table #Lokalni_Tab_StavSkladuKVykryti
if OBJECT_ID(N'tempdb..#Lokalni_Tab_VydaneObj') is not NULL
drop table #Lokalni_Tab_VydaneObj

/*

Select _Material From TabPrikaz_EXT Where _Material is not NULL

Select _DatZajMat From TabPrKVazby_EXT Where _DatZajMat is not NULL

Select _Material From TabPlanPrikaz_EXT Where _Material is not NULL

Select _DatZajMat From TabPlanPrKVazby_EXT Where _DatZajMat is not NULL

exec GEP_PrepocetZajisteniVsechMaterialu_RayService_ZK_new

*/
GO

