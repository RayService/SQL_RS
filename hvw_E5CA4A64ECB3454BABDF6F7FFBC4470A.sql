USE [RayService]
GO

/****** Object:  View [dbo].[hvw_E5CA4A64ECB3454BABDF6F7FFBC4470A]    Script Date: 03.07.2025 14:39:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_E5CA4A64ECB3454BABDF6F7FFBC4470A] AS SELECT
au.ID AS IDUser
,au.UserName AS UserName
,au.PasswordHash
,au.FullName
,au.IDZam
,au.Autor
,au.DatPorizeni
,au.Zmenil
,au.DatZmeny
,au.BlokovaniEditoru
,au.DatPorizeni_D
,au.DatPorizeni_M
,au.DatPorizeni_Y
,au.DatPorizeni_Q
,au.DatPorizeni_W
,au.DatPorizeni_X
,au.DatZmeny_D
,au.DatZmeny_M
,au.DatZmeny_Y
,au.DatZmeny_Q
,au.DatZmeny_W
,au.DatZmeny_X
,au.IDMaticeRoleProcesy
,tcz.Cislo AS CisloZam
,tcz.Prijmeni AS Primeni
,tcz.Jmeno AS Jmeno
,tcz.PrijmeniJmeno AS PrijmeniJmeno
,tcz.PrijmeniJmenoTituly AS PrijmeniJmenoTituly
FROM Tabx_RS_AppUsers au WITH(NOLOCK)
LEFT OUTER JOIN TabCisZam tcz WITH(NOLOCK) ON tcz.ID=au.IDZam
GO

