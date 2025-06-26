USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_HromZmena_DilecGenVC]    Script Date: 26.06.2025 9:15:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_HromZmena_DilecGenVC]
	@_RayService_GenVC_Maska NVARCHAR(100)
	,@_RayService_GenVC_RespPosledni BIT
	,@ID INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Hromadná změna externích atributů pro generování VČ na dílci
-- =============================================

SET @_RayService_GenVC_Maska = NULLIF(@_RayService_GenVC_Maska,N'');

MERGE TabKmenZbozi_EXT ET
USING ( 
    VALUES (@ID, @_RayService_GenVC_Maska, @_RayService_GenVC_RespPosledni)
) AS V (ID, _RayService_GenVC_Maska ,_RayService_GenVC_RespPosledni) 
ON ET.ID = V.ID
WHEN MATCHED THEN
   UPDATE SET _RayService_GenVC_Maska = V._RayService_GenVC_Maska
			,_RayService_GenVC_RespPosledni = V._RayService_GenVC_RespPosledni
WHEN NOT MATCHED BY TARGET THEN
   INSERT (ID, _RayService_GenVC_Maska, _RayService_GenVC_RespPosledni)
   VALUES (V.ID, V._RayService_GenVC_Maska, V._RayService_GenVC_RespPosledni);
GO

