USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDKonfigurace]    Script Date: 02.07.2025 10:23:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDKonfigurace](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PovolitNerealizovane] [bit] NOT NULL,
	[PriznakSchvalenoVOBJ] [bit] NOT NULL,
	[NeprovadetOdemceniVOBJ] [bit] NOT NULL,
	[LogNezapisovatIdentPoznamky] [bit] NOT NULL,
	[PriznakSchvalenoEP] [bit] NOT NULL,
	[NeprovadetOdemceniEP] [bit] NOT NULL,
	[NezobrazovatPotvrzeni] [bit] NOT NULL,
	[NezobrazovatPuvodniPrehledy] [bit] NOT NULL,
 CONSTRAINT [PK__Tabx_SDKonfigurace__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__PovolitNerealizovane]  DEFAULT ((0)) FOR [PovolitNerealizovane]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__PriznakSchvalenoVOBJ]  DEFAULT ((1)) FOR [PriznakSchvalenoVOBJ]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__NeprovadetOdemceniVOBJ]  DEFAULT ((0)) FOR [NeprovadetOdemceniVOBJ]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__LogNezapisovatIdentPoznamky]  DEFAULT ((0)) FOR [LogNezapisovatIdentPoznamky]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__PriznakSchvalenoEP]  DEFAULT ((0)) FOR [PriznakSchvalenoEP]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__NeprovadetOdemceniEP]  DEFAULT ((0)) FOR [NeprovadetOdemceniEP]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__NezobrazovatPotvrzeni]  DEFAULT ((0)) FOR [NezobrazovatPotvrzeni]
GO

ALTER TABLE [dbo].[Tabx_SDKonfigurace] ADD  CONSTRAINT [DF__Tabx_SDKonfigurace__NezobrazovatPuvodniPrehledy]  DEFAULT ((0)) FOR [NezobrazovatPuvodniPrehledy]
GO

