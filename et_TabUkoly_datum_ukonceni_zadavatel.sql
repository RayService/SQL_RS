USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabUkoly_datum_ukonceni_zadavatel]    Script Date: 03.07.2025 8:26:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabUkoly_datum_ukonceni_zadavatel] ON [dbo].[TabUkoly]
FOR UPDATE
AS
--===================================
--Author: MŽ
--Description: Datum ukončení polovolen zadat pouze zadavateli
--Date: 17.7.2019
--===================================
DECLARE @user NVARCHAR(128)
SET @user = (SELECT TOP 1 LoginId FROM deleted i JOIN TabCisZam b on i.Zadavatel = b.Cislo)
BEGIN
  IF UPDATE(DatumDokonceni) OR UPDATE(Zadavatel)
  BEGIN
    if exists(
		SELECT * 
		FROM deleted a 
		INNER JOIN TabCisZam b on a.Zadavatel = b.Cislo
		INNER JOIN TabKontaktJednani c ON c.ID = a.IDKontaktJed--=TabKontaktJednani.ID AND TabUkoly.Vzor=0 
		WHERE SUSER_SNAME() NOT IN (@user,'sa','zalesak') AND c.Kategorie NOT IN ('Q04','909')
		/*WHERE SUSER_SNAME() NOT IN (b.LoginId,'sa') AND c.Kategorie <> 'Q04'*/
	) BEGIN
        ROLLBACK
        RAISERROR('Vyplnění pole Datum dokončení nebo změna pole Zadavatel není povoleno, kontaktujte Zadavatele', 16, 1);
  	
      END
/*	  
  IF UPDATE(Zadavatel)
    if exists(
		SELECT * 
		FROM inserted a 
		INNER JOIN TabCisZam b on a.Zadavatel = b.Cislo
		INNER JOIN TabKontaktJednani c ON c.ID = a.IDKontaktJed--=TabKontaktJednani.ID AND TabUkoly.Vzor=0 
		WHERE SUSER_SNAME() NOT IN (@user,'sa','zalesak') AND c.Kategorie NOT IN ('Q04','909')
		/*WHERE SUSER_SNAME() NOT IN (b.LoginId,'sa') AND c.Kategorie <> 'Q04'*/
	) BEGIN
        ROLLBACK
        RAISERROR('Změna pole Zadavatel není povolena, kontaktujte Zadavatele', 16, 1);
  	
      END
	*/  
	END;
END

GO

ALTER TABLE [dbo].[TabUkoly] ENABLE TRIGGER [et_TabUkoly_datum_ukonceni_zadavatel]
GO

