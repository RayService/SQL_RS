USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromadnaZmenaUdajuRS]    Script Date: 26.06.2025 14:00:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromadnaZmenaUdajuRS]
@_VyjmoutZMapySkladu BIT,
@kontrola1 bit,
@_PovolitZaporneMnozNaUmisteni BIT,
@kontrola2 bit,
@_IDPolice INT,
@kontrola3 bit,
@_EXT_RS_generate_stock_taking_subordinate BIT,
@kontrola4 bit,
@_EXT_RS_PhysicalPlace INT,
@kontrola5 bit,
@_EXT_RS_IDLocationPrint INT,
@kontrola6 bit,
@_EXT_RS_VypnoutFIFOFEFO BIT,
@kontrola7 bit,
@_EXT_RS_VypnoutVzorec BIT,
@kontrola8 bit,
@ID INT
AS
IF @kontrola1 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _VyjmoutZMapySkladu=@_VyjmoutZMapySkladu WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_VyjmoutZMapySkladu)
  VALUES (@ID,@_VyjmoutZMapySkladu);
END
COMMIT TRANSACTION;
END;

IF @kontrola2=1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _PovolitZaporneMnozNaUmisteni=@_PovolitZaporneMnozNaUmisteni WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_PovolitZaporneMnozNaUmisteni)
  VALUES (@ID,@_PovolitZaporneMnozNaUmisteni);
END
COMMIT TRANSACTION;
END;

IF @kontrola3 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _IDPolice=@_IDPolice WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_IDPolice)
  VALUES (@ID,@_IDPolice);
END
COMMIT TRANSACTION;
END;

IF @kontrola4 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_generate_stock_taking_subordinate=@_EXT_RS_generate_stock_taking_subordinate WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_EXT_RS_generate_stock_taking_subordinate)
  VALUES (@ID,@_EXT_RS_generate_stock_taking_subordinate);
END
COMMIT TRANSACTION;
END;

IF @kontrola5 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_PhysicalPlace=@_EXT_RS_PhysicalPlace WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_EXT_RS_PhysicalPlace)
  VALUES (@ID,@_EXT_RS_PhysicalPlace);
END
COMMIT TRANSACTION;
END;

IF @kontrola6 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_IDLocationPrint=@_EXT_RS_IDLocationPrint WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_EXT_RS_IDLocationPrint)
  VALUES (@ID,@_EXT_RS_IDLocationPrint);
END
COMMIT TRANSACTION;
END;

IF @kontrola7 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_VypnoutFIFOFEFO=@_EXT_RS_VypnoutFIFOFEFO WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_EXT_RS_VypnoutFIFOFEFO)
  VALUES (@ID,@_EXT_RS_VypnoutFIFOFEFO);
END
COMMIT TRANSACTION;
END;

IF @kontrola8 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_VypnoutVzorec=@_EXT_RS_VypnoutVzorec WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_EXT_RS_VypnoutVzorec)
  VALUES (@ID,@_EXT_RS_VypnoutVzorec);
END
COMMIT TRANSACTION;
END;

IF @kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0 AND @kontrola6=0 AND @kontrola7=0 AND @kontrola8=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

