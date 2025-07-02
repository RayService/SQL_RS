USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlan_upd_datum]    Script Date: 02.07.2025 15:48:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--========================================================
-- Author:		MŽ
-- Description:	Nemožnost změnit datum plánu pokud kmen.středisko = 20000230100 nebo zakázka = 20226858 mimo autora gajarsky nebo tvrdy
-- Date: 16.5.2023
--18.8.2023 nainstalováno, ale po dohodě s DaG vypnuto.
--========================================================
CREATE TRIGGER [dbo].[et_TabPlan_upd_datum] ON [dbo].[TabPlan]
FOR UPDATE
AS
BEGIN
  IF UPDATE(Datum)
    IF EXISTS (SELECT * 
		FROM inserted a
		INNER JOIN TabPlan ON TabPlan.ID=a.ID
		LEFT OUTER JOIN TabZakazka tz ON tz.ID=TabPlan.IDZakazka
		WHERE
		(TabPlan.InterniZaznam=0)
		AND(((ISNULL(TabPlan.KmenoveStredisko, (SELECT ISNULL(ZMD.KmenoveStredisko,KZ.KmenoveStredisko)
												FROM TabKmenZbozi KZ
												LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=TabPlan.IDZakazModif AND ZMD.IDKmenZbozi=TabPlan.IDTabKmen) 
		WHERE KZ.ID=TabPlan.IDTabKmen)))=N'20000230100')OR(tz.CisloZakazky=N'20226858')))
		AND (SUSER_SNAME() NOT IN ('sa','gajarsky','tvrdy','zufan'))
	 BEGIN
        ROLLBACK
        RAISERROR('Změna data plánu není povolena.', 16, 1);
  	
      END
  
END
GO

ALTER TABLE [dbo].[TabPlan] DISABLE TRIGGER [et_TabPlan_upd_datum]
GO

