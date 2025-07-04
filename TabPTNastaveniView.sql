USE [RayService]
GO

/****** Object:  View [dbo].[TabPTNastaveniView]    Script Date: 04.07.2025 12:49:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPTNastaveniView] AS
  SELECT
    CONVERT(int,ROW_NUMBER() OVER(ORDER BY Ciselnik)) AS Id
    ,CASE WHEN EXISTS (SELECT *
                         FROM TabPenTokKonst
					     WHERE (Kategorie = 1))
          THEN CASE WHEN (DoPenTok = 1)
		            THEN CONVERT(bit,CASE WHEN (PTKategorie_Seznam IS NOT NULL) OR (JeKat = 1) THEN 1 ELSE 0 END)
	                ELSE NULL
	           END
		  ELSE NULL
     END PTKategorie_Je
    ,CONVERT(nvarchar(255),SUBSTRING(SUBSTRING(PTKategorie_Seznam,1,LEN(PTKategorie_Seznam)-1),1,255)) PTKategorie_Seznam
    ,CASE WHEN (DoPenTok = 1)
		 THEN CONVERT(bit,CASE WHEN PTVarianty_Seznam IS NOT NULL THEN 1 ELSE 0 END)
		 ELSE CONVERT(bit,0)
	 END PTVarianty_Jsou
    ,CONVERT(nvarchar(255),SUBSTRING(SUBSTRING(PTVarianty_Seznam,1,LEN(PTVarianty_Seznam)-1),1,255)) PTVarianty_Seznam
    ,Ciselnik
	,CiselnikID
	,DoPenTok
	,DruhPohybuZbo
	,IdBankSp
	,IdCisUct
	,IdDosleObjRada
	,IdDruhDZ
	,IdLeaSkup
	,IdPokl
	,IdSalSk
    ,Nazev
	,PredAnal
	,RadaDokladu
	,Typ
    FROM(
      SELECT
        DoPenTok                       DoPenTok
        ,0                             Ciselnik
		,'0.'+CONVERT(nvarchar(10),Id) CiselnikID
        ,NULL                          DruhPohybuZbo
        ,NULL                          IdBankSp
		,NULL                          IdCisUct
        ,NULL                          IdDosleObjRada
        ,NULL                          IdDruhDZ
		,NULL                          IdLeaSkup
        ,NULL                          IdPokl
        ,Id                            IdSalSk
        ,CONVERT(bit
        ,CASE WHEN EXISTS(SELECT *
                            FROM TabVKatPTSal
					    			        WHERE (CisloSalSk = TabVKatPTSal.CisloSalSk)
             							        AND (Id IS NOT NULL))
              THEN 1
    				  ELSE 0
    		 END)                   JeKat
        ,NazevSalSk             Nazev
        ,CASE WHEN DoPenTok = 1
		          THEN CONVERT(bit,PredAnal)
			        ELSE CONVERT(bit,0)
		     END	  PredAnal
        ,(SELECT CONVERT(NVarchar(30),TabKategoriePT.KategoriePT)+', '
		        FROM TabKategoriePT
              LEFT OUTER JOIN TabVKatPTSal VPTKategorieSalSk ON TabKategoriePT.Id = VPTKategorieSalSk.IdKatPT
            WHERE (VPTKategorieSalSk.CisloSalSk = TabSalSk.CisloSalSk)
		        FOR XML Path('')) PTKategorie_Seznam
        ,(SELECT CONVERT(NVarchar(30),TabVariantyPT.Nazev)+', '
            FROM TabVariantyPT
              LEFT OUTER JOIN TabVVarPTSal VPTVariantySalSk ON TabVariantyPT.Id = VPTVariantySalSk.IdVarPT
            WHERE (VPTVariantySalSk.CisloSalSk = TabSalSk.CisloSalSk)
		        FOR XML Path('')) PTVarianty_Seznam
        ,CisloSalSk             RadaDokladu
		,0                      Typ
        FROM TabSalSk
    UNION ALL
      SELECT
        DoPenTok                       DoPenTok
        ,1                             Ciselnik
		,'1.'+CONVERT(nvarchar(10),Id) CiselnikID
    	,DruhPohybuZbo                 DruhPohybuZbo
    	,NULL                          IdBankSp
		,NULL                          IdCisUct
		,NULL                          IdDosleObjRada
        ,Id                            IdDruhDZ
		,NULL                          IdLeaSkup
    	,NULL                          IdPokl
    	,NULL                          IdSalSk
        ,CONVERT(bit
        ,CASE WHEN EXISTS(SELECT *
		                        FROM TabVKatPTDruhDZ
				  	                WHERE (Id = TabVKatPTDruhDZ.IdRadaDokladu)
						    		              AND (Id IS NOT NULL))
			        THEN 1
    				  ELSE 0
	       END)                   JeKat
    	  ,Nazev                  Nazev
		    ,CASE WHEN (DoPenTok = 1)AND(DruhPohybuZbo IN (2,3,4,9,10,13,14))
		          THEN CONVERT(bit,PredAnal)
			        ELSE CONVERT(bit,0)
		     END	  PredAnal
        ,(SELECT CONVERT(NVarchar(30),TabKategoriePT.KategoriePT)+', '
		        FROM TabKategoriePT
              LEFT OUTER JOIN TabVKatPTDruhDZ VPTKategorieDruhDokZbo ON TabKategoriePT.Id = VPTKategorieDruhDokZbo.IdKatPT
            WHERE (VPTKategorieDruhDokZbo.IdRadaDokladu = TabDruhDokZbo.Id)
		        FOR XML Path('')) PTKategorie_Seznam
        ,(SELECT CONVERT(NVarchar(30),TabVariantyPT.Nazev)+', '
            FROM TabVariantyPT
              LEFT OUTER JOIN TabVVarPTDruhDZ VPTVariantyDruhDokZbo ON TabVariantyPT.Id = VPTVariantyDruhDokZbo.IdVarPT
            WHERE (VPTVariantyDruhDokZbo.IdRadaDokladu = TabDruhDokZbo.Id)
		        FOR XML Path('')) PTVarianty_Seznam
        ,RadaDokladu            RadaDokladu
		,0                      Typ
        FROM TabDruhDokZbo
		WHERE DruhPohybuZbo IN (0,1,2,3,4,6,9,13,14,18,19)
    UNION ALL
      SELECT
        DoPenTok                       DoPenTok
        ,2                             Ciselnik
		,'2.'+CONVERT(nvarchar(10),Id) CiselnikID
    	,NULL                          DruhPohybuZbo
    	,NULL                          IdBankSp
		,NULL                          IdCisUct
		,Id                            IdDosleObjRada
        ,NULL                          IdDruhDZ
		,NULL                          IdLeaSkup
    	,NULL                          IdPokl
    	,NULL                          IdSalSk
        ,CONVERT(bit
        ,CASE WHEN EXISTS(SELECT *
 	                          FROM TabPTKategorieVazby
    				                WHERE (Id = TabPTKategorieVazby.IdDosleObjRada)
		    		                      AND (Id IS NOT NULL))
		    	    THEN 1
    	  			ELSE 0
	       END)                   JeKat
		    ,Nazev                  Nazev
		    ,CASE WHEN DoPenTok = 1
		          THEN CONVERT(bit,PredAnal)
			        ELSE CONVERT(bit,0)
		     END	                   PredAnal
       ,(SELECT CONVERT(NVarchar(30),TabKategoriePT.KategoriePT)+', '
		            FROM TabKategoriePT
              LEFT OUTER JOIN TabPTKategorieVazby VPTKategorieVazby ON TabKategoriePT.Id = VPTKategorieVazby.IdPTKategorie
            WHERE (VPTKategorieVazby.IdDosleObjRada = TabDosleObjRada.Id)
		            FOR XML Path('')) PTKategorie_Seznam
        ,(SELECT CONVERT(NVarchar(30),TabVariantyPT.Nazev)+', '
            FROM TabVariantyPT
              LEFT OUTER JOIN TabPTVariantyVazby VPTVariantyVazby ON TabVariantyPT.Id = VPTVariantyVazby.IdPTVarianty
            WHERE (VPTVariantyVazby.IdDosleObjRada = TabDosleObjRada.Id)
		            FOR XML Path('')) PTVarianty_Seznam
        ,Rada                   RadaDokladu
		,0                      Typ
        FROM TabDosleObjRada
    UNION ALL
      SELECT
        DoPenTok                       DoPenTok
        ,3                             Ciselnik
        ,'3.'+CONVERT(nvarchar(10),Id) CiselnikID
        ,NULL                          DruhPohybuZbo
        ,NULL                          IdBankSp
		,NULL                          IdCisUct
		,NULL                          IdDosleObjRada
        ,NULL                          IdDruhDZ
		,NULL                          IdLeaSkup
    	,Id                            IdPokl
	    ,NULL                          IdSalSk
        ,NULL                          JeKat
    	,Nazev                         Nazev
        ,CONVERT(bit,0)                PredAnal
        ,NULL                          PTKategorie_Seznam
        ,(SELECT CONVERT(NVarchar(30),TabVariantyPT.Nazev)+', '
            FROM TabVariantyPT
              LEFT OUTER JOIN TabVVarPTPokl VPTVariantyDruhPokladen
			  ON TabVariantyPT.Id = VPTVariantyDruhPokladen.IdVarPT
            WHERE (VPTVariantyDruhPokladen.CisloPokladny = TabDruhPokladen.Cislo)
		    FOR XML Path(''))          PTVarianty_Seznam
        ,Cislo                         RadaDokladu
		,1                             Typ
        FROM TabDruhPokladen
    UNION ALL
      SELECT
        TabBankSpojeni.DoPenTok                       DoPenTok
        ,4                                            Ciselnik
        ,'4.'+CONVERT(nvarchar(10),TabBankSpojeni.Id) CiselnikID
    	,NULL                                         DruhPohybuZbo
    	,TabBankSpojeni.Id                            IdBankSp
		,NULL                                         IdCisUct
		,NULL                                         IdDosleObjRada
		,NULL                                         IdDruhDZ
		,NULL                                         IdLeaSkup
       	,NULL                                         IdPokl
	    ,NULL                                         IdSalSk
        ,NULL                                         JeKat
    	,TabBankSpojeni.CisloUctu                     Nazev
        ,CONVERT(bit,0)                               PredAnal
        ,NULL                                         PTKategorie_Seznam
        ,(SELECT CONVERT(NVarchar(30),TabVariantyPT.Nazev)+', '
            FROM TabVariantyPT
              LEFT OUTER JOIN TabVVarPTBankSp VPTVariantyBankSpojeni ON TabVariantyPT.Id = VPTVariantyBankSpojeni.IdVarPT
            WHERE (VPTVariantyBankSpojeni.IdBankSp = TabBankSpojeni.Id)
		        FOR XML Path(''))                     PTVarianty_Seznam
        ,N'   '                                       RadaDokladu
		,1                                            Typ
        FROM TabBankSpojeni
	        JOIN TabCisOrg ON TabCisOrg.Id=TabBankSpojeni.IDOrg
        WHERE TabCisOrg.CisloOrg=0--) AS MyResults
    UNION ALL
      SELECT
        tabPTVPTUcto.DoPenTok          DoPenTok
        ,5                             Ciselnik
        ,'5.'+CONVERT(nvarchar(10),Id) CiselnikID
        ,NULL                          DruhPohybuZbo
        ,NULL                          IdBankSp
        ,Id                            IdCisUct
		,NULL                          IdDosleObjRada
        ,NULL                          IdDruhDZ
		,NULL                          IdLeaSkup
    	,NULL                          IdPokl
	    ,NULL                          IdSalSk
        ,NULL                          JeKat
        ,tabCisUctDef.NazevUctu        Nazev
        ,CONVERT(bit,0)                PredAnal
        ,NULL                          PTKategorie_Seznam
        ,(SELECT CONVERT(NVarchar(30),TabVariantyPT.Nazev)+', '
            FROM TabVariantyPT
              LEFT OUTER JOIN TabPTVVarUcto VPTVariantyCisUcto
			  ON TabVariantyPT.Id = VPTVariantyCisUcto.IdVarPT
            WHERE (VPTVariantyCisUcto.CisloUcet = TabCisUct.CisloUcet)
		    FOR XML Path(''))          PTVarianty_Seznam
        ,tabCisUct.CisloUcet           RadaDokladu
		,1                             Typ
        FROM TabCisUct--TabDruhPokladen
  		  LEFT OUTER JOIN tabCisUctDef
          ON (TabCisUct.CisloUcet = tabCisUctDef.CisloUcet)
             AND(IdObdobi = (SELECT Id
                              FROM TabObdobi
                              WHERE DatumOd < GETDATE()
                                    AND DatumDo > GETDATE()))
  		  INNER JOIN tabPTVPTUcto
          ON (TabCisUct.CisloUcet = tabPTVPTUcto.CisloUcet)UNION ALL
SELECT
TabSTDLeaSkupina.DoPenTok           DoPenTok
,6                                  Ciselnik
,'6.'+CONVERT(nvarchar(10),Id)      CiselnikID
,NULL                               DruhPohybuZbo
,NULL                               IdBankSp
,NULL                               IdCisUct
,NULL                               IdDosleObjRada
,NULL                               IdDruhDZ
,Id                                 IdLeaSkup
,NULL                               IdPokl
,NULL                               IdSalSk
,NULL                               JeKat
,NazevSkupina1                      Nazev
,CONVERT(bit,0)                     PredAnal
,(SELECT CONVERT(NVarchar(30),TabKategoriePT.KategoriePT)+', '
FROM TabKategoriePT
LEFT OUTER JOIN TabPTVKatLeas VPTKategorLeas ON TabKategoriePT.Id = VPTKategorLeas.IdKatPT
WHERE (VPTKategorLeas.IdLeaSkup = TabSTDLeaSkupina.Id)
FOR XML Path('')) PTKategorie_Seznam
,(SELECT CONVERT(NVarchar(30),TabVariantyPT.Nazev)+', '
FROM TabVariantyPT
LEFT OUTER JOIN TabPTVVarLeas VPTVariantyLeas
ON TabVariantyPT.Id = VPTVariantyLeas.IdVarPT
WHERE (VPTVariantyLeas.IdLeaSkup = TabSTDLeaSkupina.Id)
FOR XML Path(''))               PTVarianty_Seznam
,CONVERT(nvarchar(30),CisloSkupina) RadaDokladu
,0                                  Typ
FROM TabSTDLeaSkupina
) AS MyResults
GO

