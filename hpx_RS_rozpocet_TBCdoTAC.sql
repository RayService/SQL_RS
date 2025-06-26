USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_rozpocet_TBCdoTAC]    Script Date: 26.06.2025 13:14:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_rozpocet_TBCdoTAC] @Kontrola BIT, @ID INT
AS
SET NOCOUNT ON
/*
USE HCvicna
DECLARE @ID INT=6078233
SELECT tp.*
FROM TabPostup tp
LEFT OUTER JOIN TabCzmeny tczOd ON tp.ZmenaOd=tczOd.ID
WHERE tp.ID=@ID
*/
--kontroly
IF @Kontrola = 0
BEGIN
RAISERROR('Akce neproběhne, není zatrženo potvrzení.',16,1)
RETURN
END
--správná operace
IF (SELECT tp.nazev
FROM TabPostup tp
WHERE tp.ID=@ID) NOT LIKE '%Příprava pracoviště%'
BEGIN
RAISERROR('Akce neproběhne, není označena operace "Příprava pracoviště".',16,1)
RETURN
END
--existuje vyšší změna
IF (SELECT tczDo.ID
FROM TabPostup tp
LEFT OUTER JOIN TabCzmeny tczDo ON tp.ZmenaDo=tczDo.ID
WHERE tp.ID=@ID) IS NOT NULL
BEGIN
RAISERROR('Akce neproběhne, existuje vyšší změna.',16,1)
RETURN
END
--zplatněná změna
IF (SELECT tczOd.Platnost
FROM TabPostup tp
LEFT OUTER JOIN TabCzmeny tczOd ON tp.ZmenaOd=tczOd.ID
WHERE tp.ID=@ID) =1
BEGIN
RAISERROR('Akce neproběhne, spouštíte pod zplatněnou změnou.',16,1)
RETURN
END

BEGIN
DECLARE @IDDilce INT, @IDZmenyDo INT, @IDZmenyOd INT, @OD NUMERIC(19,6)
SELECT @IDDilce=tp.dilec,@IDZmenyOd=tp.ZmenaOd,@IDZmenyDo=tp.ZmenaDo
FROM TabPostup tp WHERE tp.ID=@ID
--SELECT @IDDilce AS Dilec, @IDZmenyOd AS ZmenaOd, @IDZmenyDo AS ZmenaDo

SELECT @OD=ISNULL(td.davka,1)
FROM TabDavka td
LEFT OUTER JOIN TabCzmeny VDavkaCZmenyOd ON VDavkaCZmenyOd.ID=td.ZmenaOd
LEFT OUTER JOIN TabCzmeny VDavkaCZmenyDo ON VDavkaCZmenyDo.ID=td.ZmenaDo
WHERE
(td.IDDilce=@IDDilce AND td.zmenaOd=@IDZmenyOd AND td.ZmenaDo IS NULL)
--SELECT @OD
SELECT
tp.ID,tp.nazev,prac.IDTabStrom,tp.TBC_N,tp.TAC_Obsluhy,((1+(0.4/@OD))*tp.TAC_Obsluhy) AS NasobekTAC_Obsluhy,tp.TAC,((1+(0.4/@OD))*tp.TAC) AS NasobekTAC,tp.TAC_Obsluhy_J,((1+(0.4/@OD))*tp.TAC_Obsluhy_J) AS NasobekTAC_Obsluhy_J,tp.TAC_J,((1+(0.4/@OD))*tp.TAC_J) AS NasobekTAC_J
FROM TabPostup tp
LEFT OUTER JOIN TabCPraco prac ON tp.pracoviste=prac.ID
WHERE ((tp.dilec=@IDDilce AND tp.ZmenaOd=@IDZmenyOd/* AND tp.ZmenaDo=@IDZmenyDo*/)
AND(prac.IDTabStrom=N'200' OR prac.IDTabStrom LIKE '2002%')
AND(tp.ID<>@ID))
--smazání TBC na označeném řádku
UPDATE tp SET tp.TBC=0,TBC_Obsluhy=0,Zmenil=SUSER_SNAME(),DatZmeny=GETDATE()
FROM TabPostup tp
WHERE tp.ID=@ID

UPDATE tp SET 
TAC_Obsluhy=((1+(0.4/@OD))*tp.TAC_Obsluhy),
TAC=((1+(0.4/@OD))*tp.TAC), 
TAC_Obsluhy_J=((1+(0.4/@OD))*tp.TAC_Obsluhy_J),
TAC_J=((1+(0.4/@OD))*tp.TAC_J),
--Konf_TypMzdy=0,
Zmenil=SUSER_SNAME(),
DatZmeny=GETDATE()
FROM TabPostup tp
LEFT OUTER JOIN TabCPraco prac ON tp.pracoviste=prac.ID
LEFT OUTER JOIN TabCPraco_EXT prace WITH(NOLOCK) ON prace.ID=prac.ID
WHERE ((tp.dilec=@IDDilce AND tp.ZmenaOd=@IDZmenyOd/* AND tp.ZmenaDo=@IDZmenyDo*/)
AND(prac.IDTabStrom=N'200' OR (prac.IDTabStrom LIKE N'2002%'AND ISNULL(prace._EXT_RS_wokplaceQA,0)=0))
AND(tp.ID<>@ID))
/*
SELECT
tp.ID,tp.nazev,prac.IDTabStrom,tp.TBC_N,tp.TAC_Obsluhy,tp.TAC,tp.TAC_Obsluhy_J,tp.TAC_J
FROM TabPostup tp
LEFT OUTER JOIN TabCPraco prac ON tp.pracoviste=prac.ID
WHERE ((tp.dilec=@IDDilce AND tp.ZmenaOd=@IDZmenyOd/* AND tp.ZmenaDo=@IDZmenyDo*/)
AND(prac.IDTabStrom=N'200')
AND(tp.ID<>@ID))
*/
END;
GO

