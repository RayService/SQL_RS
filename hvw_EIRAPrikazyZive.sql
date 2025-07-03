USE [RayService]
GO

/****** Object:  View [dbo].[hvw_EIRAPrikazyZive]    Script Date: 03.07.2025 14:45:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_EIRAPrikazyZive] AS  select TabPrikaz.ID, TabPrikaz.IDPlan as IDPLAN, TabPrikaz.Rada, TabPrikaz.Plan_zadani, TabPrikaz.Plan_ukonceni, 
 TabPrikaz.Poznamka,TabPrikaz.KmenoveStredisko, TabPrikaz.Prikaz, ISNULL(TabPrikaz.kusy_zive,0) AS Kusy_zive
 from RayService.dbo.TabPrikaz 
    where TabPrikaz.IDPlan IN ( 
   SELECT tp.ID AS TPPLANID 
      FROM RayService.dbo.TabPlan tp WITH(NOLOCK) 
        LEFT OUTER JOIN RayService.dbo.TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=tp.IDRezervace 
        where tpz.ID IN ( 
        SELECT TabPohybyZbozi.ID AS TPZID 
        FROM RayService.dbo.TabPohybyZbozi WITH(NOLOCK) 
        LEFT OUTER JOIN RayService.dbo.TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=TabPohybyZbozi.IDDoklad 
        LEFT OUTER JOIN RayService.dbo.TabStavSkladu tss WITH(NOLOCK) ON TabPohybyZbozi.IDZboSklad=tss.ID 
        LEFT OUTER JOIN RayService.dbo.TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID= 
          (SELECT TabStavSkladu.IDKmenZbozi FROM RayService.dbo.TabStavSkladu WHERE TabStavSkladu.ID=TabPohybyZbozi.IDZboSklad) 
        LEFT OUTER JOIN RayService.dbo.TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg IN 
          (SELECT TabDokladyZbozi.CisloOrg FROM RayService.dbo.TabDokladyZbozi WHERE TabDokladyZbozi.ID=TabPohybyZbozi.IDDoklad) 
        LEFT OUTER JOIN RayService.dbo.TabZakazka tz WITH(NOLOCK) ON TabPohybyZbozi.CisloZakazky=tz.CisloZakazky 
        LEFT OUTER JOIN RayService.dbo.TabDokladyZbozi tdzorig WITH(NOLOCK) ON tdzorig.ID IN 
          (SELECT OldPohyb.IDDoklad FROM RayService.dbo.TabPohybyZbozi OldPohyb WHERE OldPohyb.ID=TabPohybyZbozi.IDOldPolozka) 
        LEFT OUTER JOIN RayService.dbo.TabCisOrg_EXT tco_EXT WITH(NOLOCK) ON tco_EXT.ID=tco.ID 
        LEFT OUTER JOIN RayService.dbo.TabPohybyZbozi_EXT tpze WITH(NOLOCK) ON tpze.ID=TabPohybyZbozi.ID 
        WHERE 
        ((tdz.DruhPohybuZbo=9)AND (tss.IDSklad=N'200')AND(tdz.DatPovinnostiFa_Y>=2021)) AND 
        ((((TabPohybyZbozi.Mnozstvi - TabPohybyZbozi.MnOdebrane)>0)AND(TabPohybyZbozi.PotvrzDatDod_X<=GETDATE()+30))AND(tdz.Splneno=0)) 
--AND TabPohybyZbozi.ID= 1111111
        AND TabPohybyZbozi.IDDoklad IN (SELECT TabDokladyZbozi.ID 
        FROM RayService.dbo.TabDokladyZbozi WITH(NOLOCK) 
 LEFT OUTER JOIN RayService.dbo.TabDokladyZbozi_EXT WITH(NOLOCK) ON TabDokladyZbozi_EXT.ID=TabDokladyZbozi.ID 
 WHERE 
    ((TabDokladyZbozi.DruhPohybuZbo=9)AND(TabDokladyZbozi.IDSklad='200')AND 
    (TabDokladyZbozi.PoradoveCislo>=0)AND(TabDokladyZbozi.Splneno=0)AND(TabDokladyZbozi.StavRezervace<>N'x'))) 
    ) 
 ) ;

GO

