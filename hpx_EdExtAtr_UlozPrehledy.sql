USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_EdExtAtr_UlozPrehledy]    Script Date: 26.06.2025 9:32:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_EdExtAtr_UlozPrehledy] AS
TRUNCATE TABLE Tabx_EdExtAtr_Prehledy
INSERT INTO Tabx_EdExtAtr_Prehledy (BID, BrowseName, TableName, Soudecek)
SELECT BID, BrowseName, TableName, Soudecek
FROM #TabPravaPrehledTemp
GO

