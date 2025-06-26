USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_udaju_RS_vztahy_kont_osob]    Script Date: 26.06.2025 13:05:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_udaju_RS_vztahy_kont_osob]
@_EXT_RS_zaslat_kalendar BIT,
@kontrola1 bit,
@_EXT_RS_typ_darku NVARCHAR(10),
@kontrola2 bit,
@Pohlavi SMALLINT,
@kontrola3 bit,
@_EXT_RS_email_zpravy BIT,
@kontrola4 bit,
@ID int
AS
IF @kontrola1 = 1
BEGIN
IF (SELECT VOS.ID  FROM TabVztahOrgKOs_EXT as VOS WHERE VOS.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabVztahOrgKOs_EXT (ID,_EXT_RS_zaslat_kalendar)
    VALUES (@ID,@_EXT_RS_zaslat_kalendar)
 END
ELSE
UPDATE TabVztahOrgKOs_EXT SET _EXT_RS_zaslat_kalendar = @_EXT_RS_zaslat_kalendar WHERE ID = @ID
END

IF @kontrola2 = 1
BEGIN
IF (SELECT VOS.ID  FROM TabVztahOrgKOs_EXT as VOS WHERE VOS.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabVztahOrgKOs_EXT (ID,_EXT_RS_typ_darku)
    VALUES (@ID,@_EXT_RS_typ_darku)
 END
ELSE
UPDATE TabVztahOrgKOs_EXT SET _EXT_RS_typ_darku = @_EXT_RS_typ_darku WHERE ID = @ID
END

IF @kontrola3 = 1
BEGIN
UPDATE KOS SET KOS.Pohlavi=@Pohlavi
FROM TabVztahOrgKOs VOS
LEFT OUTER JOIN TabCisKOs KOS ON KOS.ID=VOS.IDCisKOs
WHERE VOS.ID = @ID
END

IF @kontrola4 = 1
BEGIN
IF (SELECT VOS.ID  FROM TabVztahOrgKOs_EXT as VOS WHERE VOS.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabVztahOrgKOs_EXT (ID,_EXT_RS_email_zpravy)
    VALUES (@ID,@_EXT_RS_email_zpravy)
 END
ELSE
UPDATE TabVztahOrgKOs_EXT SET _EXT_RS_email_zpravy = @_EXT_RS_email_zpravy WHERE ID = @ID
END

IF @kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

