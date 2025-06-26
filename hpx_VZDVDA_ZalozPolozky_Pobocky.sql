USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_VZDVDA_ZalozPolozky_Pobocky]    Script Date: 26.06.2025 8:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpVyuctovaniZalDane.Vyuctovani*/CREATE PROC [dbo].[hpx_VZDVDA_ZalozPolozky_Pobocky]
   @ID INT
  ,@KodPobocky NVARCHAR(5)
AS

DECLARE @Rok INT, @IdVZDVDA INT
SET @IdVZDVDA=@ID
SET @Rok=(SELECT rok FROM dbo.Tabx_VZDVDA WHERE ID=@ID)

-- část I a II
	IF OBJECT_ID(N'tempdb..#VyuctovaniDaneMesPobocky') IS NOT NULL
		DROP TABLE #VyuctovaniDaneMesPobocky
	SELECT Mesic AS Mesic,
		CAST(NULL AS DATETIME) AS Sloupec_01,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_02,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_03,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_04,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_05,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_05A,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_05B,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_06,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_07,
		CAST(0 AS NUMERIC(19,2)) AS Sloupec_08,
		CAST(NULL AS DATETIME) AS Sloupec_09_Dny,
		CAST(0 AS NUMERIC(19,2))AS Sloupec_09_Castka
	INTO #VyuctovaniDaneMesPobocky
	FROM TabMzdObd
	WHERE Rok=@Rok
	ORDER BY Mesic ASC

	EXEC dbo.hpx_MzVyuctovaniDaneZPrijmuFO_Pobocky @Rok, 0, @KodPobocky

	INSERT Tabx_VZDMesVypocet(IdVZDVDA, mesic, kc_dpzi01_vyp, kc_dpzi02_vyp, kc_dpzi04_vyp, kc_dpzi05_vyp, kc_dpzi06_vyp, kc_dpzi07_vyp, kc_dpzi11_vyp)
	SELECT
		@IdVZDVDA, Mesic, Sloupec_02, Sloupec_03, Sloupec_05, Sloupec_05A, 0/*Sloupec_06*/, 0/*Sloupec_04*/, Sloupec_09_Castka
	FROM #VyuctovaniDaneMesPobocky
	WHERE Mesic<13
	ORDER BY Mesic ASC

	IF OBJECT_ID(N'tempdb..#VyuctovaniDaneMesPobocky') IS NOT NULL
		DROP TABLE #VyuctovaniDaneMesPobocky

