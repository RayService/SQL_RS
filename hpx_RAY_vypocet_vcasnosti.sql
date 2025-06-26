USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_vypocet_vcasnosti]    Script Date: 26.06.2025 10:03:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_vypocet_vcasnosti] @ID INT

AS

DECLARE @datum DATETIME
DECLARE @interval_prvotne INT
DECLARE @interval_potvrzeno INT
DECLARE @interval_pozadovano INT

SELECT @datum = (SELECT tdz.DatPorizeni FROM TabDokladyZbozi tdz JOIN TabPohybyZbozi tpz ON tpz.IDDoklad = tdz.ID JOIN TabPohybyZbozi_EXT tpze ON tpze.ID = tpz.ID WHERE tpz.ID = @ID)
SELECT @interval_prvotne = (SELECT DATEDIFF(d,@datum,tpze._dat_dod1) FROM TabPohybyZbozi_EXT tpze JOIN TabPohybyZbozi tpz ON tpz.ID = tpze.ID WHERE tpz.ID = @ID)
SELECT @interval_potvrzeno = (SELECT DATEDIFF(d,@datum,tpz.PotvrzDatDod) FROM TabPohybyZbozi tpz JOIN TabPohybyZbozi_EXT tpze ON tpze.ID = tpz.ID WHERE tpz.ID =@ID)
SELECT @interval_pozadovano = (SELECT DATEDIFF(d,@datum,tpz.PozadDatDod) FROM TabPohybyZbozi tpz JOIN TabPohybyZbozi_EXT tpze ON tpze.ID = tpz.ID WHERE tpz.ID =@ID)

IF @interval_prvotne BETWEEN 0 AND 30
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'A'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne BETWEEN -7 AND -1
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'B'
WHERE TabPohybyZbozi_EXT.ID = @ID
 
IF @interval_prvotne > 31
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'B'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne BETWEEN -14 AND -8
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'C'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne <= -15
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'D'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno BETWEEN 0 AND 30
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'A'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno BETWEEN -7 AND -1
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'B'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno > 31
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'B'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno BETWEEN -14 AND -8
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'C'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno <= -15
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'D'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno IS NULL AND @interval_pozadovano BETWEEN 0 AND 30
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'A'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno IS NULL AND @interval_pozadovano BETWEEN -7 AND -1
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'B'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno IS NULL AND @interval_pozadovano > 31
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'B'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno IS NULL AND @interval_pozadovano BETWEEN -14 AND -8
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'C'
WHERE TabPohybyZbozi_EXT.ID = @ID

IF @interval_prvotne IS NULL AND @interval_potvrzeno IS NULL AND @interval_pozadovano <= -15
UPDATE TabPohybyZbozi_EXT SET TabPohybyZbozi_EXT._vcasnost = 'D'
WHERE TabPohybyZbozi_EXT.ID = @ID
GO

