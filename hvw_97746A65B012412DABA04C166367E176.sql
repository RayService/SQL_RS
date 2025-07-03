USE [RayService]
GO

/****** Object:  View [dbo].[hvw_97746A65B012412DABA04C166367E176]    Script Date: 03.07.2025 12:44:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_97746A65B012412DABA04C166367E176] AS SELECT 
ff.ID AS ID,
ff.ID_master,
ff.ID_slave,
ff.File_ID_master,
ff.File_ID_slave,
ff.Matched,
ff.Result,
ff.Autor,
ff.DatPorizeni,
ff.Zmenil,
ff.DatZmeny,
ff.BlokovaniEditoru,
ff.Marker
FROM AI2helios.dbo.Tabx_RS_Robot_Finder_Found ff WITH(NOLOCK)
GO

