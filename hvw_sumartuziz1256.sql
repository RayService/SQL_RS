USE [RayService]
GO

/****** Object:  View [dbo].[hvw_sumartuziz1256]    Script Date: 04.07.2025 8:37:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_sumartuziz1256] AS select id,  nukaz,  cislo, popis,  prirses, skupina, druh, atribut, atribut2, atribut3, atribut4, atribut5, atribut6, atribut7,
substring(natribut,6,80) as natribut, substring(natribut2,6,80) as natribut2, substring(natribut3,6,80) as natribut3, substring(natribut4,6,80) as natribut4, substring(natribut5,6,80) as natribut5, substring(natribut6,6,80) as natribut6, 
substring(natribut7,6,80) as natribut7, 
substring(natribut,3,2) as dimenze1, substring(natribut2,3,2) as dimenze2, substring(natribut3,3,2) as dimenze3, substring(natribut4,3,2) as dimenze4, substring(natribut5,3,2) as dimenze5, substring(natribut6,3,2) as dimenze6,
substring(natribut7,3,2) as dimenze7,
 copocitat, copocitat2, copocitat3, copocitat4, copocitat5, copocitat6, copocitat7, copocitat8, copocitat9, 
nsuma1, nsuma2, nsuma3, nsuma4,nsuma5, nsuma6, nsuma7, nsuma8, nsuma9,
typsumace1,  typsumace2, typsumace3, typsumace4, typsumace5, typsumace6, typsumace7, typsumace8, typsumace9, 
slnaz, slnaz2, slnaz3, slnaz4, slnaz5, slnaz6, slnaz7, slnaz8, slnaz9,
 filtrucet, filtrdoklad, datumod, datumdo, datzmeny, dataktual, autor, datporizeni, zmenil, blokovanieditoru, substring(filtr,1,1000) as filtr255, slqdotaz 
from aprevfa  where typ='S' and isnull(cislo,0)<>0
GO

