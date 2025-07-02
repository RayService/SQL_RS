USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_Gatema_PohybUmisteni_Delete]    Script Date: 02.07.2025 15:54:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPohybyZbozi_Gatema_PohybUmisteni_Delete] ON [dbo].[TabPohybyZbozi] FOR DELETE 
AS 
	IF (EXISTS(SELECT * FROM Gatema_PohybUmisteni WHERE IDPohZbo IN (SELECT ID FROM DELETED)))
	BEGIN
		RAISERROR('Nelze smazat! Na záznam je navázán pohyb umístění.', 16, 1)
		IF (@@TRANCOUNT > 0) ROLLBACK TRAN
	END


GO

ALTER TABLE [dbo].[TabPohybyZbozi] ENABLE TRIGGER [et_TabPohybyZbozi_Gatema_PohybUmisteni_Delete]
GO

EXEC sp_settriggerorder @triggername=N'[dbo].[et_TabPohybyZbozi_Gatema_PohybUmisteni_Delete]', @order=N'First', @stmttype=N'DELETE'
GO

