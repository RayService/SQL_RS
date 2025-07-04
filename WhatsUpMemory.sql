USE [RayService]
GO

/****** Object:  View [dbo].[WhatsUpMemory]    Script Date: 04.07.2025 13:11:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW
    [dbo].[WhatsUpMemory]
AS
SELECT TOP (2147483647)
    view_name =
        'WhatsUpMemory',
    database_name =
        DB_NAME(),
    x.schema_name,
    x.object_name,
    x.index_name,
    in_row_pages_mb =
        SUM
        (
            CASE
                WHEN x.type IN (1, 3)
                THEN 1
                ELSE 0
            END
        ) * 8. / 1024.,
    lob_pages_mb =
        SUM
        (
            CASE
                WHEN x.type = 2
                THEN 1
                ELSE 0
            END
        ) * 8. / 1024.,
    buffer_cache_pages_total =
        COUNT_BIG(*)
FROM sys.dm_os_buffer_descriptors AS obd
INNER HASH JOIN
(
    SELECT
        schema_name =
            s.name,
        object_name =
            o.name,
        index_name =
            i.name,
        au.type,
        au.allocation_unit_id
    FROM sys.allocation_units AS au
    JOIN sys.partitions AS p
      ON  au.container_id = p.hobt_id
      AND au.type =1
    JOIN sys.objects AS o
      ON p.object_id = o.object_id
    JOIN sys.indexes AS i
      ON  o.object_id = i.object_id
      AND p.index_id = i.index_id
    JOIN sys.schemas AS s
      ON o.schema_id = s.schema_id
    WHERE au.type > 0
    AND   o.is_ms_shipped = 0

    UNION ALL

    SELECT
        schema_name =
            s.name,
        object_name =
            o.name,
        index_name =
            i.name,
        au.type,
        au.allocation_unit_id
    FROM sys.allocation_units AS au
    JOIN sys.partitions AS p
      ON  au.container_id = p.hobt_id
      AND au.type = 3
    JOIN sys.objects AS o
      ON p.object_id = o.object_id
    JOIN sys.indexes AS i
      ON  o.object_id = i.object_id
      AND p.index_id = i.index_id
    JOIN sys.schemas AS s
      ON o.schema_id = s.schema_id
    WHERE au.type > 0
    AND   o.is_ms_shipped = 0

    UNION ALL

    SELECT
        schema_name =
            s.name,
        object_name =
            o.name,
        index_name =
            i.name,
        au.type,
        au.allocation_unit_id
    FROM sys.allocation_units AS au
    JOIN sys.partitions AS p
      ON  au.container_id = p.partition_id
      AND au.type = 2
    JOIN sys.objects AS o
      ON p.object_id = o.object_id
    JOIN sys.indexes AS i
      ON  o.object_id = i.object_id
      AND p.index_id = i.index_id
    JOIN sys.schemas AS s
      ON o.schema_id = s.schema_id
    WHERE au.type > 0
    AND   o.is_ms_shipped = 0
) AS x
  ON x.allocation_unit_id = obd.allocation_unit_id
GROUP BY
    x.schema_name,
    x.object_name,
    x.index_name
ORDER BY
    COUNT_BIG(*) DESC;
GO

