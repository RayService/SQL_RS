USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PridatPoznamku3]    Script Date: 30.06.2025 8:45:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PridatPoznamku3]
@Poznamka NVARCHAR(MAX),
@kontrola BIT,
@ID INT
AS
IF @kontrola=1
BEGIN
UPDATE TabDokladyZbozi SET TabDokladyZbozi.Text2=CAST((ISNULL(CAST(TabDokladyZbozi.Text2 AS NVARCHAR(MAX)),'') +'
'+ @Poznamka) AS NVARCHAR(MAX)) WHERE ID=@ID
END
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přidat.',16,1)
RETURN;
END;
GO

