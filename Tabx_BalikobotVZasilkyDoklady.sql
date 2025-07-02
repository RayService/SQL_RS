USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotVZasilkyDoklady]    Script Date: 02.07.2025 8:37:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdZasilky] [int] NOT NULL,
	[IdDoklad] [int] NOT NULL,
	[MasterDoklad] [bit] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotVZasilkyDoklady__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady] ADD  CONSTRAINT [DF__Tabx_BalikobotVZasilkyDoklady__MasterDoklad]  DEFAULT ((0)) FOR [MasterDoklad]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady] ADD  CONSTRAINT [DF__Tabx_BalikobotVZasilkyDoklady__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady] ADD  CONSTRAINT [DF__Tabx_BalikobotVZasilkyDoklady__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotVZasilkyDoklady__IdDoklad] FOREIGN KEY([IdDoklad])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady] CHECK CONSTRAINT [FK__Tabx_BalikobotVZasilkyDoklady__IdDoklad]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotVZasilkyDoklady__IdZasilky] FOREIGN KEY([IdZasilky])
REFERENCES [dbo].[Tabx_BalikobotZasilky] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotVZasilkyDoklady] CHECK CONSTRAINT [FK__Tabx_BalikobotVZasilkyDoklady__IdZasilky]
GO