-- VyuctovaniDaneZPrijmuFO_06
	DECLARE @UhrnPreplatkuDane_06 NUMERIC(19,2), @UhrnNedoplatkuDB_06A NUMERIC(19,2)
	DECLARE @Leden_Mesic_06 TINYINT, @Unor_Mesic_06 TINYINT, @Brezen_Mesic_06 TINYINT
	DECLARE @Leden_Castka_06 NUMERIC(19,2), @Unor_Castka_06 NUMERIC(19,2), @Brezen_Castka_06 NUMERIC(19,2)
	DECLARE @DanBonusRozdil NUMERIC(19,2)

	SELECT @UhrnPreplatkuDane_06=SUM(Preplatek-(CASE WHEN DanBonusRozdil>0 THEN DanBonusRozdil ELSE 0 END))
	FROM TabZamDan rzd
	WHERE rzd.Rok=@Rok-1 AND rzd.Preplatek>0 AND EXISTS(
							SELECT *
							FROM TabMzSloz m
							LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
							WHERE (m.CisloMS=97) AND (m.ZamestnanecId=rzd.ZamestnanecId)
								AND	(m.IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1))
								AND (Mzd.Pobocka=@KodPobocky)  -- zaměstananci dané pobočky a povoleno v konstantách

							)

	SELECT @UhrnNedoplatkuDB_06A=SUM(DanBonusRozdil)
	FROM TabZamDan rzd
	WHERE rzd.Rok=@Rok-1 AND rzd.DanBonusRozdil>0 AND
		rzd.Preplatek>0 AND EXISTS(
					SELECT *
					FROM TabMzSloz m
					LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
					WHERE (m.CisloMS=97) AND (m.ZamestnanecId=rzd.ZamestnanecId)
						AND	(m.IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1))
						AND (Mzd.Pobocka=@KodPobocky)  -- zaměstananci dané pobočky a povoleno v konstantách
					)

	SET @Leden_Mesic_06=NULL
	SET @Unor_Mesic_06=NULL
	SET @Brezen_Mesic_06=NULL
	SET @Leden_Castka_06=0
	SET @Unor_Castka_06=0
	SET @Brezen_Castka_06=0

	SELECT @Leden_Castka_06=-SUM(m.Koruny)
	FROM TabMzSloz m
	LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
	WHERE (m.CisloMS=97) AND (m.IdObdobi=(SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND Mesic=1 AND MKo.OdvodyNaPobocky=1))
		AND (Mzd.Pobocka=@KodPobocky)  -- zaměstananci dané pobočky a povoleno v konstantách
	IF @Leden_Castka_06<>0
		SET @Leden_Mesic_06=1
	ELSE
		SET @Leden_Castka_06=NULL

	SELECT @Unor_Castka_06=-SUM(m.Koruny)
	FROM TabMzSloz m
	LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
	WHERE (m.CisloMS=97) AND (m.IdObdobi=(SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND Mesic=2 AND MKo.OdvodyNaPobocky=1))
		AND (Mzd.Pobocka=@KodPobocky)  -- zaměstananci dané pobočky a povoleno v konstantách
	IF @Unor_Castka_06<>0
		SET @Unor_Mesic_06=2
	ELSE
		SET @Unor_Castka_06=NULL

	SELECT @Brezen_Castka_06=-SUM(m.Koruny)
	FROM TabMzSloz m
	LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
	WHERE (m.CisloMS=97) AND (m.IdObdobi=(SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND Mesic=3 AND MKo.OdvodyNaPobocky=1))
		AND (Mzd.Pobocka=@KodPobocky)  -- zaměstananci dané pobočky a povoleno v konstantách
	IF @Brezen_Castka_06<>0
		SET @Brezen_Mesic_06=3
	ELSE
		SET @Brezen_Castka_06=NULL

	SELECT @DanBonusRozdil=SUM(DanBonusRozdil)
	FROM TabZamDan rzd
	WHERE rzd.Rok=@Rok-1 AND rzd.Preplatek>0 AND DanBonusRozdil>0 AND EXISTS(
									SELECT *
									FROM TabMzSloz m
									LEFT JOIN TabZamMzd Mzd ON m.IdObdobi=Mzd.IdObdobi AND m.ZamestnanecId=Mzd.ZamestnanecId
									WHERE (m.CisloMS=97) AND (m.ZamestnanecId=rzd.ZamestnanecId)
										AND	(m.IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1))
										AND (Mzd.Pobocka=@KodPobocky)  -- zaměstananci dané pobočky a povoleno v konstantách
									)
	SET @DanBonusRozdil=ISNULL(@DanBonusRozdil,0)

	IF @Rok>=2010
	BEGIN
		IF @Leden_Castka_06 > 0
			SET @Leden_Castka_06 = @Leden_Castka_06 - @DanBonusRozdil
		ELSE
			IF @Unor_Castka_06 > 0
				SET @Unor_Castka_06 = @Unor_Castka_06 - @DanBonusRozdil
			ELSE
				IF @Brezen_Castka_06 > 0
					SET @Brezen_Castka_06 = @Brezen_Castka_06 - @DanBonusRozdil
	END

	UPDATE Tabx_VZDVDA
		SET uhrndopl = ISNULL(@UhrnNedoplatkuDB_06A, 0),
			uhrnprepl = ISNULL(@UhrnPreplatkuDane_06, 0)
	WHERE ID=@IdVZDVDA

	INSERT Tabx_VZDPrehledPlateb(IdVZDVDA, mesic_06, uhrnprepl_c)
		VALUES(@IdVZDVDA, 2, ISNULL(@Leden_Castka_06, 0))
	INSERT Tabx_VZDPrehledPlateb(IdVZDVDA, mesic_06, uhrnprepl_c)
		VALUES(@IdVZDVDA, 3, ISNULL(@Unor_Castka_06, 0))
	INSERT Tabx_VZDPrehledPlateb(IdVZDVDA, mesic_06, uhrnprepl_c)
		VALUES(@IdVZDVDA, 4, ISNULL(@Brezen_Castka_06, 0))


	DECLARE @IdObdobi_12 INT, @ZamestnanecId INT
