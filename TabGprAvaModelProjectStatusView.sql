USE [RayService]
GO

/****** Object:  View [dbo].[TabGprAvaModelProjectStatusView]    Script Date: 04.07.2025 11:07:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabGprAvaModelProjectStatusView] AS 
SELECT ID, Code, 
       Description=convert(NVArchar(255),Description), 
       Name=convert(NVArchar(255),Name), 
       Status=convert(NVArchar(255),Status),
       StatusExternalID=convert(NVArchar(100),Description),
       AVAExternalID=convert(NVArchar(255),AVAExternalID),
       AVAReferenceID=convert(NVArchar(40),AVAReferenceID)
FROM
(
    SELECT ID=1,Code=N'Proposed', 
           Description='Proposed', 
           Name=N'Proposed', 
           Status='Proposed',
           StatusExternalID='Proposed.ProjectStatusType.00000000-0000-0000-0000-000000000000',
           AVAExternalID='',
           AVAReferenceID='BAAC0F94-D7E8-4022-B525-3FD74833DCA1' 
    UNION ALL
    SELECT ID=2,Code=N'Done', 
           Description='Done', 
           Name=N'Done', 
           Status='Done',
           StatusExternalID='Done.ProjectStatusType.00000000-0000-0000-0000-000000000000',
           AVAExternalID='',
           AVAReferenceID='BBD73F39-73B5-467F-AD08-E3F767301EFA' 
) as v
GO

