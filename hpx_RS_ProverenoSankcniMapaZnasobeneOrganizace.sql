USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ProverenoSankcniMapaZnasobeneOrganizace]    Script Date: 30.06.2025 8:31:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ProverenoSankcniMapaZnasobeneOrganizace]
AS
SET NOCOUNT ON;

--hromadně doplnit TabCisOrg._EXT_RS_ProvereniSankcniMapa u duplicitních názvů organizací - vzít nejstarší, proceduru uložit do HEO na ext.akci - právo: hrbacova, pavlisova
WITH Sankce AS (
SELECT tco.ID AS ID, tco.Nazev AS Nazev, MIN(tcoe._EXT_RS_ProvereniSankcniMapa) OVER (PARTITION BY tco.Nazev) AS DatProvereni--, tco2.ID, tco2.Nazev
FROM TabCisOrg tco
LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg tco2 ON tco2.Nazev=tco.Nazev
LEFT OUTER JOIN TabCisOrg_EXT tcoe2 ON tcoe2.ID=tco2.ID
WHERE tcoe._EXT_RS_ProvereniSankcniMapa IS NOT NULL AND tcoe2._EXT_RS_ProvereniSankcniMapa IS NULL
--AND(tco.Nazev='ARGOS ELEKTRO, a.s.')
)
UPDATE tcoe2 SET tcoe2._EXT_RS_ProvereniSankcniMapa=Sankce.DatProvereni
FROM Sankce
LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=Sankce.ID
LEFT OUTER JOIN TabCisOrg tco2 ON tco2.Nazev=Sankce.Nazev
LEFT OUTER JOIN TabCisOrg_EXT tcoe2 ON tcoe2.ID=tco2.ID
WHERE tcoe._EXT_RS_ProvereniSankcniMapa IS NOT NULL AND tcoe2._EXT_RS_ProvereniSankcniMapa IS NULL
AND tco2.Nazev=Sankce.Nazev
--AND(tco2.Nazev='ARGOS ELEKTRO, a.s.')

--ORDER BY tco2.Nazev ASC


GO