/* SouhrnneUdajeCizinci do roku 2016 */
     IF @Rok < 2016
     BEGIN
	  SELECT @IdObdobi_12=IdObdobi FROM TabMzdObd WHERE Rok=@Rok AND Mesic=12
	  IF @IdObdobi_12 IS NULL
		  RETURN

	  IF OBJECT_ID(N'tempdb..#SouhrnneUdajeCizinciPlg') IS NOT NULL
		  DROP TABLE #SouhrnneUdajeCizinciPlg
	  SELECT
		  c.ID AS ZamId,
		  c.AdrTrvZeme AS KodStatu_01,
		  c.Prijmeni AS Prijmeni_02,
		  c.Jmeno AS Jmeno_03,
		  c.AdrTrvMisto AS Obec_04,
		  c.AdrTrvUlice AS Ulice_05,
		  CASE
			  WHEN c.AdrTrvPopCislo='' AND c.AdrTrvOrCislo<>'' THEN c.AdrTrvOrCislo
			  WHEN c.AdrTrvPopCislo<>'' AND c.AdrTrvOrCislo='' THEN c.AdrTrvPopCislo
			  WHEN c.AdrTrvPopCislo<>'' AND c.AdrTrvOrCislo<>'' THEN c.AdrTrvPopCislo + N'/' + c.AdrTrvOrCislo
			  ELSE ''
		  END AS Cislo_06,
		  c.AdrTrvPSC AS PSC_07,
		  c.DatumNarozeni AS DatumNarozeni_08,
		  CAST('' AS NVARCHAR(30)) AS DIC_09,
		  c.RodneCislo AS RodneCislo_10,
		  c.CisloPasu AS CisloPasu_11,
		  CAST(0 AS NUMERIC(19,2)) AS UhrnPrijmu_12,
		  CAST(0 AS BIT) AS Mesice_13_1,
		  CAST(0 AS BIT) AS Mesice_13_2,
		  CAST(0 AS BIT) AS Mesice_13_3,
		  CAST(0 AS BIT) AS Mesice_13_4,
		  CAST(0 AS BIT) AS Mesice_13_5,
		  CAST(0 AS BIT) AS Mesice_13_6,
		  CAST(0 AS BIT) AS Mesice_13_7,
		  CAST(0 AS BIT) AS Mesice_13_8,
		  CAST(0 AS BIT) AS Mesice_13_9,
		  CAST(0 AS BIT) AS Mesice_13_10,
		  CAST(0 AS BIT) AS Mesice_13_11,
		  CAST(0 AS BIT) AS Mesice_13_12,
		  CAST(0 AS NUMERIC(19,2)) AS Pojistne_14,
		  CAST(0 AS NUMERIC(19,2)) AS ZakladDane_15,
		  CAST(0 AS NUMERIC(19,2)) AS DanPoSlevach_16
	  INTO #SouhrnneUdajeCizinciPlg
	  FROM TabCisZam c
	  JOIN TabZamMzd m ON m.ZamestnanecId=c.ID AND m.IdObdobi=@IdObdobi_12
	  WHERE (c.AdrTrvZeme IS NOT NULL)
		  AND (c.AdrTrvZeme<>(SELECT ISOKod FROM TabZeme WHERE Vlastni=1))
		  AND EXISTS(
				  SELECT *
				  FROM TabZamVyp v
				  WHERE v.ZamestnanecId=c.ID AND IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1))
		  AND (m.Pobocka=@KodPobocky)
	  ORDER BY c.AdrTrvZeme ASC, c.Prijmeni ASC, c.Jmeno ASC

	  DECLARE @UhrnPrijmu_12 NUMERIC(19,2), @Pojistne_14 NUMERIC(19,2)
	  DECLARE @Mesice_13_1 BIT, @Mesice_13_2 BIT, @Mesice_13_3 BIT, @Mesice_13_4 BIT, @Mesice_13_5 BIT,
		  @Mesice_13_6 BIT, @Mesice_13_7 BIT, @Mesice_13_8 BIT, @Mesice_13_9 BIT, @Mesice_13_10 BIT, @Mesice_13_11 BIT, @Mesice_13_12 BIT
	  DECLARE @ZakladDane_15 NUMERIC(19,2), @DanPoSlevach_16 NUMERIC(19,2), @MesicZam TINYINT
	  DECLARE c CURSOR LOCAL FOR SELECT ZamId FROM #SouhrnneUdajeCizinciPlg
	  OPEN c
	  WHILE 1=1
	  BEGIN
		  FETCH NEXT FROM c INTO @ZamestnanecId
		  IF @@FETCH_STATUS<>0 BREAK
		  SET @UhrnPrijmu_12=0
		  SET @Pojistne_14=0
		  SET @ZakladDane_15=0
		  SET @DanPoSlevach_16=0
		  SET @Mesice_13_1=0 SET @Mesice_13_2=0 SET @Mesice_13_3=0 SET @Mesice_13_4=0
		  SET @Mesice_13_5=0 SET @Mesice_13_6=0 SET @Mesice_13_7=0 SET @Mesice_13_8=0
		  SET @Mesice_13_9=0 SET @Mesice_13_10=0 SET @Mesice_13_11=0 SET @Mesice_13_12=0
		  SELECT
			  @UhrnPrijmu_12=SUM(UhrnPrijmuZavCin),
			  @Pojistne_14=SUM(SocPojZam+ZdrPojZam),
			  @ZakladDane_15=SUM(ZdanitelnaMzda),
			  @DanPoSlevach_16=SUM(DanPoSleve)
		  FROM TabMzdList
		  WHERE ZamestnanecId=@ZamestnanecId AND IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1)

		  DECLARE cMesice CURSOR LOCAL FOR
						  SELECT
							  o.Mesic
						  FROM TabZamVyp v
						  JOIN TabMzdObd o ON v.IdObdobi=o.IdObdobi
						  LEFT JOIN TabMzKons MKo ON o.IdObdobi=MKo.IdObdobi
						  WHERE ZamestnanecId=@ZamestnanecId AND o.Rok=@Rok
							  AND MKo.OdvodyNaPobocky=1
						  ORDER BY o.Mesic ASC
		  OPEN cMesice
		  WHILE 1=1
		  BEGIN
			  FETCH NEXT FROM cMesice INTO @MesicZam
			  IF @@FETCH_STATUS<>0 BREAK
			  IF @MesicZam=1
				  SET @Mesice_13_1=1
			  IF @MesicZam=2
				  SET @Mesice_13_2=1
			  IF @MesicZam=3
				  SET @Mesice_13_3=1
			  IF @MesicZam=4
				  SET @Mesice_13_4=1
			  IF @MesicZam=5
				  SET @Mesice_13_5=1
			  IF @MesicZam=6
				  SET @Mesice_13_6=1
			  IF @MesicZam=7
				  SET @Mesice_13_7=1
			  IF @MesicZam=8
				  SET @Mesice_13_8=1
			  IF @MesicZam=9
				  SET @Mesice_13_9=1
			  IF @MesicZam=10
				  SET @Mesice_13_10=1
			  IF @MesicZam=11
				  SET @Mesice_13_11=1
			  IF @MesicZam=12
				  SET @Mesice_13_12=1
		  END
		  CLOSE cMesice
		  DEALLOCATE cMesice

		  UPDATE #SouhrnneUdajeCizinciPlg
			  SET UhrnPrijmu_12=@UhrnPrijmu_12,
				  Pojistne_14=@Pojistne_14,
				  ZakladDane_15=@ZakladDane_15,
				  DanPoSlevach_16=@DanPoSlevach_16,
				  Mesice_13_1=@Mesice_13_1,
				  Mesice_13_2=@Mesice_13_2,
				  Mesice_13_3=@Mesice_13_3,
				  Mesice_13_4=@Mesice_13_4,
				  Mesice_13_5=@Mesice_13_5,
				  Mesice_13_6=@Mesice_13_6,
				  Mesice_13_7=@Mesice_13_7,
				  Mesice_13_8=@Mesice_13_8,
				  Mesice_13_9=@Mesice_13_9,
				  Mesice_13_10=@Mesice_13_10,
				  Mesice_13_11=@Mesice_13_11,
				  Mesice_13_12=@Mesice_13_12
		  WHERE ZamId=@ZamestnanecId
	  END
	  CLOSE c
	  DEALLOCATE c

	  INSERT dbo.Tabx_VZDSUCizinci(IdVZDVDA, m_k_stat, m_prijmeni, m_jmeno, m_naz_obce, m_ulice, m_c_pop_or, m_psc, m_d_naroz, m_dic,
		  m_rod_c, m_c_pasu, m_kc_prijmy, m_mes_zuct1, m_mes_zuct2, m_mes_zuct3, m_mes_zuct4, m_mes_zuct5, m_mes_zuct6, m_mes_zuct7,
		  m_mes_zuct8, m_mes_zuct9, m_mes_zuct10, m_mes_zuct11, m_mes_zuct12, m_kc_pojistne, m_kc_zakldane, m_kc_zalohy
		  )
	  SELECT
		  @IdVZDVDA,
		  LEFT(KodStatu_01, 2) AS KodStatu_01,
		  LEFT(Prijmeni_02, 36) AS Prijmeni_02,
		  LEFT(Jmeno_03, 20) AS Jmeno_03,
		  LEFT(Obec_04, 48) AS Obec_04,
		  LEFT(Ulice_05, 38) AS Ulice_05,
		  LEFT(Cislo_06, 10) AS Cislo_06,
		  LEFT(PSC_07, 10) AS PSC_07,
		  DatumNarozeni_08,
		  LEFT(DIC_09, 20) AS DIC_09,
		  LEFT(RodneCislo_10, 20) AS RodneCislo_10,
		  LEFT(CisloPasu_11, 16) AS CisloPasu_11,
		  UhrnPrijmu_12,
		  Mesice_13_1, Mesice_13_2, Mesice_13_3, Mesice_13_4, Mesice_13_5, Mesice_13_6, Mesice_13_7, Mesice_13_8, Mesice_13_9, Mesice_13_10, Mesice_13_11, Mesice_13_12,
		  Pojistne_14,
		  ZakladDane_15,
		  DanPoSlevach_16
	  FROM #SouhrnneUdajeCizinciPlg

	  IF OBJECT_ID(N'tempdb..#SouhrnneUdajeCizinciPlg') IS NOT NULL
		  DROP TABLE #SouhrnneUdajeCizinciPlg
     END
