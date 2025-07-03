USE [RayService]
GO

/****** Object:  View [dbo].[hvw_FAC360B002EC46ED9A4D4F24726E5751]    Script Date: 03.07.2025 14:49:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_FAC360B002EC46ED9A4D4F24726E5751] AS SELECT 
TabJC.ID,
TabJC.DatPorizeni_X,
kz.Skupzbo AS _Skupina,
kz.RegCis AS _RegCislo,
kz.Nazev1 AS _Zbozi,
kz.Nazev2 AS _Zbozi2,
TabJC.IDStavSkladu,
TabJC.EcCelkem,
TabJC.Mnozstvi,
TabStrom.Nazev,
'EcJc' = 
      CASE 
         WHEN TabJC.EcJc>0 THEN TabJC.EcJc
         ELSE (select top 1 JCevid from TabPohybyZbozi where TabPohybyZbozi.IDZboSklad=TabJC.IDStavSkladu order by DatPorizeni desc)
      END
,(SELECT TabStavSkladu.IDSklad FROM TabStavSkladu WHERE TabStavSkladu.ID = TabJC.IDStavSkladu) AS _Sklad
FROM TabJC
left outer join TabStavSkladu ss on ss.Id=TabJC.IdStavSkladu
left outer join TabKmenZbozi kz on ss.IdKmenZbozi=kz.Id
left outer join TabStrom on ss.IDSklad=TabStrom.Cislo
GO

