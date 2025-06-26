USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_DetailniZmenyKusVazeb]    Script Date: 26.06.2025 13:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_DetailniZmenyKusVazeb]
AS

--detailní seznam změn nad konkrétní změnou, s oblastí 110=Kusovníkové vazby
--USE RayService

DECLARE @ID INT, @Oblast int, @IDZmeny int, @DatumPlatnosti datetime 
--nejprve vymažu předchozí uložené hodnoty
DELETE  FROM  Tabx_RS_DetailZmenyZmenRizeni
--pak kurzorem napočtu nové hodnoty
DECLARE CurDetZmeny CURSOR LOCAL FAST_FORWARD FOR
SELECT TabCzmeny.ID
FROM TabCzmeny
WHERE (TabCzmeny.datumNastaveni_X>=GETDATE()-365/* AND (TabCzmeny.datumNastaveni_M>=5 AND TabCzmeny.datumNastaveni_M<=6)*/)
--(DATEADD(DAY,0,DATEDIFF(DAY,0,TabCzmeny.datumNastaveni))=DATEADD(DAY,0,DATEDIFF(DAY,0,GETDATE())))

OPEN CurDetZmeny;
	FETCH NEXT FROM CurDetZmeny INTO @ID;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

SELECT @Oblast=110, @IDZmeny=@ID, @DatumPlatnosti=NULL 
SELECT @DatumPlatnosti=Datum_X FROM TabCZmeny WHERE ID=@IDZmeny AND Platnost=1 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, TypZmeny, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV.nizsi, NULL, KV.ID, 3, 
LEFT(REPLACE(REPLACE(N'Zrušení kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV.nizsi)), 255) 
        FROM TabKvazby KV 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV.IDVarianta))
        WHERE KV.ZmenaDo=@IDZmeny AND 
              NOT EXISTS(SELECT * FROM TabKvazby KV2 WHERE KV2.ID1=KV.ID1 AND KV2.ZmenaOd=@IDZmeny) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, TypZmeny, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV.nizsi, NULL, KV.ID, 2, 
LEFT(REPLACE(REPLACE(N'Nová kusovníková vazba - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV.nizsi)), 255) 
        FROM TabKvazby KV 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV.IDVarianta))
        WHERE KV.ZmenaOd=@IDZmeny AND 
              NOT EXISTS(SELECT * FROM TabKvazby KV2 WHERE KV2.ID1=KV.ID1 AND KV2.ZmenaDo=@IDZmeny) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Globální',128), 0, convert(nvarchar(255), KV_O.globalni), convert(nvarchar(255), KV_N.globalni), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.globalni, 0) <> ISNULL(KV_N.globalni, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Položka',128), 0, convert(nvarchar(255), (SELECT I.SkupZbo+N' '+I.RegCis+N' '+I.nazev1 FROM TabKmenZbozi I WHERE I.ID=KV_O.nizsi)), convert(nvarchar(255), (SELECT I.SkupZbo+N' '+I.RegCis+N' '+I.nazev1 FROM TabKmenZbozi I WHERE I.ID=KV_N.nizsi)), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.nizsi, 0) <> ISNULL(KV_N.nizsi, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Pozice',128), 0, convert(nvarchar(255), KV_O.pozice), convert(nvarchar(255), KV_N.pozice), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.pozice, '') <> ISNULL(KV_N.pozice, '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Operace',128), 0, convert(nvarchar(255), KV_O.Operace), convert(nvarchar(255), KV_N.Operace), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.Operace, '') <> ISNULL(KV_N.Operace, '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Fixní množství',128), 0, convert(nvarchar(255), KV_O.FixniMnozstvi), convert(nvarchar(255), KV_N.FixniMnozstvi), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.FixniMnozstvi, 0.0) <> ISNULL(KV_N.FixniMnozstvi, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Množství',128), 0, convert(nvarchar(255), KV_O.mnozstvi), convert(nvarchar(255), KV_N.mnozstvi), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.mnozstvi, 0.0) <> ISNULL(KV_N.mnozstvi, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'% ztrát',128), 0, convert(nvarchar(255), KV_O.ProcZtrat), convert(nvarchar(255), KV_N.ProcZtrat), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.ProcZtrat, 0.0) <> ISNULL(KV_N.ProcZtrat, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Množství se ztrátou',128), 0, convert(nvarchar(255), KV_O.mnozstviSeZtratou), convert(nvarchar(255), KV_N.mnozstviSeZtratou), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.mnozstviSeZtratou, 0.0) <> ISNULL(KV_N.mnozstviSeZtratou, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Počet kusů z přířezu',128), 0, convert(nvarchar(255), KV_O.Prirez), convert(nvarchar(255), KV_N.Prirez), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.Prirez, 0.0) <> ISNULL(KV_N.Prirez, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Spotřební rozměr',128), 0, convert(nvarchar(255), KV_O.SpotRozmer), convert(nvarchar(255), KV_N.SpotRozmer), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.SpotRozmer, '') <> ISNULL(KV_N.SpotRozmer, '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Výchozí sklad pro výdej do výroby',128), 0, convert(nvarchar(255), KV_O.VychoziSklad), convert(nvarchar(255), KV_N.VychoziSklad), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.VychoziSklad, '') <> ISNULL(KV_N.VychoziSklad, '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Režijní položka',128), 0, convert(nvarchar(255), KV_O.RezijniMat), convert(nvarchar(255), KV_N.RezijniMat), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.RezijniMat, 0) <> ISNULL(KV_N.RezijniMat, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Vyřadit z kalkulace',128), 0, convert(nvarchar(255), KV_O.VyraditZKalkulace), convert(nvarchar(255), KV_N.VyraditZKalkulace), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.VyraditZKalkulace, 0) <> ISNULL(KV_N.VyraditZKalkulace, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Poznámka',128), 0, convert(nvarchar(255), KV_O.Poznamka), convert(nvarchar(255), KV_N.Poznamka), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(convert(nvarchar(max),KV_O.poznamka), '') <> ISNULL(convert(nvarchar(max),KV_N.poznamka), '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Vzorec pro výpočet spotřeby materiálů',128), 0, convert(nvarchar(255), (SELECT I.Kod+N' '+ISNULL(I.nazev,'') FROM TabCVzorcuSpotMat I WHERE I.ID=KV_O.IDVzorceSpotMat)), convert(nvarchar(255), (SELECT I.Kod+N' '+ISNULL(I.nazev,'') FROM TabCVzorcuSpotMat I WHERE I.ID=KV_N.IDVzorceSpotMat)), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.IDVzorceSpotMat, 0) <> ISNULL(KV_N.IDVzorceSpotMat, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- A - ',128), 0, convert(nvarchar(255), KV_O.PromA), convert(nvarchar(255), KV_N.PromA), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromA, 0.0) <> ISNULL(KV_N.PromA, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- B - ',128), 0, convert(nvarchar(255), KV_O.PromB), convert(nvarchar(255), KV_N.PromB), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromB, 0.0) <> ISNULL(KV_N.PromB, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- C - ',128), 0, convert(nvarchar(255), KV_O.PromC), convert(nvarchar(255), KV_N.PromC), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromC, 0.0) <> ISNULL(KV_N.PromC, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- D - ',128), 0, convert(nvarchar(255), KV_O.PromD), convert(nvarchar(255), KV_N.PromD), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromD, 0.0) <> ISNULL(KV_N.PromD, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- E - ',128), 0, convert(nvarchar(255), KV_O.PromE), convert(nvarchar(255), KV_N.PromE), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromE, 0.0) <> ISNULL(KV_N.PromE, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'63A7C565-6D48-4543-BB72-3AEED36917A8',128), 1, convert(nvarchar(255), KV_Ext_O._EXT_RS_item_time), convert(nvarchar(255), KV_Ext_N._EXT_RS_item_time), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          LEFT OUTER JOIN TabKvazby_Ext KV_Ext_N ON (KV_Ext_N.ID=KV_N.ID) 
          LEFT OUTER JOIN TabKvazby_Ext KV_Ext_O ON (KV_Ext_O.ID=KV_O.ID) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(convert(nvarchar(max),KV_Ext_O._EXT_RS_item_time), '') <> ISNULL(convert(nvarchar(max),KV_Ext_N._EXT_RS_item_time), '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, NULL, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Procesní vazba',128), 1, convert(nvarchar(255), KV_Ext_O._ProcVaz), convert(nvarchar(255), KV_Ext_N._ProcVaz), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(KV_N.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabKvazby KV_N 
          INNER JOIN TabKvazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          LEFT OUTER JOIN TabKvazby_Ext KV_Ext_N ON (KV_Ext_N.ID=KV_N.ID) 
          LEFT OUTER JOIN TabKvazby_Ext KV_Ext_O ON (KV_Ext_O.ID=KV_O.ID) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(convert(nvarchar(max),KV_Ext_O._ProcVaz), '') <> ISNULL(convert(nvarchar(max),KV_Ext_N._ProcVaz), '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, TypZmeny, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV.nizsi, PKV.ID, KV.ID, 3, 
LEFT(REPLACE(REPLACE(N'Zrušení alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV.nizsi)), 255) 
        FROM TabAltKVazby KV 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV.ZmenaDo=@IDZmeny AND 
              NOT EXISTS(SELECT * FROM TabAltKVazby KV2 WHERE KV2.ID1=KV.ID1 AND KV2.ZmenaOd=@IDZmeny) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, TypZmeny, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV.nizsi, PKV.ID, KV.ID, 2, 
LEFT(REPLACE(REPLACE(N'Nová alternativní kusovníková vazba - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV.nizsi)), 255) 
        FROM TabAltKVazby KV 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV.ZmenaOd=@IDZmeny AND 
              NOT EXISTS(SELECT * FROM TabAltKVazby KV2 WHERE KV2.ID1=KV.ID1 AND KV2.ZmenaDo=@IDZmeny) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Položka',128), 0, convert(nvarchar(255), (SELECT I.SkupZbo+N' '+I.RegCis+N' '+I.nazev1 FROM TabKmenZbozi I WHERE I.ID=KV_O.nizsi)), convert(nvarchar(255), (SELECT I.SkupZbo+N' '+I.RegCis+N' '+I.nazev1 FROM TabKmenZbozi I WHERE I.ID=KV_N.nizsi)), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.nizsi, 0) <> ISNULL(KV_N.nizsi, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Priorita',128), 0, convert(nvarchar(255), KV_O.Priorita), convert(nvarchar(255), KV_N.Priorita), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.Priorita, 0) <> ISNULL(KV_N.Priorita, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Fixní množství',128), 0, convert(nvarchar(255), KV_O.FixniMnozstvi), convert(nvarchar(255), KV_N.FixniMnozstvi), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.FixniMnozstvi, 0.0) <> ISNULL(KV_N.FixniMnozstvi, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Množství',128), 0, convert(nvarchar(255), KV_O.mnozstvi), convert(nvarchar(255), KV_N.mnozstvi), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.mnozstvi, 0.0) <> ISNULL(KV_N.mnozstvi, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'% ztrát',128), 0, convert(nvarchar(255), KV_O.ProcZtrat), convert(nvarchar(255), KV_N.ProcZtrat), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.ProcZtrat, 0.0) <> ISNULL(KV_N.ProcZtrat, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Množství se ztrátou',128), 0, convert(nvarchar(255), KV_O.mnozstviSeZtratou), convert(nvarchar(255), KV_N.mnozstviSeZtratou), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.mnozstviSeZtratou, 0.0) <> ISNULL(KV_N.mnozstviSeZtratou, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Počet kusů z přířezu',128), 0, convert(nvarchar(255), KV_O.Prirez), convert(nvarchar(255), KV_N.Prirez), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.Prirez, 0.0) <> ISNULL(KV_N.Prirez, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Spotřební rozměr',128), 0, convert(nvarchar(255), KV_O.SpotRozmer), convert(nvarchar(255), KV_N.SpotRozmer), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.SpotRozmer, '') <> ISNULL(KV_N.SpotRozmer, '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Výchozí sklad pro výdej do výroby',128), 0, convert(nvarchar(255), KV_O.VychoziSklad), convert(nvarchar(255), KV_N.VychoziSklad), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.VychoziSklad, '') <> ISNULL(KV_N.VychoziSklad, '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Režijní položka',128), 0, convert(nvarchar(255), KV_O.RezijniMat), convert(nvarchar(255), KV_N.RezijniMat), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.RezijniMat, 0) <> ISNULL(KV_N.RezijniMat, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Vyřadit z kalkulace',128), 0, convert(nvarchar(255), KV_O.VyraditZKalkulace), convert(nvarchar(255), KV_N.VyraditZKalkulace), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.VyraditZKalkulace, 0) <> ISNULL(KV_N.VyraditZKalkulace, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Poznámka',128), 0, convert(nvarchar(255), KV_O.Poznamka), convert(nvarchar(255), KV_N.Poznamka), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(convert(nvarchar(max),KV_O.poznamka), '') <> ISNULL(convert(nvarchar(max),KV_N.poznamka), '') 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'Vzorec pro výpočet spotřeby materiálů',128), 0, convert(nvarchar(255), (SELECT I.Kod+N' '+ISNULL(I.nazev,'') FROM TabCVzorcuSpotMat I WHERE I.ID=KV_O.IDVzorceSpotMat)), convert(nvarchar(255), (SELECT I.Kod+N' '+ISNULL(I.nazev,'') FROM TabCVzorcuSpotMat I WHERE I.ID=KV_N.IDVzorceSpotMat)), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.IDVzorceSpotMat, 0) <> ISNULL(KV_N.IDVzorceSpotMat, 0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- A - ',128), 0, convert(nvarchar(255), KV_O.PromA), convert(nvarchar(255), KV_N.PromA), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromA, 0.0) <> ISNULL(KV_N.PromA, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- B - ',128), 0, convert(nvarchar(255), KV_O.PromB), convert(nvarchar(255), KV_N.PromB), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromB, 0.0) <> ISNULL(KV_N.PromB, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- C - ',128), 0, convert(nvarchar(255), KV_O.PromC), convert(nvarchar(255), KV_N.PromC), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromC, 0.0) <> ISNULL(KV_N.PromC, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- D - ',128), 0, convert(nvarchar(255), KV_O.PromD), convert(nvarchar(255), KV_N.PromD), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromD, 0.0) <> ISNULL(KV_N.PromD, 0.0) 
INSERT INTO Tabx_RS_DetailZmenyZmenRizeni(IDZmeny, Oblast, Vyssi, nizsi, IDParentVazby, IDVazbyOld, IDVazbyNew, TypZmeny, Atribut, ExtAtribut, OldValue, NewValue, PopisZmeny) 
      SELECT @IDZmeny, 110, KZV.ID, KV_N.nizsi, PKV.ID, KV_O.ID, KV_N.ID, 1, 
             LEFT(N'- E - ',128), 0, convert(nvarchar(255), KV_O.PromE), convert(nvarchar(255), KV_N.PromE), 
LEFT(REPLACE(REPLACE(N'Změna hodnoty alternativní kusovníkové vazby - Pozice: %s1 Položka: %s2',N'%s1',LTRIM(ISNULL(PKV.Pozice,''))), N'%s2', (SELECT KZN.SkupZbo+N' '+KZN.RegCis+N' '+KZN.nazev1 FROM TabKmenZbozi KZN WHERE KZN.ID=KV_N.nizsi)), 255) 
        FROM TabAltKVazby KV_N 
          INNER JOIN TabAltKVazby KV_O ON (KV_O.ID1=KV_N.ID1 AND KV_O.ZmenaDo=@IDZmeny) 
          INNER JOIN TabKmenZbozi KZV ON (KZV.IDKusovnik=KV_N.vyssi AND (KV_N.IDVarianta IS NULL AND KZV.ShodaId=1 OR KZV.IDVarianta=KV_N.IDVarianta))
          INNER JOIN TabKVazby PKV ON (PKV.ID1=KV_N.KV_ID1 AND 
                                        (@DatumPlatnosti IS NULL AND PKV.ZmenaOd=@IDZmeny OR 
                                         @DatumPlatnosti IS NOT NULL AND EXISTS(SELECT * FROM tabczmeny ZodPKV  
                                                                                   LEFT OUTER JOIN tabczmeny ZdoPKV ON (ZDoPKV.ID=PKV.zmenaDo) 
                                                                                 WHERE ZodPKV.ID=PKV.zmenaOd AND ZodPKV.platnost=1 AND @DatumPlatnosti>=ZodPKV.datum AND 
                                                                                       (PKV.ZmenaDo IS NULL OR ZdoPKV.platnost=0 OR (ZDoPKV.platnost=1 AND @DatumPlatnosti<ZDoPKV.datum))) 
                                        )) 
        WHERE KV_N.ZmenaOd=@IDZmeny AND 
              ISNULL(KV_O.PromE, 0.0) <> ISNULL(KV_N.PromE, 0.0)



	  	FETCH NEXT FROM CurDetZmeny INTO @ID;
	END;
CLOSE CurDetZmeny;
DEALLOCATE CurDetZmeny;


SELECT ZR.*, tkz.SkupZbo, tkz.RegCis, tkz.Nazev1
FROM Tabx_RS_DetailZmenyZmenRizeni ZR
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=ZR.nizsi
GO

