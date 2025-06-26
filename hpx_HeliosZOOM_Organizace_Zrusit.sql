USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_Organizace_Zrusit]    Script Date: 26.06.2025 9:35:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosZOOM_Organizace_Zrusit]
@ID INT
AS
DECLARE @CisloOrg INT

IF EXISTS(SELECT * FROM TabCisOrg WHERE ((TabCisOrg.ID=@ID)) AND BlokovaniEditoru IS NOT NULL)
  
BEGIN

    RAISERROR(N'Záznam je blokován jiným uživatelem - nelze smazat!', 16, 1)
RETURN

  END
  BEGIN TRAN
    SELECT @CisloOrg=CisloOrg FROM TabCisOrg WHERE TabCisOrg.ID=@ID
	
  BEGIN TRY    

      DELETE FROM TabBankSpojeniArch
       FROM TabBankSpojeniArch a 
      JOIN TabBankSpojeni s ON s.ID = a.IDBankSpoj
      WHERE s.IDOrg=@ID

    DELETE TabBankSpojeni WHERE IDOrg=@ID
    DELETE TabDICOrgArch
       FROM TabDICOrgArch a
       JOIN TabDICOrg d ON d.ID = a.IDDICOrg 
       WHERE d.CisloOrg=@ID

    DELETE TabCisOrgArch WHERE CisloOrg=@CisloOrg     
    DELETE TabDICOrg WHERE CisloOrg=@CisloOrg
    DELETE TabVztahSkupOrg WHERE IDcisorg=@CisloOrg
    DELETE TabCisOrgArch WHERE CisloOrg=@CisloOrg
    DELETE TabMaKarOrganizace WHERE IdCisOrg =@CisloOrg
    DELETE TabMaPrZaOrganizace WHERE IdCisOrg =@CisloOrg
    DELETE TabAkceZakazOrg WHERE CisloOrg =@CisloOrg
    DELETE TabIdentKartaOrg WHERE CisloOrg =@CisloOrg
    DELETE TabBodoveKontoOrg WHERE CisloOrg =@CisloOrg
    DELETE TabBodoveKontoUprava WHERE CisloOrg =@CisloOrg
    DELETE TabVScontoOrg WHERE IDOrg=@CisloOrg
    DELETE TabSlOrg WHERE CisloOrg=@CisloOrg
    DELETE TabSkupZboOrgSlevy WHERE CisloOrg=@CisloOrg
    DELETE TabKontakty WHERE IDOrg=@CisloOrg
    DELETE TabVztahOrgKOs WHERE IDOrg=@CisloOrg
    DELETE TabCisOrg WHERE (TabCisOrg.ID=@ID)
    COMMIT
  END TRY

BEGIN CATCH
--     SELECT ERROR_MESSAGE(), @@ERROR
--  IF @@ERROR<>0 ROLLBACK ELSE COMMIT
       RAISERROR(N'Na záznam jsou navázány další údaje - nalze smazat !',16,1)
             IF @@TRANCOUNT > 0 ROLLBACK
END CATCH
GO

