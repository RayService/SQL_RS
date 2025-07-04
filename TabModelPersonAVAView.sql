USE [RayService]
GO

/****** Object:  View [dbo].[TabModelPersonAVAView]    Script Date: 04.07.2025 11:30:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabModelPersonAVAView] AS
SELECT
z.ID AS ID
,z.ID AS IDCisZam
,NULL AS IDCisKOs
,z.AVAReferenceID AS AVAReferenceID
,CAST(N'Employee' AS NVARCHAR(100)) AS PersonType
,CAST(N'Employee.PersonType.00000000-0000-0000-0000-000000000000' AS NVARCHAR(100)) AS PersonTypeExternalId
,z.RodneCislo AS IdentificationNumber
,z.StatniPrislus AS CountryCode
,z.Jmeno AS FirstName
,z.Prijmeni AS Surname
,z.TitulPred AS TitlePre
,z.TitulZa AS TitlePost
,z.DatumNarozeni AS DateOfBirth
,CAST((CASE z.Pohlavi WHEN 0 THEN N'Male.PersonGenderType.00000000-0000-0000-0000-000000000000' WHEN 1 THEN N'Female.PersonGenderType.00000000-0000-0000-0000-000000000000' ELSE N'Unspecified.PersonGenderType.00000000-0000-0000-0000-000000000000' END) AS NVARCHAR(100)) AS Gender
,z.Obrazek AS Photo
,z.Obrazek_BGJ AS Photo_BGJ
FROM TabCisZam z

UNION ALL

SELECT
-k.ID AS ID
,NULL AS IDCisZam
,k.ID AS IDCisKOs
,k.AVAReferenceID AS AVAReferenceID
,CAST(N'ContactPerson' AS NVARCHAR(100)) AS PersonType
,CAST(N'ContactPerson.PersonType.00000000-0000-0000-0000-000000000000' AS NVARCHAR(100)) AS PersonTypeExternalId
,k.RodneCislo AS IdentificationNumber
,k.StatniPrislus AS CountryCode
,k.Jmeno AS FirstName
,k.Prijmeni AS Surname
,k.TitulPred AS TitlePre
,k.TitulZa AS TitlePost
,k.DatumNarozeni AS DateOfBirth
,CAST((CASE k.Pohlavi WHEN 0 THEN N'Male.PersonGenderType.00000000-0000-0000-0000-000000000000' WHEN 1 THEN N'Female.PersonGenderType.00000000-0000-0000-0000-000000000000' ELSE N'Unspecified.PersonGenderType.00000000-0000-0000-0000-000000000000' END) AS NVARCHAR(100)) AS Gender
,NULL AS Photo
,NULL AS Photo_BGJ
FROM TabCisKOs k
GO

