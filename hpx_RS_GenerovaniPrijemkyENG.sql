USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniPrijemkyENG]    Script Date: 26.06.2025 10:56:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--nejprve je nutné ve slepé uložence dbo.ep_EvidenceMezdAZmetku zavolat EXEC dbo.hpx_RS_GenerovaniPrijemkyENG @IDMzdy

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniPrijemkyENG]
	@IDMzdy INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		MŽ
-- Description:	Procedura na odvedení dílce Engineering na sklad
-- Date: 22.6.2021
-- =============================================

DECLARE @IDPrikaz INT;
DECLARE @IDDilec INT;
DECLARE @Mnozstvi NUMERIC(19,2);
DECLARE @IDZakazka INT;
DECLARE @DatPorizeni DATETIME;
DECLARE @OdvadeciOperace BIT;
--sety
SET @DatPorizeni=GETDATE();
SET @IDPrikaz=(SELECT tpmz.IDPrikaz FROM TabPrikazMzdyAZmetky tpmz WHERE tpmz.ID=@IDMzdy);
SET @IDZakazka=(SELECT P.IDZakazka FROM TabPrikaz P WHERE P.ID=@IDPrikaz);
SET @IDDilec=(SELECT P.IDTabKmen FROM TabPrikaz P WHERE P.ID=@IDPrikaz);
SET @Mnozstvi=(SELECT tpmz.kusy_odv FROM TabPrikazMzdyAZmetky tpmz WHERE tpmz.ID=@IDMzdy);
SET @OdvadeciOperace=(SELECT tpp.Odvadeci 
						FROM TabPrikazMzdyAZmetky WITH(NOLOCK)
						LEFT OUTER JOIN TabPrPostup tpp WITH(NOLOCK) ON TabPrikazMzdyAZmetky.IDPrikaz=tpp.IDPrikaz AND TabPrikazMzdyAZmetky.DokladPrPostup=tpp.Doklad AND TabPrikazMzdyAZmetky.AltPrPostup=tpp.Alt AND tpp.IDOdchylkyDo IS NULL
						WHERE TabPrikazMzdyAZmetky.ID=@IDMzdy)
IF OBJECT_ID(N'tempdb..#TabGenPrijem') IS NOT NULL DROP TABLE #TabGenPrijem
IF OBJECT_ID(N'tempdb..#TabOdved') IS NOT NULL DROP TABLE #TabOdved
IF OBJECT_ID(N'tempdb..#TabVyrCisProGenOdv') IS NOT NULL DROP TABLE #TabVyrCisProGenOdv
-- docasna tabulka za normalnich okolnosti generovana HeO
IF OBJECT_ID('tempdb..#TabTempUziv') IS NULL
CREATE TABLE #TabTempUziv(
[Tabulka] [varchar] (255) NOT NULL,
[SCOPE_IDENTITY] [int] NULL,
[Datum] [datetime] NULL
);
--řada příjemek 595
--sklad pro odvedení 20000275900
--podmínka, že operace je odváděcí
IF @OdvadeciOperace=1
BEGIN

CREATE TABLE #TabGenPrijem(ID int) --zde uloženka zapíše IDčka nového záznamu z TabDokladyZbozi

CREATE TABLE #TabOdved(
ID int IDENTITY(1,1) NOT NULL,
IDPrikaz int NOT NULL,
IDDilec int NOT NULL,
IDZakazModif int NULL,
Sklad nvarchar(30) COLLATE database_default NOT NULL, 
mnozstvi numeric(19,6) NOT NULL, 
KodUmisteni nvarchar(15) COLLATE database_default NULL, 
IDZakazka int NULL,
IDPohZbo int NULL,
PRIMARY KEY (ID)) 
INSERT INTO #TabOdved (IDPrikaz,IDDilec,IDZakazModif,Sklad,mnozstvi,KodUmisteni,IDZakazka)
VALUES( @IDPrikaz, @IDDilec, NULL, '20000275900', @Mnozstvi, NULL, @IDZakazka)

CREATE TABLE #TabVyrCisProGenOdv(
ID int IDENTITY(1,1) NOT NULL, 
IDOdvedeni int NOT NULL, --ID z #TabOdved
IDPrikaz int NOT NULL, --ID z TabPrikaz
VyrCislo nvarchar(25) COLLATE database_default NOT NULL, 
Mnozstvi numeric(19,6) NOT NULL, 
MaxMnozstvi numeric(19,6) NULL,
IDVyrCP int NULL, --zde uloženka zapíše IDčko nového záznamu z TabVyrCP
PRIMARY KEY (ID)) 

EXEC dbo.hp_PrednabidniTabVyrCisProGenOdv @ProIDPrikaz=@IDPrikaz

EXEC hp_OdvedeniPrikazu @RadaDokladu='595',@KonecneOdvedeni=0,@DatPorizeni=@DatPorizeni,@SekejZakazky=1,@SekejPrikazy=1

END;

GO

