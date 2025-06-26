USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ciselnik_kontrol_new]    Script Date: 26.06.2025 10:45:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ciselnik_kontrol_new]
@Sort INT,
@Code NVARCHAR(64),
@Title NVARCHAR(255),
@RoleCode NVARCHAR(20),
@PdfTitle NVARCHAR(255),
@PdfTitle_AJ NVARCHAR(255)
AS

INSERT INTO B2A_Fair_Fair_Inspection_Type (Sort, Code, Title, RoleCode,PdfTitle,PdfTitle_AJ)
VALUES (@Sort,@Code,@Title,@RoleCode,@PdfTitle,@PdfTitle_AJ)
GO

