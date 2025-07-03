USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Gatema_PohybUmisteni_Insert]    Script Date: 03.07.2025 9:26:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_Gatema_PohybUmisteni_Insert] ON [dbo].[Gatema_PohybUmisteni] FOR INSERT
AS 
SET NOCOUNT ON 
IF (EXISTS(SELECT *
			FROM INSERTED I
				INNER JOIN TabStavSkladu SS ON SS.ID = I.IDStavSkladu
				INNER JOIN TabUmisteni U ON U.ID = I.IDUmisteni
			WHERE SS.IDSklad <> U.IdSklad))
BEGIN
	IF @@trancount>0 ROLLBACK TRAN 
	RAISERROR(N'Nesoulad skladu na kartě a na umístění', 16, 1)
END
GO

ALTER TABLE [dbo].[Gatema_PohybUmisteni] ENABLE TRIGGER [et_Gatema_PohybUmisteni_Insert]
GO