/* SouhrnneUdajeCizinci od roku 2016*/
     ELSE 
     BEGIN
	  SELECT @IdObdobi_12=IdObdobi FROM TabMzdObd WHERE Rok=@Rok AND Mesic=12
	  IF @IdObdobi_12 IS NULL
		  RETURN

	  IF OBJECT_ID(N'tempdb..#SouhrnneUdajeCizinci2016Plg') IS NOT NULL
		  DROP TABLE #SouhrnneUdajeCizinci2016Plg
	  SELECT
		  c.ID AS ZamId,
		  c.AdrTrvZeme AS KodStatu_01,
		  c.Prijmeni AS Prijmeni_02,
		  c.Jmeno AS Jmeno_03,
		  c.AdrTrvMisto AS Obec_04,
		  c.AdrTrvUlice AS Ulice_05,
		  CASE
			  WHEN c.AdrTrvPopCislo='' AND c.AdrTrvOrCislo<>'' THEN c.AdrTrvOrCislo
			  WHEN c.AdrTrvPopCislo<>'' AND c.AdrTrvOrCislo='' THEN c.AdrTrvPopCislo
			  WHEN c.AdrTrvPopCislo<>'' AND c.AdrTrvOrCislo<>'' THEN c.AdrTrvPopCislo + N'/' + c.AdrTrvOrCislo
			  ELSE ''
		  END AS Cislo_06,
		  c.AdrTrvPSC AS PSC_07,
		  c.DatumNarozeni AS DatumNarozeni_08,
		  CAST('' AS NVARCHAR(30)) AS DIC_09,
     c.RC_C_RC AS RodneCislo_10,
		  c.CisloPasu AS CisloPasu_11
	      ,CAST(0 AS NUMERIC(19, 2)) AS UhrnPrijmu_14
	      ,CAST(0 AS NUMERIC(19, 2)) AS UhrnZdanPrijmu_15
	      ,CAST(0 AS NUMERIC(19, 2)) AS UhrnOdmeny_16
	      ,CAST(0 AS NUMERIC(19, 2)) AS SrazZalohy_17
	      ,CAST(0 AS NUMERIC(19, 2)) AS SrazDan_18
	      --Nové údaje od 2016
	      ,(365 * d.ZamestnaniRoky + d.ZamestnaniDny) - (365 * ISNULL(p.ZamestnaniRoky, 0) + ISNULL(p.ZamestnaniDny, 0)) AS VykonPrace_19
      ,LEFT(ISNULL(c.PasVydal_Zeme,''), 2) AS StatDokladu_13
	      ,'P' AS TypDokladu_12
	      ,'R' AS TypDIC_10
	  INTO #SouhrnneUdajeCizinci2016Plg
	  FROM TabCisZam c
	  JOIN TabZamMzd m ON m.ZamestnanecId=c.ID AND m.IdObdobi=@IdObdobi_12
       JOIN TabZamPer d ON d.ZamestnanecId = c.ID AND d.IdObdobi = @IdObdobi_12
   LEFT JOIN TabMzPocHod p ON p.ZamestnanecID = c.ID AND p.Rok = @Rok
	  WHERE (((c.AdrTrvZeme IS NOT NULL) AND
		      (c.AdrTrvZeme<>(SELECT ISOKod FROM TabZeme WHERE Vlastni=1)))
              OR (m.NerezidentDane = 1))
		  AND EXISTS(
				  SELECT *
				  FROM TabZamVyp v
				  WHERE v.ZamestnanecId=c.ID AND IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1))
		  AND (m.Pobocka=@KodPobocky)
	  ORDER BY c.AdrTrvZeme ASC, c.Prijmeni ASC, c.Jmeno ASC

       DECLARE @UhrnPrijmu_14 NUMERIC(19, 2)
	      ,@UhrnZdanPrijmu_15 NUMERIC(19, 2)
	      ,@UhrnOdmeny_16 NUMERIC(19, 2)
	      ,@SrazZalohy_17 NUMERIC(19, 2)
	      ,@SrazDan_18 NUMERIC(19, 2)

	  DECLARE c CURSOR LOCAL FOR SELECT ZamId FROM #SouhrnneUdajeCizinci2016Plg
	  OPEN c
	  WHILE 1=1
	  BEGIN
		  FETCH NEXT FROM c INTO @ZamestnanecId
		  IF @@FETCH_STATUS<>0 BREAK

            SET @UhrnPrijmu_14 = 0
            SET @UhrnZdanPrijmu_15 = 0
            SET @UhrnOdmeny_16 = 0
            SET @SrazZalohy_17 = 0
            SET @SrazDan_18 = 0

            SELECT @UhrnPrijmu_14 = SUM(UhrnPrijmuZavCin + OsvobozenoDan)
                  ,@UhrnZdanPrijmu_15 = SUM(UhrnPrijmuZavCin)
                  ,@SrazZalohy_17 = SUM(DanPoSleve)
                  ,@SrazDan_18 = SUM(DanSrazkova)
            FROM TabMzdList
		  WHERE ZamestnanecId=@ZamestnanecId AND IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1)

            SET @UhrnOdmeny_16 = (SELECT SUM(l.UhrnPrijmuZavCin)
                                  FROM TabMzdList l
                                  LEFT JOIN TabZamMzd m ON m.ZamestnanecId = l.ZamestnanecId AND m.IdObdobi = l.IdObdobi
                                  WHERE l.ZamestnanecId = @ZamestnanecId
                                    AND l.IdObdobi IN (SELECT MO.IdObdobi FROM TabMzdObd MO LEFT JOIN TabMzKons MKo ON MO.IdObdobi=MKo.IdObdobi WHERE MO.Rok=@Rok AND MKo.OdvodyNaPobocky=1)
                                    AND m.DruhPP IN (11,12))



		  UPDATE #SouhrnneUdajeCizinci2016Plg
              SET UhrnPrijmu_14 = @UhrnPrijmu_14
                , UhrnZdanPrijmu_15 = @UhrnZdanPrijmu_15
                , UhrnOdmeny_16 = @UhrnOdmeny_16
                , SrazZalohy_17 = @SrazZalohy_17
                , SrazDan_18 = @SrazDan_18
            WHERE ZamId = @ZamestnanecId
	  END
	  CLOSE c
	  DEALLOCATE c

	  INSERT dbo.Tabx_VZDSUCizinci2016(IdVZDVDA, h_k_stat, h_prijmeni, h_jmeno, h_naz_obce, h_ulice, h_c_pop_or, h_psc, h_d_naroz, h_dic,
		  h_typ_dic, h_c_pasu, h_typ_pasu, h_k_stat_pasu, h_kc_prijmy, h_kc_mzdy, h_kc_odmeny, h_kc_zalohy, h_sraz_dan, h_delka_vyk
		  )
	  SELECT
		  @IdVZDVDA,
		  LEFT(KodStatu_01, 2) AS KodStatu_01,
		  LEFT(Prijmeni_02, 36) AS Prijmeni_02,
		  LEFT(Jmeno_03, 20) AS Jmeno_03,
		  LEFT(Obec_04, 48) AS Obec_04,
		  LEFT(Ulice_05, 38) AS Ulice_05,
		  LEFT(Cislo_06, 10) AS Cislo_06,
		  LEFT(PSC_07, 10) AS PSC_07,
		  DatumNarozeni_08,
		  LEFT(RodneCislo_10, 20) AS DIC_09,
            TypDIC_10,
		  LEFT(CisloPasu_11, 16) AS CisloPasu_11,
            TypDokladu_12,
            StatDokladu_13,
            ISNULL(UhrnPrijmu_14, 0),
            ISNULL(UhrnZdanPrijmu_15, 0),
            ISNULL(UhrnOdmeny_16, 0), 
            ISNULL(SrazZalohy_17, 0),
            ISNULL(SrazDan_18, 0),
            ISNULL(VykonPrace_19, 0)
	  FROM #SouhrnneUdajeCizinci2016Plg

	  IF OBJECT_ID(N'tempdb..#SouhrnneUdajeCizinci2016Plg') IS NOT NULL
		  DROP TABLE #SouhrnneUdajeCizinci2016Plg
     END

