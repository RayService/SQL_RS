USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hp_hpx_EDI_NajdiNavazneDokladyOZ]    Script Date: 26.06.2025 9:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpNahradniPlneni.pcn_NahradniPlneni*/CREATE PROCEDURE [dbo].[hp_hpx_EDI_NajdiNavazneDokladyOZ]
@IdPocatecni INT,
@IdExpedaku INT OUT,
@IdVydejky INT OUT,
@IdFaktury INT OUT,
@Selectem BIT=0
AS
SET NOCOUNT ON
DECLARE @IdAktualni INT,@IdNavazne INT,@DpAktualni INT
SET @IdAktualni=@IdPocatecni
SET @IdFaktury=-1
SET @IdExpedaku=-1
SET @IdVydejky=-1
SELECT @DpAktualni=DruhPohybuZbo FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF(@DpAktualni=13)
SET @IdFaktury=@IdAktualni
IF(@DpAktualni=9)
SET @IdExpedaku=@IdAktualni
IF(@DpAktualni=2)OR(@DpAktualni=4)
SET @IdVydejky=@IdAktualni
SET @DpAktualni=-1
SELECT @IdNavazne=NavaznyDoklad FROM TabDokladyZbozi WHERE Id=@IdAktualni
WHILE 1=1
BEGIN
IF EXISTS(SELECT 1 FROM TabDokladyZbozi WHERE(NavaznyDoklad=@IdAktualni))
BEGIN
SELECT @IdAktualni=Id,@DpAktualni=DruhPohybuZbo
FROM TabDokladyZbozi WHERE(NavaznyDoklad=@IdAktualni)
IF(@DpAktualni=13)AND(@IdFaktury<1)
SELECT @IdFaktury=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF(@DpAktualni=9)AND(@IdExpedaku<1)
SELECT @IdExpedaku=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF((@DpAktualni=2)OR(@DpAktualni=4))AND(@IdVydejky<1)
SELECT @IdVydejky=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
END
ELSE
IF EXISTS(SELECT 1 FROM TabPohybyZbozi
WHERE IdOldPolozka IS NOT NULL AND(IdDoklad=@IdAktualni))AND
EXISTS(SELECT 1 FROM TabPohybyZbozi WHERE Id=(SELECT TOP 1 IdOldPolozka FROM TabPohybyZbozi
WHERE IdOldPolozka IS NOT NULL AND(IdDoklad=@IdAktualni)))
BEGIN
SET @IdNavazne=@IdAktualni
SELECT TOP 1 @IdAktualni=IdDoklad,@DpAktualni=DruhPohybuZbo
FROM TabPohybyZbozi
WHERE Id IN(SELECT IdOldPolozka FROM TabPohybyZbozi WHERE IdOldPolozka IS NOT NULL AND(IdDoklad=@IdNavazne))
IF(@DpAktualni=13)AND(@IdFaktury<1)
SELECT @IdFaktury=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF(@DpAktualni=9)AND(@IdExpedaku<1)
SELECT @IdExpedaku=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF((@DpAktualni=2)OR(@DpAktualni=4))AND(@IdVydejky<1)
SELECT @IdVydejky=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
END
ELSE
BEGIN
SET @IdAktualni=@IdPocatecni
SELECT @IdNavazne=NavaznyDoklad
FROM TabDokladyZbozi WHERE Id=@IdAktualni
BREAK
END
END
IF(@IdExpedaku<1)OR(@IdVydejky<1)OR(@IdFaktury<1)
WHILE 1=1
BEGIN
IF @IdNavazne IS NOT NULL AND
EXISTS(SELECT 1 FROM TabDokladyZbozi WHERE(Id=@IdNavazne))
BEGIN
SET @IdAktualni=@IdNavazne
SELECT @IdNavazne=NavaznyDoklad,@DpAktualni=DruhPohybuZbo
FROM TabDokladyZbozi WHERE(Id=@IdAktualni)
IF(@DpAktualni=13)AND(@IdFaktury<1)
SELECT @IdFaktury=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF(@DpAktualni=9)AND(@IdExpedaku<1)
SELECT @IdExpedaku=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF((@DpAktualni=2)OR(@DpAktualni=4))AND(@IdVydejky<1)
SELECT @IdVydejky=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
END
ELSE
BEGIN
IF EXISTS(SELECT 1 FROM TabPohybyZbozi WHERE IdOldPolozka IN(SELECT Id FROM TabPohybyZbozi WHERE(IdDoklad=@IdAktualni)))
BEGIN
SELECT TOP 1 @IdAktualni=IdDoklad,@DpAktualni=DruhPohybuZbo
FROM TabPohybyZbozi
WHERE IdOldPolozka IN(SELECT Id FROM TabPohybyZbozi WHERE(IdDoklad=@IdAktualni))
IF(@DpAktualni=13)AND(@IdFaktury<1)
SELECT @IdFaktury=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF(@DpAktualni=9)AND(@IdExpedaku<1)
SELECT @IdExpedaku=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
IF((@DpAktualni=2)OR(@DpAktualni=4))AND(@IdVydejky<1)
SELECT @IdVydejky=Id FROM TabDokladyZbozi WHERE Id=@IdAktualni
END
ELSE
BREAK
END
END
IF(@IdExpedaku>0)AND(@IdVydejky<1)
BEGIN
SET @IdAktualni=@IdExpedaku
SELECT @IdNavazne=NavaznyDoklad FROM TabDokladyZbozi WHERE(Id=@IdAktualni)
IF @IdNavazne IS NOT NULL AND
EXISTS(SELECT 1 FROM TabDokladyZbozi WHERE(Id=@IdNavazne)AND((DruhPohybuZbo=2)OR(DruhPohybuZbo=4)))
SET @IdVydejky=@IdNavazne
ELSE
IF EXISTS(SELECT 1 FROM TabPohybyZbozi WHERE IdOldPolozka
IN(SELECT Id FROM TabPohybyZbozi WHERE(IdDoklad=@IdAktualni))AND((DruhPohybuZbo=2)OR(DruhPohybuZbo=4)))
SELECT TOP 1 @IdVydejky=IdDoklad
FROM TabPohybyZbozi
WHERE IdOldPolozka IN(SELECT Id FROM TabPohybyZbozi WHERE(IdDoklad=@IdAktualni))AND((DruhPohybuZbo=2)OR(DruhPohybuZbo=4))
END
IF(@IdExpedaku>0)AND(@IdFaktury<1)
BEGIN
SET @IdAktualni=@IdExpedaku
SELECT @IdNavazne=NavaznyDoklad FROM TabDokladyZbozi WHERE(Id=@IdAktualni)
IF @IdNavazne IS NOT NULL AND
EXISTS(SELECT 1 FROM TabDokladyZbozi WHERE(Id=@IdNavazne)AND(DruhPohybuZbo=13))
SET @IdFaktury=@IdNavazne
ELSE
IF EXISTS(SELECT 1 FROM TabPohybyZbozi WHERE IdOldPolozka
IN(SELECT Id FROM TabPohybyZbozi WHERE(IdDoklad=@IdAktualni))AND(DruhPohybuZbo=13))
SELECT TOP 1 @IdFaktury=IdDoklad
FROM TabPohybyZbozi
WHERE IdOldPolozka IN(SELECT Id FROM TabPohybyZbozi WHERE(IdDoklad=@IdAktualni))AND(DruhPohybuZbo=13)
END
IF @Selectem=1
SELECT @IdExpedaku,@IdVydejky,@IdFaktury
GO

