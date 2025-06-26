USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_generovani_souboru_z_VP_do_adresare]    Script Date: 26.06.2025 12:51:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_generovani_souboru_z_VP_do_adresare]
AS
SET NOCOUNT ON
-- =============================================
-- Author:		MŽ
-- Create date:            18.10.2022
-- Description:	Generování souborů z vybraných VP do adresářů na serveru. Generování tiskových formulářů včetně výkresové dokumentace
-- =============================================

--pro VP
DECLARE @RadaPrikaz NVARCHAR(33),@Path NVARCHAR(255),@Filtr NVARCHAR(MAX),@NazevSouboru NVARCHAR(255),@UmisteniSouboru NVARCHAR(255);
--pro obrázky
DECLARE @IDPrikaz INT;
DECLARE
@IDFile INT
,@Zdroj INT
,@Kateg INT
,@PicName NVARCHAR(255)--='850-017863'
,@Nazev NVARCHAR(200)--alias Popis
,@Filename NVARCHAR(255)--='850-017863-07.pdf', alias JmenoSouboru
;
--vymažeme stávající data
EXEC xp_cmdshell 'RMDIR /s /q F:\OFFLINEVYROBA\Export_VP';

--tabulka pro uložení původní hodnoty data tisku
--IF OBJECT_ID('tempdb..#Prikazy') IS NOT NULL DROP TABLE #Prikazy
--CREATE TABLE #Prikazy (ID INT IDENTITY(1,1), IDPrikaz INT, DatTisku DATETIME, AutorTisku NVARCHAR(128))
DELETE FROM Tabx_RS_TiskPrikazy
INSERT INTO Tabx_RS_TiskPrikazy (IDPrikaz, DatTisku, AutorTisku)
SELECT TabPrikaz.ID, TabPrikaz.DatumTisku, TabPrikaz.AutorTisku
FROM TabPrikaz
WHERE
((TabPrikaz.StavPrikazu=30)AND(TabPrikaz.Rada<=N'803'))
--dočasně
--AND TabPrikaz.RadaPrikaz IN ('200 - 54448','200 - 54606')

DECLARE CurMKDir CURSOR LOCAL FAST_FORWARD FOR
SELECT TabPrikaz.RadaPrikaz
FROM TabPrikaz
WHERE
((TabPrikaz.StavPrikazu=30)AND(TabPrikaz.Rada<=N'803'))
--dočasně
--AND TabPrikaz.RadaPrikaz IN ('200 - 54448','200 - 54606')

OPEN CurMKDir;
FETCH NEXT FROM CurMKDir INTO @RadaPrikaz;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	SET @Path = 'F:\OFFLINEVYROBA\Export_VP\'+@RadaPrikaz
	EXEC xp_create_subdir @Path;
	--nyní vložíme do adresáře dokumenty
	SET @IDPrikaz=(SELECT ID FROM TabPrikaz WHERE RadaPrikaz=@RadaPrikaz)

	--export tiskového formuláře
	SET @Filtr='TabPrikaz.ID='+CONVERT(NVARCHAR(255),@IDPrikaz)
	SET @NazevSouboru='VP'+@RadaPrikaz
	-- požadavek na vytvoření dokumentu z tisku systému Helios technologií GatemaRemotePrint
	EXEC dbo.GEP_RP_NewPozadavekNaTisk_Dokument 
	@Uzivatel ='zufan',
	@Popis ='Export VP', 
	@BrowseID =11011, 
	@TiskID =364, 
	@Filtr =@Filtr, 
	@NazevSouboru =@NazevSouboru, --bez přípony
	@UmisteniSouboru =@Path,--'F:\OFFLINEVYROBA\',--NULL, --pokud je zadáno, tak je dokument uložen na disk; extení úložiště se zapisuje "<kod>"
	@IdentVazby =NULL, --pokud je vyplněno včetně @IDTabVazby, tak je založen dokument v systému HeOr.
	@IDTabVazby =NULL, 
	@Sklad =NULL, 
	@IDObdobi =NULL, 
	@DatumTPV =NULL, 
	@Priorita =3 --<0,10>

	--následuje cursor generování souborů z výrobní dokumentace
		DECLARE CurGenFile CURSOR LOCAL FAST_FORWARD FOR
		SELECT
		tvd.ID,tvd.Zdroj,tvd.IDKategorie,tvd.Popis,tvd.JmenoSouboru
		FROM TabVyrDokum tvd
		WHERE
		(EXISTS(SELECT * FROM TabVazbyVyrDokum VVD WHERE VVD.Oblast=3 AND VVD.RecID=@IDPrikaz AND VVD.ID1VyrDokum=tvd.ID1 AND
		(VVD.VerzeVyrDokum IS NULL AND tvd.Archiv=0 OR VVD.VerzeVyrDokum=tvd.Verze)))
		AND (tvd.IDKategorie=4)--omezení na kategorii "výkres"

		OPEN CurGenFile;
		FETCH NEXT FROM CurGenFile INTO @IDFile,@Zdroj,@Kateg,@Nazev,@FileName;
			WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
			BEGIN
			SELECT @PicName=@Nazev;
			SELECT @Filename=@Filename
				BEGIN
				   DECLARE @ImageData VARBINARY (max);
				   DECLARE @Path2OutFile NVARCHAR (2000);
				   DECLARE @Obj INT
 
				   SELECT @ImageData = (
						 SELECT convert (VARBINARY (max), tvd.Dokument, 1)
						 FROM TabVyrDokum tvd
						 WHERE ID = @IDFile
						 );
 
				   SET @Path2OutFile = CONCAT (
						 @Path
						 ,'\'
						 , @Filename
						 );
					BEGIN TRY
					 EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT;
					 EXEC sp_OASetProperty @Obj ,'Type',1;
					 EXEC sp_OAMethod @Obj,'Open';
					 EXEC sp_OAMethod @Obj,'Write', NULL, @ImageData;
					 EXEC sp_OAMethod @Obj,'SaveToFile', NULL, @Path2OutFile, 2;
					 EXEC sp_OAMethod @Obj,'Close';
					 EXEC sp_OADestroy @Obj;
					END TRY
    
				 BEGIN CATCH
				 EXEC sp_OADestroy @Obj;
				 END CATCH
				END

			FETCH NEXT FROM CurGenFile INTO @IDFile,@Zdroj,@Kateg,@Nazev,@FileName;
			END;
		CLOSE CurGenFile;
		DEALLOCATE CurGenFile;

	FETCH NEXT FROM CurMKDir INTO @RadaPrikaz;
	END;
CLOSE CurMKDir;
DEALLOCATE CurMKDir;
/*
--nakonec vrátíme zpět datum tisku VP
MERGE TabPrikaz AS TARGET
--USING #Prikazy AS SOURCE
USING Tabx_RS_TiskPrikazy AS SOURCE
ON TARGET.ID=SOURCE.IDPrikaz
WHEN MATCHED THEN
UPDATE SET TARGET.DatumTisku=SOURCE.DatTisku
;
*/

GO

