USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_update_eWay_tasks]    Script Date: 26.06.2025 10:24:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:	 David Kovář
-- Create date:
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[hpx_update_eWay_tasks]
AS
BEGIN 
    DECLARE @ID INT   --deklaruju proměnnou ID úkolu, který se bude v rámci kurzoru měnit
    
    	DECLARE DK_cur CURSOR LOCAL FAST_FORWARD FOR  --deklarujeme kurzor
	  SELECT rsu.ID FROM RayService.dbo.TabUkoly rsu  --přiřadíme kurzor do proměnné
	  LEFT OUTER JOIN RayService.dbo.TabCisZam tcz ON rsu.Resitel=tcz.Cislo
	  LEFT OUTER JOIN RayService.dbo.TabKontaktJednani tkj ON rsu.IDKontaktJed=tkj.ID AND rsu.Vzor=0
	  WHERE
	  ((rsu.Vzor=0)AND((rsu.DatPorizeni>='2008-02-18 00:00:00.000')AND(rsu.TerminSplneni<'2099-12-31 00:00:00.000')AND(rsu.DatumDokonceni IS NULL)AND(tcz.PrijmeniJmeno IS NOT NULL)AND(tkj.Kategorie<>N'029')))

					
	OPEN DK_cur  --otevřeme kurzor
	
	WHILE 1=1
	  BEGIN	
	    FETCH NEXT FROM DK_cur
		INTO @ID
			
	    IF @@FETCH_STATUS <> 0 BREAK


		-- Vezmu GUID ukolu, ktery chci aktualizovat
		DECLARE @TaskToUpdateGUID UNIQUEIDENTIFIER
			SET @TaskToUpdateGUID = (SELECT ItemGUID FROM eWay.dbo.EWD_Tasks WHERE af_21 = @ID )

		-- Nactu RealtionDataGUID pro vazbu mezi resitelem a ukolem. RelationDataGUID je stejna pro oba smery vazby, proto je jednodussi
		-- delat update pomoci RelationDataGUID, nez pomoci ItemGUID samotneho zaznamu.
		DECLARE @RelationDataGUID UNIQUEIDENTIFIER
			SET @RelationDataGUID = (SELECT RelationDataGUID FROM EWR_ObjectRelations WHERE RelationType = N'TASKSOLVER' AND ItemGUID1 = @TaskToUpdateGUID AND ObjectTypeID2 = 2)

		-- Nactu si GUID noveho uzivatele
		DECLARE @NewUserGUID UNIQUEIDENTIFIER		/*musím dohledat GUID uživatele dle řešitele z úkolu*/
			SET @NewUserGUID = (SELECT ewu.ItemGUID
								FROM eWay.dbo.EWD_Users ewu
								JOIN RayService.dbo.TabCisZam tcz ON tcz.LoginID = ewu.UserName collate DATABASE_DEFAULT
								LEFT OUTER JOIN RayService.dbo.TabUkoly rsu ON rsu.Resitel = tcz.Cislo
								WHERE ewu.UserName  collate DATABASE_DEFAULT = tcz.LoginId AND rsu.ID = @ID)

		BEGIN TRAN

		-- Aktualizuju smer Uzivatel-Ukol
		UPDATE EWR_ObjectRelations
		SET          ItemVersion = ItemVersion + 1, 
				     Server_Itemchanged = GETDATE(),
					 ItemGUID1 = @NewUserGUID
		WHERE RelationDataGUID = @RelationDataGUID AND ObjectTypeID1 = 2

		-- Aktalizuju smer Ukol-Uzivatel
		UPDATE EWR_ObjectRelations
		SET          ItemVersion = ItemVersion + 1, 
			         Server_Itemchanged = GETDATE(),
					 ItemGUID2 = @NewUserGUID
		WHERE RelationDataGUID = @RelationDataGUID AND ObjectTypeID2 = 2

		-- Vlozim do ItemChanges
		INSERT INTO EWD_ItemChanges(ItemGUID, ObjectTypeID, Removed, ItemCreated)
		SELECT ItemGUID, 1, 0, GETDATE()
		FROM EWR_ObjectRelations WHERE RelationDataGUID = @RelationDataGUID
      END

	CLOSE DK_cur  --zavření kurzoru
	DEALLOCATE DK_cur   --vymazání kurzoru
END



GO

