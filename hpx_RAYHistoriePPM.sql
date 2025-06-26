USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAYHistoriePPM]    Script Date: 26.06.2025 9:50:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RAYHistoriePPM]  
AS
-- ==============================================================
-- Author:			JOC
-- Create date:		17.4.2011
-- Akce:			 
-- Name:			Historie PPM
-- Description:		
-- ==============================================================
---------------------------------------generovaní řádků externí tabulky--------------------------------------
INSERT INTO Tabx_RAYHistoriePPM(IdOrg)
SELECT TabCisOrg.ID FROM TabCisOrg WHERE TabCisOrg.ID NOT IN (SELECT Tabx_RAYHistoriePPM.IDOrg FROM Tabx_RAYHistoriePPM) 
---------------------------------------deklarace proměných--------------------------------------------------
DECLARE @Mesic INT
DECLARE @Rok INT
---------------------------------------vlastni telo procedury-----------------------------------------------

SELECT  @Mesic=month(DatumDo), @Rok=year(DatumDo) FROM RAY_RozmDatumuPPM_JOC

IF @Rok =2003 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2003 =_RAY_PPMZaObdZbo_JOC, Rok2003V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

IF @Rok =2004 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2004 =_RAY_PPMZaObdZbo_JOC, Rok2004V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

IF @Rok =2005 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2005 =_RAY_PPMZaObdZbo_JOC, Rok2005V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

IF @Rok =2006 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2006 =_RAY_PPMZaObdZbo_JOC, Rok2006V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

IF @Rok =2007 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2007 =_RAY_PPMZaObdZbo_JOC, Rok2007V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

IF @Rok =2008 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2008 =_RAY_PPMZaObdZbo_JOC, Rok2008V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

IF @Rok =2009 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2009 =_RAY_PPMZaObdZbo_JOC, Rok2009V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2010 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rok2010 =_RAY_PPMZaObdZbo_JOC, Rok2010V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

------------------------------
  IF @Rok =2011 AND @Mesic=1
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Leden2011 =_RAY_PPMZaObdZbo_JOC, Leden2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2011 AND @Mesic=2
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Unor2011 =_RAY_PPMZaObdZbo_JOC, Unor2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2011 AND @Mesic=3
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Brezen2011 =_RAY_PPMZaObdZbo_JOC, Brezen2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2011 AND @Mesic=4
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Duben2011 =_RAY_PPMZaObdZbo_JOC, Duben2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2011 AND @Mesic=5
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Kveten2011 =_RAY_PPMZaObdZbo_JOC, Kveten2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2011 AND @Mesic=6
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cerven2011 =_RAY_PPMZaObdZbo_JOC, Cerven2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2011 AND @Mesic=7
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cervenec2011 =_RAY_PPMZaObdZbo_JOC, Cervenec2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2011 AND @Mesic=8
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Srpen2011 =_RAY_PPMZaObdZbo_JOC, Srpen2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2011 AND @Mesic=9
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Zari2011 =_RAY_PPMZaObdZbo_JOC, Zari2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2011 AND @Mesic=10
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rijen2011 =_RAY_PPMZaObdZbo_JOC, Rijen2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2011 AND @Mesic=11
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Listopad2011 =_RAY_PPMZaObdZbo_JOC, Listopad2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2011 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Prosinec2011 =_RAY_PPMZaObdZbo_JOC, Prosinec2011V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end
-------------------------------------

