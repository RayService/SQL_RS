USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ciselnik_kontrol_edit]    Script Date: 26.06.2025 10:45:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ciselnik_kontrol_edit]
@Sort INT,
@Code NVARCHAR(64),
@Title NVARCHAR(255),
@RoleCode NVARCHAR(20),
@PdfTitle NVARCHAR(255),
@PdfTitle_AJ NVARCHAR(255),
@ID INT
AS

UPDATE B2A_Fair_Fair_Inspection_Type SET
Sort = @Sort,
Code = @Code,
Title= @Title,
RoleCode = @RoleCode,
PdfTitle=@PdfTitle,
PdfTitle_AJ=@PdfTitle_AJ
WHERE ID = @ID
GO

