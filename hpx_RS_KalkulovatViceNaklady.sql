USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KalkulovatViceNaklady]    Script Date: 26.06.2025 14:18:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KalkulovatViceNaklady]
@KalkulovatFAIR BIT,
@kontrola1 bit,
@KalkulovatPPAP BIT,
@kontrola2 bit,
@KalkulovatCofC BIT,
@kontrola3 bit,
@ID INT
AS
IF @kontrola1 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPozaZDok_kalk WITH (UPDLOCK, SERIALIZABLE) SET KalkulovatFAIR=@KalkulovatFAIR WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPozaZDok_kalk (ID,KalkulovatFAIR)
  VALUES (@ID,@KalkulovatFAIR);
END
COMMIT TRANSACTION;
END;

IF @kontrola2 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPozaZDok_kalk WITH (UPDLOCK, SERIALIZABLE) SET KalkulovatPPAP=@KalkulovatPPAP WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPozaZDok_kalk (ID,KalkulovatPPAP)
  VALUES (@ID,@KalkulovatPPAP);
END
COMMIT TRANSACTION;
END;

IF @kontrola3 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPozaZDok_kalk WITH (UPDLOCK, SERIALIZABLE) SET KalkulovatCofC=@KalkulovatCofC WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPozaZDok_kalk (ID,KalkulovatCofC)
  VALUES (@ID,@KalkulovatCofC);
END
COMMIT TRANSACTION;
END;

IF (@kontrola1=0 AND @kontrola2=0 AND @kontrola3=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

