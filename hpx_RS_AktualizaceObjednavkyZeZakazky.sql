USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AktualizaceObjednavkyZeZakazky]    Script Date: 26.06.2025 15:13:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_AktualizaceObjednavkyZeZakazky]
@kontrola bit,
@ID INT
AS
SET NOCOUNT ON
IF @kontrola = 1
BEGIN
DECLARE @NavaznaObjednavka NVARCHAR(30)
DECLARE @CisloObjednavky NVARCHAR(50)
SET @CisloObjednavky=(SELECT tz.CisloObjednavky FROM TabPrikaz tp LEFT OUTER JOIN TabZakazka tz ON tz.ID=tp.IDZakazka WHERE tp.ID=@ID)
SET @NavaznaObjednavka=(SELECT ISNULL(tp.NavaznaObjednavka,'') FROM TabPrikaz tp WHERE tp.ID=@ID)
IF (@CisloObjednavky<>@NavaznaObjednavka AND @CisloObjednavky<>'')
BEGIN
UPDATE TabPrikaz SET NavaznaObjednavka=@CisloObjednavky, Zmenil=SUSER_SNAME(), DatZmeny=GETDATE() WHERE ID=@ID;
END;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

