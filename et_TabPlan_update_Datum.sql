USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlan_update_Datum]    Script Date: 02.07.2025 15:48:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPlan_update_Datum] ON [dbo].[TabPlan] AFTER UPDATE
AS
BEGIN
SET NOCOUNT ON;
-- =============================================================
-- Author: MŽ
-- Datum: 5.10.2020
-- Pokud se přesune plán z jednoho měsíce do jiného, založit jeho kopii v původním kvartálu s plusovou hodnotou a v novém kvartálu kopii s mínusovou hodnotou.
-- Obě kopie do řady burza.
-- Řady plánů, které se mají takto kopírovat : P_blokace, P_Freezed, P_RO, P_RO_povrz, Plan_fix, Plan_quick, PT_BD, PT_FC, PT_PlPř
-- Changed: 13.10.2020 řady plánů pouze Plan_fix
-- Changed: 30.10.2020 položka nových plánů změněna na ID = 130217
-- Changed: 18.11.2020 přidána řada plánů Plan_quick
-- =============================================================
IF UPDATE(datum)
BEGIN
DECLARE @ID INT;
DECLARE @RadaPl NVARCHAR(10);
DECLARE @NewHodnota DATETIME;
DECLARE @OldHodnota DATETIME;
DECLARE @Rozdil INT;
DECLARE @Plan1 INT;
DECLARE @Plan2 INT;
SET @ID = (SELECT TOP 1 ID FROM INSERTED);
SET @RadaPl = (SELECT TOP 1 TabPlan.Rada FROM TabPlan WHERE ID = @ID)
SET @NewHodnota = (SELECT (CONVERT(DATETIME,NewHodnota,121))
FROM GTabLogovaneInformace tzlog WITH(NOLOCK)
WHERE tzlog.IDZaznam = @ID AND tzlog.SysNazevTabulka LIKE N'TabPlan%' AND tzlog.SysNazevAtribut LIKE N'datum%' AND tzlog.Akce=1 AND tzlog.DatPorizeni = 
(SELECT TOP 1 tzlog.DatPorizeni FROM GTabLogovaneInformace tzlog WITH(NOLOCK)
WHERE tzlog.IDZaznam = @ID AND tzlog.SysNazevTabulka LIKE N'TabPlan%' AND tzlog.SysNazevAtribut LIKE N'datum%' AND tzlog.Akce=1 ORDER BY tzlog.DatPorizeni DESC))
SET @OldHodnota = (SELECT (CONVERT(DATETIME,OldHodnota,121))
FROM GTabLogovaneInformace tzlog WITH(NOLOCK)
WHERE tzlog.IDZaznam = @ID AND tzlog.SysNazevTabulka LIKE N'TabPlan%' AND tzlog.SysNazevAtribut LIKE N'datum%' AND tzlog.Akce=1 AND tzlog.DatPorizeni = 
(SELECT TOP 1 tzlog.DatPorizeni FROM GTabLogovaneInformace tzlog WITH(NOLOCK)
WHERE tzlog.IDZaznam = @ID AND tzlog.SysNazevTabulka LIKE N'TabPlan%' AND tzlog.SysNazevAtribut LIKE N'datum%' AND tzlog.Akce=1 ORDER BY tzlog.DatPorizeni DESC))
SET @Rozdil = (DATEPART(QUARTER,CAST(@NewHodnota AS DATETIME))) - (DATEPART(QUARTER,CAST(@OldHodnota AS DATETIME)))
IF (@Rozdil <> 0 AND @RadaPl IN ('Plan_fix','Plan_quick'))
BEGIN
UPDATE TabPlan_EXT SET _EXT_RS_mnozstvi_obchod = tpold.mnozstvi
FROM TabPlan tpold
LEFT OUTER JOIN TabPlan_EXT tpolde ON tpolde.ID = tpold.ID
WHERE tpolde.ID = @ID
INSERT INTO TabPlan (uzavreno, Rada, datum, IDTabKmen, IDZakazka, mnozstvi, TypProvedeneKorekcePozadavku, mnozPrev, InterniZaznam,NavaznaObjednavka)
SELECT 0,N'PT_Burza',@OldHodnota,130217,tpold.IDZakazka,tpold.mnozstvi,0,0,0, tpold.NavaznaObjednavka
FROM TabPlan tpold
WHERE tpold.ID = @ID
SELECT SCOPE_IDENTITY()
SET @Plan1 = SCOPE_IDENTITY()
INSERT INTO TabPlan_EXT (ID, _EXT_RS_mnozstvi_obchod, _EXT_RS_ID_plan_presun)
SELECT @Plan1, tpl.mnozstvi, @ID
FROM TabPlan tpl
WHERE tpl.Id = @ID
/*INSERT INTO TabPlanZdrojOZ (IDPlan, IDRezervace)
SELECT @Plan1, tpl.IDRezervace
FROM TabPlan tpl
WHERE tpl.ID = @Plan1*/
INSERT INTO TabPlan (uzavreno, Rada, datum, IDTabKmen, IDZakazka, mnozstvi, TypProvedeneKorekcePozadavku, mnozPrev, InterniZaznam,NavaznaObjednavka)
SELECT 0,N'PT_Burza',@NewHodnota,130217,tpold.IDZakazka,tpold.mnozstvi,0,0,0, tpold.NavaznaObjednavka
FROM TabPlan tpold
WHERE tpold.ID = @ID
SELECT SCOPE_IDENTITY()
SET @Plan2 = SCOPE_IDENTITY()
INSERT INTO TabPlan_EXT (ID, _EXT_RS_mnozstvi_obchod, _EXT_RS_ID_plan_presun)
SELECT @Plan2, tpl.mnozstvi * (-1), @ID
FROM TabPlan tpl
WHERE tpl.Id = @ID
/*INSERT INTO TabPlanZdrojOZ (IDPlan, IDRezervace)
SELECT @Plan2, tpl.IDRezervace
FROM TabPlan tpl
WHERE tpl.ID = @Plan2*/
END;
END;
END;
GO

ALTER TABLE [dbo].[TabPlan] DISABLE TRIGGER [et_TabPlan_update_Datum]
GO

