USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SHTools_RecompileTug]    Script Date: 04.07.2025 8:27:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SHTools_RecompileTug] AS SELECT 
ID = object_id
,object_name = CAST(name as nvarchar(128))
,schema_name = SCHEMA_NAME(schema_id)
,type_desc
,type 
FROM sys.objects
WHERE type IN
	(
		'FN' /* SQL scalar function */
		,'IF' /* SQL inline table-valued function */
		,'P'  /* SQL Stored Procedure */
		,'V'  /* View */
		,'TF' /* SQL table-valued-function */
		,'TR' /* SQL DML trigger */
		,'RF' /* Replication-filter-procedure */
		,'U' /* Table (user-defined) */
	)
GO

