USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PolRamcovaKoObNew]    Script Date: 30.06.2025 8:09:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PolRamcovaKoObNew]
  @PrvniPruchod BIT
AS

DECLARE @IDobj INT
DECLARE @Polozka INT
SET @IDobj=(SELECT TOP 1 IDHlavicka FROM Tabx_RS_IDRamcKoOB WHERE IDSession=@@SPID)
SET @Polozka=(SELECT MAX(Polozka)+1 FROM Tabx_RS_PolRamcKoopObj WHERE IDObjednavky=@IDobj)
SELECT @IDobj AS IDObjednavky, @Polozka AS Polozka


GO

