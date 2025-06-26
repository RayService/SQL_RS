USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZapisEvidenceTPVDoQANeshody]    Script Date: 26.06.2025 10:59:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_ZapisEvidenceTPVDoQANeshody]
	@IDMzdy INT
AS
SET NOCOUNT ON;
-- ==============================================================================================================
-- Author:		MŽ
-- Description:	Při evidenci práce na operaci TPV generované zápisem neshody - propsat poznámku zpět do neshody a změnit Řešení neshody
-- Date: 29.6.2021
-- ==============================================================================================================
--DECLARE @IDMzdy INT=2188929;
DECLARE @IDOPerationTPV INT;
DECLARE @IDOperationQA INT;
DECLARE @IDMzdyQA INT;
DECLARE @PoznamkaTPV NVARCHAR(255);
SET @IDOPerationTPV=(SELECT tpp.ID
					FROM TabPrPostup tpp
					LEFT OUTER JOIN TabPrikazMzdyAZmetky tpmz WITH(NOLOCK) ON tpmz.IDPrikaz=tpp.IDPrikaz AND tpmz.DokladPrPostup=tpp.Doklad
					WHERE tpmz.ID=@IDMzdy)
SET @IDMzdyQA=(SELECT operationId
				FROM B2A_qa_report_operation
				WHERE resultOperationTpv100Id=@IDOPerationTPV)
SET @PoznamkaTPV=(SELECT tpmz.Poznamka
					FROM TabPrikazMzdyAZmetky tpmz
					LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmze WITH(NOLOCK) ON tpmze.ID=tpmz.ID
					WHERE tpmz.ID =@IDMzdy)

SELECT @IDOPerationTPV, @IDMzdyQA, @PoznamkaTPV AS 'Poznámka TPV'
IF (SELECT tpmz.kusy_odv FROM TabPrikazMzdyAZmetky tpmz WHERE tpmz.ID=@IDMzdy)>=1
BEGIN
UPDATE tpmz SET tpmz.Poznamka=CAST((ISNULL(CAST(tpmz.Poznamka AS NVARCHAR(MAX)),'') +'
'+ @PoznamkaTPV) AS NTEXT)
FROM TabPrikazMzdyAZmetky tpmz
WHERE tpmz.ID=@IDMzdyQA
UPDATE tpmze SET _stavneshod='Opraveno'
FROM TabPrikazMzdyAZmetky tpmz
LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmze WITH(NOLOCK) ON tpmze.ID=tpmz.ID
WHERE tpmz.ID=@IDMzdyQA
END
/*SELECT tpmz.ID, tpmz.IDPrikaz, tpmz.DokladPrPostup, tpmz.kusy_odv, tpmz.Poznamka,tpmze._stavneshod
FROM TabPrikazMzdyAZmetky tpmz
LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmze WITH(NOLOCK) ON tpmze.ID=tpmz.ID
WHERE tpmz.ID =@IDMzdy
SELECT tpmz.ID, tpmz.IDPrikaz, tpmz.DokladPrPostup, tpmz.kusy_odv, tpmz.Poznamka,tpmze._stavneshod
FROM TabPrikazMzdyAZmetky tpmz
LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmze WITH(NOLOCK) ON tpmze.ID=tpmz.ID
WHERE tpmz.ID =@IDMzdyQA*/
GO

