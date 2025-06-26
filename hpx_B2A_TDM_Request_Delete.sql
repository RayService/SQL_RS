USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_B2A_TDM_Request_Delete]    Script Date: 26.06.2025 10:12:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_B2A_TDM_Request_Delete] @ID INT
AS
IF @ID IN (SELECT IDRequest FROM B2A_TDM_CuttingTest)
     BEGIN
          RAISERROR ('Na žádosti je již vytvořena zkouška řezem!',16,1)
     END
ELSE
    BEGIN
           DELETE FROM B2A_TDM_TensileTest_Request WHERE ID =@ID
    END
GO

