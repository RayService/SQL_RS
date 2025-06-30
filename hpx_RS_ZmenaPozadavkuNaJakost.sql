USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaPozadavkuNaJakost]    Script Date: 30.06.2025 8:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_ZmenaPozadavkuNaJakost]

@_zprava_prv_kus BIT --(Zpráva z ověření prvního kusu dle EN 9102 (FAI Report))
,@kontrola1 BIT
,@_ZKUS_ZPR_EN10204 BIT --(Zkušební zpráva dle EN 10204 "2.2")
,@kontrola2 BIT
,@_Cofc_en10204 BIT --(CofC, dle EN10204 "2.1")
,@kontrola3 BIT
,@_atest_pouz_mat BIT ----(CofC dle EN 10204 "3.1" / Atest použitých materiálů)
,@kontrola4 BIT
,@_merici_protokol BIT --(Měřící protokol (týká se opakovaných dodávek, kdy není vystaven FAI Report))
,@kontrola5 BIT
,@_cofc_vyrobce BIT --(CofC výrobce, dle EN10204 "2.1")
,@kontrola6 BIT
,@_jine_Dokumenty BIT --(Jiné dokumenty)
,@kontrola7 BIT
,@_VseoPoz NVARCHAR(540) --(Všeobecné požadavky)
,@kontrola8 BIT
,@ID INT

AS

DECLARE @IDPol INT
SET @IDPol=(SELECT #TabSouhrnnyKusovnik.IDKmenZbozi FROM #TabSouhrnnyKusovnik WHERE #TabSouhrnnyKusovnik.ID=@ID)

IF @kontrola1=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_zprava_prv_kus)
    VALUES (@IDPol,@_zprava_prv_kus)
 END
ELSE
UPDATE tkze SET tkze._zprava_prv_kus = @_zprava_prv_kus
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF @kontrola2=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_ZKUS_ZPR_EN10204)
    VALUES (@IDPol,@_ZKUS_ZPR_EN10204)
 END
ELSE
UPDATE tkze SET tkze._ZKUS_ZPR_EN10204 = @_ZKUS_ZPR_EN10204
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF @kontrola3=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_Cofc_en10204)
    VALUES (@IDPol,@_Cofc_en10204)
 END
ELSE
UPDATE tkze SET tkze._Cofc_en10204 = @_Cofc_en10204
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF @kontrola4=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_atest_pouz_mat)
    VALUES (@IDPol,@_atest_pouz_mat)
 END
ELSE
UPDATE tkze SET tkze._atest_pouz_mat = @_atest_pouz_mat
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF @kontrola5=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_merici_protokol)
    VALUES (@IDPol,@_merici_protokol)
 END
ELSE
UPDATE tkze SET tkze._merici_protokol = @_merici_protokol
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF @kontrola6=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_cofc_vyrobce)
    VALUES (@IDPol,@_cofc_vyrobce)
 END
ELSE
UPDATE tkze SET tkze._cofc_vyrobce = @_cofc_vyrobce
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF @kontrola7=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_jine_Dokumenty)
    VALUES (@IDPol,@_jine_Dokumenty)
 END
ELSE
UPDATE tkze SET tkze._jine_Dokumenty = @_jine_Dokumenty
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF @kontrola8=1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDPol) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_VseoPoz)
    VALUES (@IDPol,@_VseoPoz)
 END
ELSE
UPDATE tkze SET tkze._VseoPoz = @_VseoPoz
FROM TabKmenZbozi_EXT tkze
WHERE tkze.ID = @IDPol
END;

IF (@kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0 AND @kontrola6=0 AND @kontrola7=0 AND @kontrola8=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

