USE [RayService]
GO

/****** Object:  View [dbo].[hvw_58ZurnalspousteniAkci]    Script Date: 03.07.2025 11:11:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_58ZurnalspousteniAkci] AS select *, cast((case when datukonceni is null then null else cast(datediff(millisecond,datporizeni,datukonceni)  as numeric(19,6)) end)/1000 as numeric(19,6)) as dobatrvani, (case when chybatext is null then 0 when isnull(chybatext,'')='' then 1 else 2 end) as stavukonceni from Saperta_Tab_Funkce
GO

