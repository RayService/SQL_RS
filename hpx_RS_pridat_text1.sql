USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_pridat_text1]    Script Date: 26.06.2025 14:26:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_pridat_text1]
@Text1 NVARCHAR(255),
@ID int
AS
BEGIN
UPDATE TabDokladyZbozi SET TabDokladyZbozi.Text1=CAST((ISNULL(CAST(TabDokladyZbozi.Text1 AS NVARCHAR(MAX)),'') +'
'+ @Text1) AS NTEXT) WHERE ID=@ID
END
GO

