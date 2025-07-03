USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokumenty_editace_schvalil]    Script Date: 03.07.2025 10:00:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--MŽ, 28.9.2022 11:10 vypnuto na přání PeZ

CREATE TRIGGER [dbo].[et_TabDokumenty_editace_schvalil] ON [dbo].[TabDokumenty]
FOR UPDATE
AS
DECLARE @Stav INT
SET @Stav = (SELECT Stav FROM inserted I)
--DECLARE @user NVARCHAR(128)
--SET @user = (SELECT TOP 1 LoginId FROM inserted i JOIN TabCisZam b on i.Zadavatel = b.Cislo)
BEGIN
  IF (UPDATE(DatSchvaleno) OR UPDATE(DatSchvalenoQMS) OR UPDATE(IDZamSchvalil) OR UPDATE(IDZamSchvalilQMS))
    IF @Stav=6 AND SUSER_SNAME() NOT IN ('hodulikova','zalesak')
	BEGIN
        ROLLBACK
        RAISERROR('Nelze editovat Schválil, Schválil II, Schváleno nebo Schváleno II, je-li dokument Platný!', 16, 1);
  	END
END

GO

ALTER TABLE [dbo].[TabDokumenty] ENABLE TRIGGER [et_TabDokumenty_editace_schvalil]
GO

