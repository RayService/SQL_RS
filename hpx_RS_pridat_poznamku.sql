USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_pridat_poznamku]    Script Date: 26.06.2025 11:03:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_pridat_poznamku]
@Poznamka NVARCHAR(255),
@ID int
AS
BEGIN
UPDATE TabKmenZbozi SET TabKmenZbozi.Poznamka=CAST((ISNULL(CAST(TabKmenZbozi.Poznamka AS NVARCHAR(MAX)),'') +'
'+ @Poznamka) AS NTEXT) WHERE ID=@ID
END
GO

