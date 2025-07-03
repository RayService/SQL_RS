USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabUkoly_editace]    Script Date: 03.07.2025 8:27:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabUkoly_editace] ON [dbo].[TabUkoly]
FOR UPDATE
AS
DECLARE @user NVARCHAR(128)
SET @user = (SELECT TOP 1 LoginId FROM inserted i JOIN TabCisZam b on i.Zadavatel = b.Cislo)
BEGIN
  IF UPDATE(TerminSplneni)
    if exists(
		SELECT * 
		FROM inserted a 
		INNER JOIN TabCisZam b on a.Zadavatel = b.Cislo 
		INNER JOIN TabKontaktJednani c ON c.ID = a.IDKontaktJed--=TabKontaktJednani.ID AND TabUkoly.Vzor=0 
		WHERE SUSER_SNAME() NOT IN (b.LoginId,'sa','zalesak') AND c.Kategorie <> '909'
	) BEGIN
        ROLLBACK
        RAISERROR('Změna pole Termín splnění není povolena, kontaktujte Zadavatele', 16, 1);
  	
      END
/*
  IF UPDATE(Zadavatel)
    if exists(
		SELECT * 
		FROM inserted a 
		INNER JOIN TabCisZam b on a.Zadavatel = b.Cislo 
		WHERE SUSER_SNAME() NOT IN (@user,'sa') 
	) BEGIN
        ROLLBACK
        RAISERROR('Změna pole Zadavatel není povolena, kontaktujte Zadavatele', 16, 1);
  	
      END
*/
END

GO

ALTER TABLE [dbo].[TabUkoly] ENABLE TRIGGER [et_TabUkoly_editace]
GO