IF @Rok =2012 AND @Mesic=1
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Leden2012 =_RAY_PPMZaObdZbo_JOC, Leden2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2012 AND @Mesic=2
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Unor2012 =_RAY_PPMZaObdZbo_JOC, Unor2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2012 AND @Mesic=3
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Brezen2012 =_RAY_PPMZaObdZbo_JOC, Brezen2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2012 AND @Mesic=4
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Duben2012 =_RAY_PPMZaObdZbo_JOC, Duben2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2012 AND @Mesic=5
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Kveten2012 =_RAY_PPMZaObdZbo_JOC, Kveten2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2012 AND @Mesic=6
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cerven2012 =_RAY_PPMZaObdZbo_JOC, Cerven2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2012 AND @Mesic=7
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cervenec2012 =_RAY_PPMZaObdZbo_JOC, Cervenec2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2012 AND @Mesic=8
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Srpen2012 =_RAY_PPMZaObdZbo_JOC, Srpen2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2012 AND @Mesic=9
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Zari2012 =_RAY_PPMZaObdZbo_JOC, Zari2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2012 AND @Mesic=10
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rijen2012 =_RAY_PPMZaObdZbo_JOC, Rijen2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2012 AND @Mesic=11
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Listopad2012 =_RAY_PPMZaObdZbo_JOC, Listopad2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2012 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Prosinec2012 =_RAY_PPMZaObdZbo_JOC, Prosinec2012V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

----------------------------------------------

IF @Rok =2013 AND @Mesic=1
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Leden2013 =_RAY_PPMZaObdZbo_JOC, Leden2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2013 AND @Mesic=2
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Unor2013 =_RAY_PPMZaObdZbo_JOC, Unor2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2013 AND @Mesic=3
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Brezen2013 =_RAY_PPMZaObdZbo_JOC, Brezen2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2013 AND @Mesic=4
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Duben2013 =_RAY_PPMZaObdZbo_JOC, Duben2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2013 AND @Mesic=5
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Kveten2013 =_RAY_PPMZaObdZbo_JOC, Kveten2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2013 AND @Mesic=6
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cerven2013 =_RAY_PPMZaObdZbo_JOC, Cerven2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2013 AND @Mesic=7
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cervenec2013 =_RAY_PPMZaObdZbo_JOC, Cervenec2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2013 AND @Mesic=8
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Srpen2013 =_RAY_PPMZaObdZbo_JOC, Srpen2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2013 AND @Mesic=9
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Zari2013 =_RAY_PPMZaObdZbo_JOC, Zari2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2013 AND @Mesic=10
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rijen2013 =_RAY_PPMZaObdZbo_JOC, Rijen2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2013 AND @Mesic=11
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Listopad2013 =_RAY_PPMZaObdZbo_JOC, Listopad2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2013 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Prosinec2013 =_RAY_PPMZaObdZbo_JOC, Prosinec2013V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

------------
IF @Rok =2014 AND @Mesic=1
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Leden2014 =_RAY_PPMZaObdZbo_JOC, Leden2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2014 AND @Mesic=2
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Unor2014 =_RAY_PPMZaObdZbo_JOC, Unor2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2014 AND @Mesic=3
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Brezen2014 =_RAY_PPMZaObdZbo_JOC, Brezen2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2014 AND @Mesic=4
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Duben2014 =_RAY_PPMZaObdZbo_JOC, Duben2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end


  IF @Rok =2014 AND @Mesic=5
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Kveten2014 =_RAY_PPMZaObdZbo_JOC, Kveten2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2014 AND @Mesic=6
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cerven2014 =_RAY_PPMZaObdZbo_JOC, Cerven2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2014 AND @Mesic=7
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Cervenec2014 =_RAY_PPMZaObdZbo_JOC, Cervenec2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2014 AND @Mesic=8
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Srpen2014 =_RAY_PPMZaObdZbo_JOC, Srpen2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2014 AND @Mesic=9
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Zari2014 =_RAY_PPMZaObdZbo_JOC, Zari2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2014 AND @Mesic=10
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Rijen2014 =_RAY_PPMZaObdZbo_JOC, Rijen2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2014 AND @Mesic=11
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Listopad2014 =_RAY_PPMZaObdZbo_JOC, Listopad2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end

  IF @Rok =2014 AND @Mesic=12
    begin 
           UPDATE Tabx_RAYHistoriePPM
           SET Prosinec2014 =_RAY_PPMZaObdZbo_JOC, Prosinec2014V =_RAY_PPMZaObdVyr_JOC
           FROM Tabx_RAYHistoriePPM
           LEFT JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID =Tabx_RAYHistoriePPM.IdOrg
    end
GO

