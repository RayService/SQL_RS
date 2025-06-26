USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_termpriority]    Script Date: 26.06.2025 13:17:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_termpriority]
@kontrola1 BIT,
@_VPprior NVARCHAR(10),
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpe.ID  FROM TabPlan_EXT tpe WHERE tpe.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPlan_EXT (ID,_VPprior)
    VALUES (@ID,@_VPprior)
 END
ELSE
UPDATE tpe SET tpe._VPprior = @_VPprior
FROM TabPlan_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

