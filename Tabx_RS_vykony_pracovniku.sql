USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_vykony_pracovniku]    Script Date: 02.07.2025 10:13:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_vykony_pracovniku](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Cislo] [int] NOT NULL,
	[OdpracCasAllMesic0] [numeric](19, 6) NULL,
	[OdpracCas105Mesic0] [numeric](19, 6) NULL,
	[OdpracCasOKMesic0] [numeric](19, 6) NULL,
	[OdpracCas7595Mesic0] [numeric](19, 6) NULL,
	[OdpracCas75Mesic0] [numeric](19, 6) NULL,
	[OdpracCasAllMesic1] [numeric](19, 6) NULL,
	[OdpracCas105Mesic1] [numeric](19, 6) NULL,
	[OdpracCasOKMesic1] [numeric](19, 6) NULL,
	[OdpracCas7595Mesic1] [numeric](19, 6) NULL,
	[OdpracCas75Mesic1] [numeric](19, 6) NULL,
	[OdpracCasAllMesic2] [numeric](19, 6) NULL,
	[OdpracCas105Mesic2] [numeric](19, 6) NULL,
	[OdpracCasOKMesic2] [numeric](19, 6) NULL,
	[OdpracCas7595Mesic2] [numeric](19, 6) NULL,
	[OdpracCas75Mesic2] [numeric](19, 6) NULL,
	[OdpracCasAllMesic3] [numeric](19, 6) NULL,
	[OdpracCas105Mesic3] [numeric](19, 6) NULL,
	[OdpracCasOKMesic3] [numeric](19, 6) NULL,
	[OdpracCas7595Mesic3] [numeric](19, 6) NULL,
	[OdpracCas75Mesic3] [numeric](19, 6) NULL,
	[ID_zam] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[Over105CurMonth]  AS (([OdpracCas105Mesic0]/nullif([OdpracCasAllMesic0],(0)))*(100)),
	[Over95CurMonth]  AS (([OdpracCasOKMesic0]/nullif([OdpracCasAllMesic0],(0)))*(100)),
	[Over75CurMonth]  AS (([OdpracCas7595Mesic0]/nullif([OdpracCasAllMesic0],(0)))*(100)),
	[Under75CurMonth]  AS (([OdpracCas75Mesic0]/nullif([OdpracCasAllMesic0],(0)))*(100)),
	[Over105LastMonth]  AS (([OdpracCas105Mesic1]/nullif([OdpracCasAllMesic1],(0)))*(100)),
	[Over95LastMonth]  AS (([OdpracCasOKMesic1]/nullif([OdpracCasAllMesic1],(0)))*(100)),
	[Over75LastMonth]  AS (([OdpracCas7595Mesic1]/nullif([OdpracCasAllMesic1],(0)))*(100)),
	[Under75LastMonth]  AS (([OdpracCas75Mesic1]/nullif([OdpracCasAllMesic1],(0)))*(100)),
	[Over105BefLastMonth]  AS (([OdpracCas105Mesic2]/nullif([OdpracCasAllMesic2],(0)))*(100)),
	[Over95BefLastMonth]  AS (([OdpracCasOKMesic2]/nullif([OdpracCasAllMesic2],(0)))*(100)),
	[Over75BefLastMonth]  AS (([OdpracCas7595Mesic2]/nullif([OdpracCasAllMesic2],(0)))*(100)),
	[Under75BefLastMonth]  AS (([OdpracCas75Mesic2]/nullif([OdpracCasAllMesic2],(0)))*(100)),
	[Over105BefBefLastMonth]  AS (([OdpracCas105Mesic3]/nullif([OdpracCasAllMesic3],(0)))*(100)),
	[Over95BefBefLastMonth]  AS (([OdpracCasOKMesic3]/nullif([OdpracCasAllMesic3],(0)))*(100)),
	[Over75BefBefLastMonth]  AS (([OdpracCas7595Mesic3]/nullif([OdpracCasAllMesic3],(0)))*(100)),
	[Under75BefBefLastMonth]  AS (([OdpracCas75Mesic3]/nullif([OdpracCasAllMesic3],(0)))*(100)),
 CONSTRAINT [PK__Tabx_RS_vykony_pracovniku__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_vykony_pracovniku] ADD  CONSTRAINT [DF__Tabx_RS_vykony_pracovniku__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_vykony_pracovniku] ADD  CONSTRAINT [DF__Tabx_RS_vykony_pracovniku__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

