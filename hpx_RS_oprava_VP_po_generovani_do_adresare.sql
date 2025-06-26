USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_oprava_VP_po_generovani_do_adresare]    Script Date: 26.06.2025 13:39:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_oprava_VP_po_generovani_do_adresare]
AS

--nakonec vrátíme zpět datum tisku a autora tisku VP
MERGE TabPrikaz AS TARGET
--USING #Prikazy AS SOURCE
USING Tabx_RS_TiskPrikazy AS SOURCE
ON TARGET.ID=SOURCE.IDPrikaz
WHEN MATCHED THEN
UPDATE SET TARGET.DatumTisku=SOURCE.DatTisku, TARGET.AutorTisku=SOURCE.AutorTisku
;

GO

