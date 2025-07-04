USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_LezakyUser]    Script Date: 04.07.2025 7:22:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_LezakyUser] AS SELECT
ROW_NUMBER() OVER(ORDER BY  ISNULL(U.LoginName,SUSER_SNAME()), ISNULL(U.IDStavSkladu,L.ID)) as ID
,U.ID as IDLezakyUser
,ISNULL(U.IDStavSkladu,L.ID) as IDStavSkladu
,S.IDSklad
,U.LoginName
,U.M
,U.S
,U.A
,M_PS
,M_Vydej
,U.DatumDo
,(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,U.DatumDo)))) as DatumDo_X
,U.PocetMesicu
,U.ProcentoVydej
,U.Podminky
,U.Autor
,U.Datum
FROM Tabx_RayService_LezakyUser U
FULL OUTER JOIN Tabx_RayService_Lezaky L ON U.IDStavSkladu = L.ID AND ISNULL(U.LoginName,SUSER_SNAME()) = SUSER_SNAME()
INNER JOIN TabStavSkladu S ON ISNULL(U.IDStavSkladu,L.ID) = S.ID
WHERE ISNULL(U.LoginName,SUSER_SNAME()) IN (SUSER_SNAME(),'automat')
GO

