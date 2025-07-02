USE [HCvicna]
GO

/****** Object:  Table [dbo].[GTabVyskladneni]    Script Date: 02.07.2025 13:08:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GTabVyskladneni](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[Nazev] [nvarchar](30) NULL,
	[DatumVyskladneniPozad] [datetime] NULL,
	[Uzavreno] [bit] NOT NULL,
	[MistoVyskladneni] [nvarchar](100) NULL,
 CONSTRAINT [PK__GTabVyskladneni__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GTabVyskladneni] ADD  CONSTRAINT [DF__GTabVyskladneni__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[GTabVyskladneni] ADD  CONSTRAINT [DF__GTabVyskladneni__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

