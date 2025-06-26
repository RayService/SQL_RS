USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_export_file_from_db]    Script Date: 26.06.2025 11:21:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RS_export_file_from_db] (
   @PicName NVARCHAR (100)
   ,@FileFolderPath NVARCHAR(1000)
   ,@Filename NVARCHAR(1000)
   )
AS
BEGIN
   DECLARE @FileData VARBINARY (max);
   DECLARE @Path2OutFile NVARCHAR (2000);
   DECLARE @Obj INT
DECLARE @IDVOB INT=1232914;
DECLARE @DatumTPV DATETIME;

SELECT @DatumTPV=(SELECT DatPorizeni FROM TabDokladyZbozi tdz WITH(NOLOCK) WHERE tdz.ID=@IDVOB) 

   SET NOCOUNT ON
SELECT @FileFolderPath='C:\%TEMP%'
SELECT @Filename='test.pdf'
SELECT @PicName='test'
   SELECT @FileData = (
         SELECT TOP 1 convert (VARBINARY (max),Dokument, 1)
         FROM TabVyrDokum
		 LEFT OUTER JOIN TabCzmeny VVyrDokumZmenaOdCZmeny ON TabVyrDokum.ZmenaOd=VVyrDokumZmenaOdCZmeny.ID
		 LEFT OUTER JOIN TabCzmeny VVyrDokumZmenaDoCZmeny ON TabVyrDokum.ZmenaDo=VVyrDokumZmenaDoCZmeny.ID
		 WHERE
		 (((EXISTS(SELECT * FROM TabKmenZbozi KZ LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=0 AND ZMD.IDKmenZbozi=KZ.ID AND ZMD.TPVModif=1) 
		 INNER JOIN TabVazbyVyrDokum VVD ON (VVD.Oblast=CASE WHEN ZMD.ID IS NULL THEN 1 ELSE 2 END AND VVD.RecID=CASE WHEN ZMD.ID IS NULL THEN KZ.IDKusovnik ELSE KZ.ID END 
		 AND ((ZMD.ID IS NULL AND (VVD.RecID2 IS NULL OR VVD.RecID2=KZ.IDVarianta)) OR (ZMD.ID IS NOT NULL AND VVD.RecID2=ZMD.IDZakazModif))) LEFT OUTER JOIN TabCZmeny ZOd ON (ZOd.ID=VVD.zmenaOd) 
		 LEFT OUTER JOIN TabCZmeny ZDo ON (ZDo.ID=VVD.zmenaDo) 
		 WHERE KZ.ID IN (SELECT tkz.ID
						FROM TabPohybyZbozi tpz WITH(NOLOCK)
						LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
						LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad
						WHERE (tdz.ID=@IDVOB)
						GROUP BY tkz.ID)
		AND KZ.Dilec=1 AND VVD.ID1VyrDokum=TabVyrDokum.ID1 
		AND (VVD.VerzeVyrDokum IS NULL AND TabVyrDokum.Archiv=0 OR VVD.VerzeVyrDokum=TabVyrDokum.Verze) AND (VVD.zmenaOd IS NULL OR ZOd.platnostTPV=1 AND ZOd.datum<=@DatumTPV
		AND (ZDo.platnostTPV=0 OR VVD.ZmenaDo IS NULL OR (ZDo.platnostTPV=1 AND ZDo.datum>@DatumTPV)) ) AND (VVD.Oblast=2 OR VVyrDokumZmenaOdCZmeny.platnostTPV=1 
		AND VVyrDokumZmenaOdCZmeny.datum<=@DatumTPV AND (VVyrDokumZmenaDoCZmeny.platnostTPV=0 OR TabVyrDokum.ZmenaDo IS NULL OR (VVyrDokumZmenaDoCZmeny.platnostTPV=1 
		AND VVyrDokumZmenaDoCZmeny.datum>@DatumTPV)) ) ) ))AND(TabVyrDokum.IDKategorie IN (4,19)))
		ORDER BY TabVyrDokum.Popis ASC/*@PicName*/
         );
 
   SET @Path2OutFile = CONCAT (
         @FileFolderPath
         ,'\'
         , @Filename
         );
    BEGIN TRY
     EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT;
     EXEC sp_OASetProperty @Obj ,'Type',1;
     EXEC sp_OAMethod @Obj,'Open';
     EXEC sp_OAMethod @Obj,'Write', NULL, @FileData;
     EXEC sp_OAMethod @Obj,'SaveToFile', NULL, @Path2OutFile, 2;
     EXEC sp_OAMethod @Obj,'Close';
     EXEC sp_OADestroy @Obj;
    END TRY
    
 BEGIN CATCH
  EXEC sp_OADestroy @Obj;
 END CATCH
 
   SET NOCOUNT OFF
END
GO

