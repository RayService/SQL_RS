USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_JOCTvDokl]    Script Date: 03.07.2025 9:57:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabDokladyZbozi_JOCTvDokl] ON [dbo].[TabDokladyZbozi] FOR INSERT AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @PocetInserted INT, @PocetDeleted INT
SET @PocetInserted = (SELECT COUNT(*) FROM inserted)
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted)
DECLARE @BlokovaniEditoru SMALLINT
DECLARE @ID INT
DECLARE @Uzivatel VARCHAR(128)
DECLARE @IdSklad VARCHAR(30)
DECLARE @IDStrom INT

-- INSERT
IF @PocetInserted =1 AND @PocetDeleted =0
	BEGIN
		SET @Uzivatel = SUSER_SNAME()
		SELECT @ID=ID, @BlokovaniEditoru=BlokovaniEditoru, @IDSklad = IDSklad FROM inserted
		SELECT @IDStrom=ID FROM TabStrom WHERE Cislo = @IdSklad

		IF (SELECT _RAY_HlidTvorbDokl_JOC FROM TabStrom_EXT WHERE ID =@IdStrom )= 1 AND NOT EXISTS (SELECT * FROM TabPravaSklad WHERE Cislo = @IdSklad AND LoginName= @Uzivatel)  
			BEGIN
				RAISERROR ('Nemáte právo na tomto skladě vytvořit doklad!',16,1)
				ROLLBACK /* BACHA - toto je nutné, NEZAPOMENOUT */
				RETURN
			END	
	END
 
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ENABLE TRIGGER [et_TabDokladyZbozi_JOCTvDokl]
GO

