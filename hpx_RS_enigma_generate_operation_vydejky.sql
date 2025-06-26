USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_enigma_generate_operation_vydejky]    Script Date: 26.06.2025 13:11:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_enigma_generate_operation_vydejky] @ID INT
AS
--cvičná deklarace
--DECLARE @ID INT=1456352

DECLARE @IDOperace INT;
DECLARE @enigma_nr_new INT,@enigma_nr INT

SET @IDOperace=(SELECT prp.ID
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabPrKVazby prkv ON tpz.IDPrikaz=prkv.IDPrikaz AND tpz.DokladPrikazu=prkv.Doklad AND tpz.TypVyrobnihoDokladu IN (1,2) AND (SELECT SS.IDKmenZbozi FROM TabStavSkladu SS WHERE SS.ID=tpz.IDZboSklad)=prkv.nizsi AND prkv.IDOdchylkyDo IS NULL
LEFT OUTER JOIN TabPrPostup prp ON prp.Operace=prkv.Operace AND prp.IDOdchylkyDo IS NULL AND prkv.IDPrikaz=prp.IDPrikaz
WHERE tpz.IDDoklad=@ID
GROUP BY prp.ID)

SELECT @IDOperace

BEGIN		
	SET @enigma_nr=(SELECT tppe._EXT_RS_enigma_nr
					FROM TabPrPostup_EXT tppe
					WHERE tppe.ID=@IDOperace)
	--SELECT @enigma_nr AS Enigma_old--dočasně
	IF @enigma_nr IS NULL
	BEGIN
	SET @enigma_nr_new = (SELECT (SELECT TOP 1 tppe._EXT_RS_enigma_nr
	FROM TabPrPostup_EXT tppe
	ORDER BY tppe._EXT_RS_enigma_date DESC, tppe._EXT_RS_enigma_nr DESC)+1)
	IF @enigma_nr_new = 10000 SET @enigma_nr_new=1
	--SELECT @enigma_nr_new AS Enigma_new--dočasně
	
	BEGIN TRANSACTION;
	UPDATE dbo.TabPrPostup_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_enigma_nr=@enigma_nr_new, _EXT_RS_enigma_date=GETDATE() WHERE ID=@IDOperace
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT dbo.TabPrPostup_EXT(ID, _EXT_RS_enigma_nr, _EXT_RS_enigma_date) VALUES(@IDOperace, @enigma_nr_new, GETDATE());
	END;
	COMMIT TRANSACTION;
	END;
END;
GO

