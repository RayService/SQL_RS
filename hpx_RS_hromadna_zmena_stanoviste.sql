USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_hromadna_zmena_stanoviste]    Script Date: 26.06.2025 12:49:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_hromadna_zmena_stanoviste] @Prepsat BIT, @IDZmeny INT, @_Stan NVARCHAR(10), @ID INT
AS

/*
--cvičně id řádku
DECLARE @ID INT=4158021;
DECLARE @IDZmeny INT;
DECLARE @KontrolniText NVARCHAR(255);
SELECT @IDZmeny=66491
*/

IF @Prepsat=0
BEGIN
RAISERROR('Není zatrženo Přepsat, nic neproběhne.',16,1)
RETURN;
END;

IF @Prepsat=1
BEGIN


DECLARE @IDZakazModif INT, @IDDilce INT, @ID1 INT, @Ret INT, @typ INT, @NewPrac INT, @NewKoop INT
SELECT @IDZakazModif=0, @typ=1, @NewPrac=0, @NewKoop=0

SELECT @IDDilce=dilec, @ID1=ID1
FROM TabPostup
WHERE ID=@ID

--SET @KontrolniText=N'Testovací text pro kontrolní operaci'

--SELECT @IDDilce, @ID1, @KontrolniText

BEGIN TRAN 
  IF @IDZakazModif=0 
    BEGIN 
      EXEC hp_ZdvojeniKonstrukceATech @IDVyssi=@IDDilce, @IDZmena=@IDZmeny, @PovolitZmenuZmeny=1 
      IF @@error<>0 OR @Ret<>0 GOTO CHYBA 
    END 
	UPDATE TabPostup SET Zmenil=SYSTEM_USER, DatZmeny=GETDATE()
	WHERE ID1=@ID1 AND ISNULL(ZmenaOd,0)=@IDZmeny AND ZmenaDo IS NULL AND typ=@typ
	
	UPDATE tpe WITH (UPDLOCK, SERIALIZABLE) SET _Stan = @_Stan
	FROM dbo.TabPostup_EXT tpe
	LEFT OUTER JOIN TabPostup tp ON tp.ID=tpe.ID
	WHERE tp.ID1=@ID1 AND ISNULL(tp.ZmenaOd,0)=@IDZmeny AND tp.ZmenaDo IS NULL/* AND tp.typ=@typ*/;
	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT INTO TabPostup_EXT(ID, _Stan)
	  SELECT tp.ID,@_Stan
	  FROM dbo.TabPostup_EXT tpe
	  LEFT OUTER JOIN TabPostup tp ON tp.ID=tpe.ID
	  WHERE tp.ID1=@ID1 AND ISNULL(tp.ZmenaOd,0)=@IDZmeny AND tp.ZmenaDo IS NULL;
	END
/*
	UPDATE tpe SET tpe._Stan=@_Stan
	FROM TabPostup_EXT tpe
	LEFT OUTER JOIN TabPostup tp ON tp.ID=tpe.ID
	WHERE tp.ID1=@ID1 AND ISNULL(tp.ZmenaOd,0)=@IDZmeny AND tp.ZmenaDo IS NULL AND tp.typ=@typ*/
  IF @@error<>0 GOTO CHYBA 
  KONEC: 
COMMIT TRAN 
RETURN 
CHYBA: 
 IF @@trancount>0 ROLLBACK TRAN

END;
GO

