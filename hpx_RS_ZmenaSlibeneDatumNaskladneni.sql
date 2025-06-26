USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaSlibeneDatumNaskladneni]    Script Date: 26.06.2025 15:12:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ZmenaSlibeneDatumNaskladneni]
@TypUpdate INT,
@_EXT_RS_PromisedStockingDate DATETIME,
@kontrola bit,
@ID INT
AS

--nejprve kontrola uživatelů a skladů
--Purchasing assistant=57
--Purchasing manager=20
--Sales Asistant=68
--Sales Manager=69
DECLARE @IDSklad NVARCHAR(30)
DECLARE @IDRole INT

SET @IDRole=(SELECT IDRole FROM TabUziv WHERE LoginName=SUSER_SNAME())
SET @IDSklad=(SELECT tss.IDSklad FROM TabPohybyZbozi tpz LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=tpz.IDZboSklad WHERE tpz.ID=@ID)

IF @IDSklad<>'100' AND @IDRole IN (57,20)
BEGIN
RAISERROR('Provádíte akci na nepovoleném skladu.',16,1)
RETURN
END;

IF @IDSklad NOT IN ('200','10000115') AND @IDRole IN (68,69)
BEGIN
RAISERROR('Provádíte akci na nepovoleném skladu.',16,1)
RETURN
END;

IF @kontrola = 1 AND @TypUpdate=1	--z položek

BEGIN
	UPDATE dbo.TabPohybyZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_PromisedStockingDate=@_EXT_RS_PromisedStockingDate WHERE ID = @ID;
	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT dbo.TabPohybyZbozi_EXT (ID,_EXT_RS_PromisedStockingDate)
	  VALUES (@ID,@_EXT_RS_PromisedStockingDate);
	END
END;

IF @kontrola = 1 AND @TypUpdate=2	--z dokladu
BEGIN
IF OBJECT_ID('tempdb..#Pol') IS NOT NULL DROP TABLE #Pol
CREATE TABLE #Pol (ID INT IDENTITY(1,1) NOT NULL, IDPol INT NOT NULL)
INSERT INTO #Pol (IDpol)
SELECT tpz.ID
FROM TabPohybyZbozi tpz
WHERE tpz.IDDoklad=@ID

MERGE TabPohybyZbozi_EXT AS TARGET
USING #Pol AS SOURCE
ON TARGET.ID=SOURCE.IDPol
WHEN MATCHED THEN
UPDATE SET TARGET._EXT_RS_PromisedStockingDate=@_EXT_RS_PromisedStockingDate
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_PromisedStockingDate)
VALUES (IDPol, @_EXT_RS_PromisedStockingDate);
END;
IF @kontrola=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

