USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_RS_zakazka_Novy]    Script Date: 26.06.2025 10:36:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosZOOM_RS_zakazka_Novy]
@CisloZakazky NVARCHAR(15),
@Nazev NVARCHAR(255),
@DruhyNazev NVARCHAR(255),
@Prijemce INT,
@PrijemceMU INT,
@Zadavatel INT,
@Stav NVARCHAR(15),
@Zodpovida INT,
@_EXT_RS_datum_prezkumu DATETIME,
@_Predmet NVARCHAR(10),
@_Komodita NVARCHAR(10),
@_ZakSeg NVARCHAR(40),
@_ZakTech NVARCHAR(40),
@_ZakOpak NVARCHAR(40),
@_PocKus NVARCHAR(20),
@_TermReal NVARCHAR(50),
@_TermNab DATETIME,
@_EXT_RS_narocnost_kalkulace NVARCHAR(30),
@_EXT_RS_objem_vyroby NVARCHAR(30),
@_EXT_RS_rentabilita NVARCHAR(30),
@_EXT_RS_seriovy_potencial NVARCHAR(30),
@_EXT_RS_aspekt NVARCHAR(30),
@_InfNak NVARCHAR(20),
@_CenTerm NVARCHAR(10),
@_Licence NVARCHAR(10),
@_AAR BIT,
@_projekt BIT,
@_VaVPozn NTEXT
AS
BEGIN
INSERT INTO TabZakazka (CisloZakazky,Rada,Stav,Priorita,Identifikator,VerejnaZakazka, Nazev,DruhyNazev,Prijemce,PrijemceMU,Zadavatel,Zodpovida)
SELECT @CisloZakazky,N'100',@Stav,N'',N'',0,@Nazev,@DruhyNazev,@Prijemce,@PrijemceMU,@Zadavatel,@Zodpovida
SELECT SCOPE_IDENTITY()
INSERT INTO TabZakazka_EXT (ID,_EXT_RS_datum_prezkumu,_Predmet,_Komodita,_ZakSeg,_ZakTech,_ZakOpak,_PocKus,_TermReal,_TermNab,_EXT_RS_narocnost_kalkulace,_EXT_RS_objem_vyroby,_EXT_RS_rentabilita,_EXT_RS_seriovy_potencial,_EXT_RS_aspekt,_InfNak,_CenTerm,_Licence,_AAR,_projekt,_VaVPozn)
VALUES (SCOPE_IDENTITY(),@_EXT_RS_datum_prezkumu,@_Predmet,@_Komodita,@_ZakSeg,@_ZakTech,@_ZakOpak,@_PocKus,@_TermReal,@_TermNab,@_EXT_RS_narocnost_kalkulace,@_EXT_RS_objem_vyroby,@_EXT_RS_rentabilita,@_EXT_RS_seriovy_potencial,@_EXT_RS_aspekt,@_InfNak,@_CenTerm,@_Licence,@_AAR,@_projekt,@_VaVPozn)
END
GO

