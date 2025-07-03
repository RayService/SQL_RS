USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabVyrCP_Gatema_PohybUmisteni_Delete]    Script Date: 03.07.2025 8:39:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabVyrCP_Gatema_PohybUmisteni_Delete] ON [dbo].[TabVyrCP] FOR DELETE 
AS 
	IF (EXISTS(SELECT * FROM DELETED Del INNER JOIN TabPohybyZbozi PZ ON PZ.ID = Del.IDPolozkaDokladu WHERE PZ.DruhPohybuZbo IN (2, 4))) AND 
		(EXISTS(SELECT * FROM Gatema_PohybUmisteni WHERE IDPohZbo IN (SELECT IDPolozkaDokladu FROM DELETED)))
	BEGIN
		RAISERROR('Nelze smazat! Na záznam je navázán pohyb umístění.', 16, 1)
		IF (@@TRANCOUNT > 0) ROLLBACK TRAN
	END




GO

ALTER TABLE [dbo].[TabVyrCP] ENABLE TRIGGER [et_TabVyrCP_Gatema_PohybUmisteni_Delete]
GO

EXEC sp_settriggerorder @triggername=N'[dbo].[et_TabVyrCP_Gatema_PohybUmisteni_Delete]', @order=N'First', @stmttype=N'DELETE'
GO

