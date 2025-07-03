USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_cislozakazky]    Script Date: 03.07.2025 9:55:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabDokladyZbozi_cislozakazky] ON [dbo].[TabDokladyZbozi]
FOR UPDATE
AS
IF @@ROWCOUNT = 0 RETURN;
SET XACT_ABORT, NOCOUNT ON;

-- CisloZakazky na polozky (expedicni prikazy)
IF UPDATE(BlokovaniEditoru)
	--MŽ,11.4.2022 vypnuto: AND UPDATE(CisloZakazky)
	AND EXISTS(SELECT * FROM inserted WHERE DruhPohybuZbo IN (9,11) AND CisloZakazky IS NOT NULL)
	BEGIN
		UPDATE tpz SET 
			CisloZakazky = I.CisloZakazky
		FROM TabPohybyZbozi tpz
			INNER JOIN inserted I ON tpz.IDDoklad = I.ID
			WHERE (I.DruhPohybuZbo = 9 OR ((I.IDSklad='200')AND(I.DruhPohybuZbo=11)AND(I.RadaDokladu IN (N'320',N'330',N'383',N'384',N'385',N'374',N'376'))));
	END;


-- KontaktniOsoba za zakazky (Nabidky)
IF UPDATE(BlokovaniEditoru)
	AND EXISTS(SELECT * FROM inserted WHERE DruhPohybuZbo = 11 AND CisloZakazky IS NOT NULL AND KontaktOsoba IS NULL)
	BEGIN
		UPDATE tdz SET 
			tdz.kontaktosoba = tck.ID
		FROM TabDokladyZbozi tdz
			INNER JOIN inserted I ON tdz.ID = I.ID
			INNER JOIN TabZakazka tz ON tz.CisloZakazky = I.CisloZakazky
			INNER JOIN TabCisKOs tck ON tck.Cislo = tz.KontaktOsoba
		WHERE I.DruhPohybuZbo = 11 
			AND ((I.IDSklad=N'100' AND I.RadaDokladu IN (N'300',N'310',N'311'))OR(I.IDSklad=N'200' AND tdz.RadaDokladu IN (N'320',N'330',N'374'))) 
	END;

GO

ALTER TABLE [dbo].[TabDokladyZbozi] ENABLE TRIGGER [et_TabDokladyZbozi_cislozakazky]
GO

