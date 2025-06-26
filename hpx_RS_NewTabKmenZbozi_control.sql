USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NewTabKmenZbozi_control]    Script Date: 26.06.2025 13:33:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NewTabKmenZbozi_control]
  @PrvniPruchod BIT
AS
IF (SELECT BrowseID FROM #TempDefFormInfo)=2 AND (SELECT TabName FROM #TempDefFormInfo)='TabKmenZbozi'
AND (SELECT SkupZbo FROM #TempDefForm_NovaVeta) NOT LIKE N'9%'
BEGIN
RAISERROR('Skladovou kartu nelze založit v modulu Kmenové karty, lze pouze v modulu Technická příprava výroby.',16,1)
END;
GO