/* PocetZamestnanci */
	INSERT dbo.Tabx_VZDPocZam(IdVZDVDA, naz_vykonu, c_zko, naz_zko, c_obce_zuj, naz_obce_zuj, poc_zam)
	SELECT
		@IdVZDVDA
		,LEFT(ISNULL(TabStrom.Nazev,''), 40)							-- naz_vykonu
		,LEFT(CASE WHEN ISNUMERIC(REPLACE(TabCzNUTS.Kod, N'CZ', ''))=1
				THEN CAST(REPLACE(TabCzNUTS.Kod, N'CZ', '') AS INT)
			ELSE NULL END, 4) AS c_zko							-- c_zko
		,LEFT(ISNULL(CASE WHEN ISNUMERIC(REPLACE(TabCzNUTS.Kod, N'CZ', ''))=1
				THEN LEFT(TabCzNUTS.Nazev,23)
			ELSE N'Chybný kód' END, ''), 23) AS naz_zko			-- naz_zko
		,LEFT(CASE WHEN ISNUMERIC(TabMzStatistika.Cislo)=1
				THEN CAST(TabMzStatistika.Cislo AS INT)
			ELSE NULL END, 6) AS c_obce_zuj						-- c_obce_zuj
		,LEFT(ISNULL(CASE WHEN ISNUMERIC(TabMzStatistika.Cislo)=1
				THEN LEFT(TabMzStatistika.Popis, 40)
			ELSE N'Chybný kód' END, ''), 40) AS naz_obce_zuj			-- naz_obce_zuj
		,ISNULL(SUM(TabMzPrepStavy.ESZacatekMesiceCelkem),0) AS ESZacatekMesice	-- poc_zam
	FROM TabMzStatistika
	RIGHT OUTER JOIN TabZamPer ON TabMzStatistika.Cislo = TabZamPer.KodUzemi
	LEFT JOIN TabZamMzd Mzd ON TabZamPer.IdObdobi=Mzd.IdObdobi AND TabZamPer.ZamestnanecId=Mzd.ZamestnanecId
	LEFT OUTER JOIN TabStrom ON TabZamPer.PracovisteId = TabStrom.Cislo
	LEFT OUTER JOIN TabCzNUTS ON TabZamPer.Pracoviste_NUTS = TabCzNUTS.Kod
	RIGHT OUTER JOIN TabMzPrepStavy ON TabZamPer.IdObdobi = TabMzPrepStavy.IdObdobi AND TabZamPer.ZamestnanecId = TabMzPrepStavy.ZamestnanecId
	LEFT OUTER JOIN TabMzdObd ON TabMzdObd.IdObdobi = TabMzPrepStavy.IdObdobi
	LEFT JOIN TabMzKons MKo ON TabMzdObd.IdObdobi=MKo.IdObdobi
	WHERE (TabMzdObd.Rok=@Rok) AND (TabMzdObd.Mesic = 12) AND ((SELECT TabZamVyp.DanZakladni FROM TabZamVyp WHERE (TabZamVyp.ZamestnanecId = TabMzPrepStavy.ZamestnanecId) AND (TabZamVyp.IdObdobi = TabMzPrepStavy.IdObdobi)) <> 0)
		AND (MKo.OdvodyNaPobocky=1)
		AND (Mzd.Pobocka=@KodPobocky)
	GROUP BY TabStrom.Nazev
			,CASE WHEN ISNUMERIC(REPLACE(TabCzNUTS.Kod, N'CZ', ''))=1 THEN CAST(REPLACE(TabCzNUTS.Kod, N'CZ', '') AS INT) ELSE NULL END
			,CASE WHEN ISNUMERIC(REPLACE(TabCzNUTS.Kod, N'CZ', ''))=1 THEN LEFT(TabCzNUTS.Nazev,23)	ELSE N'Chybný kód' END
			,CASE WHEN ISNUMERIC(TabMzStatistika.Cislo)=1 THEN CAST(TabMzStatistika.Cislo AS INT) ELSE NULL END
			,CASE WHEN ISNUMERIC(TabMzStatistika.Cislo)=1 THEN LEFT(TabMzStatistika.Popis, 40) ELSE N'Chybný kód' END
GO

