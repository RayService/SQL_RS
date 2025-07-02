USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RayService_MatZodp]    Script Date: 02.07.2025 8:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RayService_MatZodp](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[dilec] [int] NOT NULL,
	[IDPostup] [int] NOT NULL,
	[IDPracovniPozice] [int] NOT NULL,
	[Dimenze] [tinyint] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
 CONSTRAINT [PK__Tabx_RayService_MatZodp__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_RayService_MatZodp__dilec__IDPostup__IDPracovniPozice__Dimenze] UNIQUE NONCLUSTERED 
(
	[dilec] ASC,
	[IDPostup] ASC,
	[IDPracovniPozice] ASC,
	[Dimenze] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RayService_MatZodp] ADD  CONSTRAINT [DF__Tabx_RayService_MatZodp__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RayService_MatZodp] ADD  CONSTRAINT [DF__Tabx_RayService_MatZodp__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

