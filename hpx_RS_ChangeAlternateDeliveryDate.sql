USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ChangeAlternateDeliveryDate]    Script Date: 30.06.2025 8:26:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ChangeAlternateDeliveryDate] @NewDate DATETIME, @Prepsat BIT, @ID INT
AS
IF @Prepsat = 1
BEGIN
IF NOT EXISTS  (SELECT *  FROM TabPohybyZbozi_EXT  PZE WHERE   PZE.ID = @ID)
    BEGIN 
       INSERT INTO TabPohybyZbozi_EXT (ID,_dat_dod) 
       VALUES (@ID,@NewDate)
    END
ELSE
    BEGIN
        UPDATE TabPohybyZbozi_EXT  
        SET _dat_dod = @NewDate
        WHERE ID = @ID
     END
END
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

