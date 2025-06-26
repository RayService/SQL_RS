USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AddContraPartsLink_FirstStep]    Script Date: 26.06.2025 13:27:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_AddContraPartsLink_FirstStep] @ID INT
AS

--nejprve promazání případných předešlých dat
DELETE FROM Tabx_RS_ContraPatrsLink WHERE SPID=@@SPID

DECLARE @IDHlavicka INT
SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'
--dohledání ID změny
DECLARE @IDZmena INT
SET @IDZmena = (SELECT TabCzmeny.ID
FROM TabCzmeny
WHERE
((TabCZmeny.Platnost = 0 AND TabCZmeny.ID IN  (
SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDHlavicka
UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDHlavicka
UNION SELECT zmenaOd FROM tabPostup WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabPostup WHERE dilec=@IDHlavicka
UNION   SELECT zmenaOd FROM TabNvazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM TabNvazby WHERE dilec=@IDHlavicka 
UNION   SELECT zmenaOd FROM tabTpvOPN WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabTpvOPN WHERE dilec=@IDHlavicka 
UNION   SELECT zmenaOd FROM tabVPVazby WHERE dilec=@IDHlavicka UNION SELECT zmenaDo FROM tabVPVazby WHERE dilec=@IDHlavicka 
UNION SELECT zmenaOd FROM tabDavka WHERE IDDilce=@IDHlavicka UNION SELECT zmenaDo FROM tabDavka WHERE IDDilce=@IDHlavicka )
)))
INSERT INTO Tabx_RS_ContraPatrsLink	(IDRow, IDHlavicka, IDZmeny, SPID)
VALUES (@ID,@IDHlavicka,@IDZmena,@@SPID)

GO

