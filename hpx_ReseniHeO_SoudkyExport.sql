USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ReseniHeO_SoudkyExport]    Script Date: 26.06.2025 8:37:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_ReseniHeO_SoudkyExport]
	@ID INT		-- ID v TabSoudky
AS
-- =============================================
-- Author:		DJ
-- Create date: 26.11.2011
-- Description:	Export soudků do importní tabulky
-- =============================================
SET NOCOUNT ON
/* deklarace */
DECLARE @Oznacenych SMALLINT
DECLARE @Aktualni SMALLINT

SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM' 
SELECT @Aktualni = Cislo FROM #TabExtKomPar WHERE Popis = 'PRECHOD'

/* funkční tělo procedury */
-- * akce - první řádek
IF @Aktualni IS NULL OR @Aktualni = 1
	BEGIN
		-- tabulka neexistuje - založíme
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TempSoudkyImp]') AND type in (N'U'))
			DROP TABLE [dbo].[TempSoudkyImp]
			
		CREATE TABLE [dbo].[TempSoudkyImp](
			[Soudek] [nvarchar](40) NOT NULL,
			[BrowseID] [nvarchar](36) NOT NULL,
			[AltNazev] [nvarchar](40) NOT NULL,
			[Poradi] [int] NULL,
			[Systemovy] [bit] NOT NULL,
			[IDFiltr] [int] NULL,
			[Skupina] [nvarchar](30) NOT NULL,
			[IDPredek] [int] NULL,
			[TabFiltr_GUID] [binary](16) NULL,
			[P_Soudek] [nvarchar](40) NULL,
			[P_BrowseID] [nvarchar](36) NULL,
			[P_IDFiltr] [int] NULL,
			[P_TabFiltr_GUID] [binary](16) NULL,
			[TabSoudkyPoradi_Poradi] [tinyint] NULL,
		) ON [PRIMARY]
		
		-- smazeme data
		TRUNCATE TABLE TempSoudkyImp

	END
	
-- * akce - každý řádek
INSERT INTO TempSoudkyImp(
	Soudek
	,BrowseID
	,AltNazev
	,Poradi
	,Systemovy
	,IDFiltr
	,Skupina
	,IDPredek
	,TabFiltr_GUID
	,P_Soudek
	,P_BrowseID
	,P_IDFiltr
	,P_TabFiltr_GUID
	,TabSoudkyPoradi_Poradi)
SELECT
	S.Soudek
	,S.BrowseID
	,S.AltNazev
	,S.Poradi
	,S.Systemovy
	,NULL as IDFiltr
	,S.Skupina
	,NULL as IDPredek
	,F.[GUID] as TabFiltr_GUID
	,PS.Soudek as P_Soudek
	,PS.BrowseID as P_BrowseID
	,NULL as P_IDFiltr
	,PF.[GUID] as P_TabFiltr_GUID
	,SP.Poradi as TabSoudkyPoradi_Poradi
FROM TabSoudky S
	LEFT OUTER JOIN TabFiltr F ON S.IDFiltr = F.ID
	LEFT OUTER JOIN TabSoudky PS ON S.IDPredek = PS.ID
	LEFT OUTER JOIN TabFiltr PF ON PS.IDFiltr = PF.ID
	LEFT OUTER JOIN TabSoudkyPoradi SP ON S.Soudek = SP.Soudek
WHERE S.ID = @ID
GO

