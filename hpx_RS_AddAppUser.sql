USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AddAppUser]    Script Date: 26.06.2025 12:52:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--procedura pro založení uživatele, vrací 1=OK, 0=není založen
CREATE PROCEDURE [dbo].[hpx_RS_AddAppUser]
    @pLogin NVARCHAR(40),
    @pPassword NVARCHAR(500),
    @pFullName NVARCHAR(1000) = NULL,
	@pIDZam INT,
	@pIDMaticeRoleProcesy INT
	--,@response BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY

        INSERT INTO dbo.Tabx_RS_AppUsers (UserName, PasswordHash, FullName, IDZam, IDMaticeRoleProcesy)
        VALUES(@pLogin, HASHBYTES('SHA2_512', @pPassword), @pFullName, @pIDZam, @pIDMaticeRoleProcesy)

       -- SET @response=1

    END TRY
    BEGIN CATCH
       -- SET @response=0
    END CATCH

END
GO

