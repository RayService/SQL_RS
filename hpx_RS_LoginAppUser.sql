USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_LoginAppUser]    Script Date: 26.06.2025 12:53:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--procedura pro kontrolu při zalogování, vrací 1=úspěch, 0=špata
CREATE PROCEDURE [dbo].[hpx_RS_LoginAppUser]
    @pLoginName NVARCHAR(40),
    @pPassword NVARCHAR(500),
    @response BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @userID INT

    IF EXISTS (SELECT TOP 1 ID FROM [dbo].[Tabx_RS_AppUsers] WHERE UserName=@pLoginName)
    BEGIN
       SET @userID=(SELECT ID FROM [dbo].[Tabx_RS_AppUsers] WHERE UserName=@pLoginName AND PasswordHash=HASHBYTES('SHA2_512', @pPassword))

       IF(@userID IS NULL)
           SET @response=0
       ELSE 
           SET @response=1
    END
    ELSE
       SET @response=0
END
GO

