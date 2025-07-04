USE [RayService]
GO

/****** Object:  View [dbo].[TabZajistKryEditorView]    Script Date: 04.07.2025 13:03:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabZajistKryEditorView] AS
SELECT Z.ID                                 AS ID,
Z.DruhZajDok                         AS DruhZajDok,
R.Mnozstvi                           AS MnozDObj,
R.MnozstviRealVydej                  AS MnozVyd,
Z.MnResit                            AS MnozResit,
CAST(R.Mnozstvi * R.PrepMnozstvi AS NUMERIC(19,6)) AS MnozDObjE,
CAST(R.MnozstviRealVydej * R.PrepMnozstvi AS NUMERIC(19,6)) AS MnozVydE,
Z.MnResitEvid                        AS MnozResitE,
K.ID                                 AS KID,
R.IDZboSklad                         AS SID,
R.MJ                                 AS RMJ,
K.MJEvidence                         AS EMJ
FROM TabZajistX           AS Z
JOIN TabDosleObjR02     AS R ON R.ID = Z.IDDObjR02
JOIN TabStavSkladu      AS S ON S.ID = R.IDZboSklad
JOIN TabKmenZbozi       AS K ON K.ID = S.IDKmenZbozi
UNION
SELECT Z.ID AS ID,
Z.DruhZajDok       AS DruhZajDok,
umz.Mnozstvi       AS MnozDObj,
umz.VydaneMnozstvi AS MnozVyd,
Z.MnResit          AS MnozResit,
CAST(umz.Mnozstvi       * CASE ISNULL(umz.PrepocetMnozstvi, 0) WHEN 0 THEN 1 ELSE umz.PrepocetMnozstvi END AS NUMERIC(19,6)) AS MnozDObjE,
CAST(umz.VydaneMnozstvi * CASE ISNULL(umz.PrepocetMnozstvi, 0) WHEN 0 THEN 1 ELSE umz.PrepocetMnozstvi END AS NUMERIC(19,6)) AS MnozVydE,
Z.MnResitEvid      AS MnozResitE,
K.ID               AS KID,
S.ID               AS SID,
umz.MJ             AS RMJ,
K.MJEvidence       AS EMJ
FROM TabZajistX             AS Z
JOIN TabGprUlohyMatZdroje AS umz ON umz.ID = z.IDGPrUMZ
JOIN TabStavSkladu        AS S ON S.IDSklad = umz.Sklad AND S.IDKmenZbozi = umz.IDMatZdroje
JOIN TabKmenZbozi         AS K ON K.ID = S.IDKmenZbozi
UNION
SELECT Z.ID AS ID,
Z.DruhZajDok       AS DruhZajDok,
ISNULL(PRK.mnoz_pozadovane, 0) AS MnozDObj,
CAST((PRK.mnoz_pozadovane - PRK.mnoz_Nevydane) AS NUMERIC(19,6)) AS MnozVyd,
Z.MnResit          AS MnozResit,
CAST((PRK.mnoz_pozadovane * 1) AS NUMERIC(19,6)) AS MnozDObjE,
CAST(((PRK.mnoz_pozadovane - PRK.mnoz_Nevydane) * 1) AS NUMERIC(19,6)) AS MnozVydE,
Z.MnResitEvid      AS MnozResitE,
K.ID               AS KID,
S.ID               AS SID,
K.MJEvidence       AS RMJ,
K.MJEvidence       AS EMJ
FROM TabZajistX           AS Z
JOIN TabPrKVazby        AS PRK ON PRK.ID1 = z.IDPrKVaz AND PRK.IDOdchylkyDo IS NULL
JOIN TabStavSkladu      AS S ON S.IDSklad = PRK.Sklad AND S.IDKmenZbozi = PRK.Nizsi
JOIN TabKmenZbozi       AS K ON K.ID = S.IDKmenZbozi AND ((K.Material = 1) OR ((K.Dilec = 1) AND (SELECT PovolitZajisteniDilcu FROM TabHGlob) = 1))
GO

