USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_packing_insert]    Script Date: 26.06.2025 11:43:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_packing_insert]
@ID_packing INT,
@ID_VyrCS_packing INT,
@Sirka NUMERIC(19,6),
@Hloubka NUMERIC(19,6),
@Vyska NUMERIC(19,6),
@Hmotnost NUMERIC(19,6),
@cislo_baleni INT
AS
BEGIN
INSERT INTO Tabx_RS_Packin (ID_Item_packing,ID_VyrCS_packing,sirka,delka,vyska,Hmotnost,cislo_baleni)
SELECT @ID_packing,@ID_VyrCS_packing,@Sirka,@Hloubka,@Vyska,@Hmotnost,@cislo_baleni
END
GO

