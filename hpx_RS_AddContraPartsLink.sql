USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AddContraPartsLink]    Script Date: 26.06.2025 13:27:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_AddContraPartsLink] @Connector INT, @PosTest INT, @ContraPartPos INT, @_EXT_RS_BranchDesc NVARCHAR(100), @ID INT
AS

--_EXT_RS_ProductConnector : Konektor výrobku - výběr z vlastní kusovníkové vazby
--_EXT_RS_TesterPosition : Pozice testeru - rolovací menu (1-50)
--_EXT_RS_ContraPartPosition : Pozice protikusu - výběr z kusovníkové vazby vloženého nářadí z označeného řádku

--dohledání ID dílce
DECLARE @IDHlavicka INT
--SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'
--SET @IDHlavicka=187492
--SET @ID=740944
--dohledání ID změny
DECLARE @IDZmena INT
SET @IDZmena = (SELECT IDZmeny FROM Tabx_RS_ContraPatrsLink WHERE SPID=@@SPID)

--vložení ID vazby z kusovníku hlavičkového výrobku do konektoru výrobku
BEGIN TRANSACTION;
UPDATE dbo.TabNvazby_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_ProductConnector = @Connector WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabNvazby_EXT(ID, _EXT_RS_ProductConnector) VALUES(@ID, @Connector);
END
COMMIT TRANSACTION;

--vložení pozice testeru
BEGIN TRANSACTION;
UPDATE dbo.TabNvazby_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_TesterPosition = @PosTest WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabNvazby_EXT(ID, _EXT_RS_TesterPosition) VALUES(@ID, @PosTest);
END
COMMIT TRANSACTION;

-- vložení ID vazby z nářadí do pozice protikusu
BEGIN TRANSACTION;
UPDATE dbo.TabNvazby_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_ContraPartPosition = @ContraPartPos WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabNvazby_EXT(ID, _EXT_RS_ContraPartPosition) VALUES(@ID, @ContraPartPos);
END
COMMIT TRANSACTION;

--vložení označení větve
BEGIN TRANSACTION;
UPDATE dbo.TabNvazby_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_BranchDesc = @_EXT_RS_BranchDesc WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabNvazby_EXT(ID, _EXT_RS_BranchDesc) VALUES(@ID, @_EXT_RS_BranchDesc);
END
COMMIT TRANSACTION;

--smazání dočasné tabule
DELETE FROM Tabx_RS_ContraPatrsLink WHERE SPID=@@SPID







GO

