USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_AppsMonitor]    Script Date: 02.07.2025 8:59:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_AppsMonitor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[spid] [int] NOT NULL,
	[ip_address] [nvarchar](32) NOT NULL,
	[application] [nvarchar](50) NULL,
	[tablet_name] [nvarchar](50) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[api_version] [nvarchar](5) NULL,
	[endpoint] [nvarchar](510) NULL,
	[url_path] [nvarchar](510) NULL,
	[duration_ms] [int] NULL,
	[received_data] [ntext] NULL,
	[received_data_255]  AS (substring(replace(substring([received_data],(1),(255)),nchar((13))+nchar((10)),nchar((32))),(1),(255))),
	[auth_token] [nvarchar](60) NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny])))),
	[IDZam] [int] NULL,
 CONSTRAINT [PK__Tabx_RS_AppsMonitor__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_AppsMonitor] ADD  CONSTRAINT [DF__Tabx_RS_AppsMonitor__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_AppsMonitor] ADD  CONSTRAINT [DF__Tabx_RS_AppsMonitor__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_AppsMonitor]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_AppsMonitor__IDZam] FOREIGN KEY([IDZam])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_AppsMonitor] CHECK CONSTRAINT [FK__Tabx_RS_AppsMonitor__IDZam]
GO

