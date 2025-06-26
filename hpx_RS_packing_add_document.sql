USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_packing_add_document]    Script Date: 26.06.2025 11:42:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_packing_add_document]
@ID_baleni INT,
@Poznamka NVARCHAR(255),
@Mnozstvi NUMERIC(19,6),
@ID INT
AS
BEGIN
INSERT INTO Tabx_RS_Packing_Doklad (ID_VyrCP_Item,ID_baleni,Mnozstvi,Poznamka)
SELECT vcp.ID,@ID_baleni,ISNULL(NULLIF(@Mnozstvi,0),vcp.Mnozstvi),@Poznamka
FROM TabVyrCP vcp
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
WHERE vcp.ID=@ID
END
GO

