USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_hromadna_zmena_atributu_JAK]    Script Date: 26.06.2025 12:04:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
--Zpráva z ověření prvního kusu dle EN 9102 pro vyráběný dílec		_zprava_prv_kus		BIT
--Zkušební zpráva dle EN 10204 "2.2"		_ZKUS_ZPR_EN10204		BIT
--CofC, dle EN10204 "2.1"		_Cofc_en10204		BIT
--Atest použitých materiálů		_atest_pouz_mat		BIT
--Měřící protokol		_merici_protokol		BIT
--CofC výrobce, dle EN10204 "2.1"		_cofc_vyrobce		BIT
--Jiné dokumenty		_jine_Dokumenty		BIT
--Všeobecné požadavky		_VseoPoz		NVARCHAR(540)
*/

CREATE PROC [dbo].[hpx_RS_hromadna_zmena_atributu_JAK]
@_ZKUS_ZPR_EN10204 BIT,
@kontrola1 bit,
@_atest_pouz_mat BIT,
@kontrola2 bit,
@_merici_protokol BIT,
@kontrola3 bit,
@_cofc_vyrobce BIT,
@kontrola4 bit,
@_jine_Dokumenty BIT,
@kontrola5 bit,
@_VseoPoz NVARCHAR(540),
@kontrola6 bit,
@ID INT
AS
--Zkušební zpráva dle EN 10204 "2.2"	
IF @kontrola1 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _ZKUS_ZPR_EN10204=@_ZKUS_ZPR_EN10204 WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_ZKUS_ZPR_EN10204)
  VALUES (@ID,@_ZKUS_ZPR_EN10204);
END
COMMIT TRANSACTION;
END;
--Atest použitých materiálů
IF @kontrola2 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _atest_pouz_mat=@_atest_pouz_mat WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_atest_pouz_mat)
  VALUES (@ID,@_atest_pouz_mat);
END
COMMIT TRANSACTION;
END;
--Měřící protokol
IF @kontrola3 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _merici_protokol=@_merici_protokol WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_merici_protokol)
  VALUES (@ID,@_merici_protokol);
END
COMMIT TRANSACTION;
END;
--CofC výrobce, dle EN10204 "2.1"
IF @kontrola4 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _cofc_vyrobce=@_cofc_vyrobce WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_cofc_vyrobce)
  VALUES (@ID,@_cofc_vyrobce);
END
COMMIT TRANSACTION;
END;
--Jiné dokumenty
IF @kontrola5 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _jine_Dokumenty=@_jine_Dokumenty WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_jine_Dokumenty)
  VALUES (@ID,@_jine_Dokumenty);
END
COMMIT TRANSACTION;
END;
--Všeobecné požadavky
IF @kontrola6 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _VseoPoz=@_VseoPoz WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_VseoPoz)
  VALUES (@ID,@_VseoPoz);
END
COMMIT TRANSACTION;
END;

IF @kontrola1=0 AND @kontrola2=0 AND @kontrola3 = 0 AND @kontrola4 = 0 AND @kontrola5 = 0 AND @kontrola6 = 0 
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

