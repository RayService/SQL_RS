USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_Apps_QaDefectReportFile]    Script Date: 02.07.2025 8:17:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_Apps_QaDefectReportFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[defectReportId] [int] NOT NULL,
	[title] [nvarchar](2) NOT NULL,
	[extension] [nvarchar](4) NOT NULL,
	[size] [int] NOT NULL,
 CONSTRAINT [PK__Tabx_Apps_QaDefectReportFile__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReportFile]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_Apps_QaDefectReportFile__defectReportId] FOREIGN KEY([defectReportId])
REFERENCES [dbo].[Tabx_Apps_QaDefectReport] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Tabx_Apps_QaDefectReportFile] CHECK CONSTRAINT [FK__Tabx_Apps_QaDefectReportFile__defectReportId]
GO

