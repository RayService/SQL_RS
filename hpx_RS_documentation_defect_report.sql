USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_documentation_defect_report]    Script Date: 26.06.2025 12:45:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_documentation_defect_report] @ID INT
AS
DECLARE @IDNewDoc INT

IF NOT EXISTS (SELECT * FROM TabDokumVazba WHERE IdentVazby=86 AND IdTab=@ID AND IdUzivTab=0)
BEGIN
INSERT INTO TabDokumenty (JmenoACesta,Popis,VseobDok,Oznaceni,SledovatHistorii)
SELECT 'https://dima-backend-production.rayservice.com/upload/file/'+RIGHT('0000'+CAST(CEILING(ID/1000)+1 AS VARCHAR(4)),4)+'/'+RIGHT('00000000' + CAST(ID AS VARCHAR(8)), 8)+'.jpg',
RIGHT('00000000' + CAST(ID AS VARCHAR(8)), 8)+'.jpg',1,'Neshody',0
FROM Tabx_Apps_QaDefectReportFile
WHERE defectReportId=@ID
SET @IDNewDoc=SCOPE_IDENTITY();

INSERT INTO TabDokumVazba (IdentVazby,IdTab,IdDok,IdUzivTab)
VALUES (86,@ID,@IdNewDoc,0)
END;
GO

