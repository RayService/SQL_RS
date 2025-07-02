USE [HCvicna]
GO

/****** Object:  Table [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment]    Script Date: 02.07.2025 13:48:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderKoeficient] [int] NULL,
	[LastProcessDate] [datetime] NULL,
	[LastChangeDate] [datetime] NULL,
	[Zbozi] [int] NOT NULL,
	[Property] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment]  WITH CHECK ADD  CONSTRAINT [FK62F277DE2E4CB0DE] FOREIGN KEY([Property])
REFERENCES [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property] ([Id])
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment] CHECK CONSTRAINT [FK62F277DE2E4CB0DE]
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment]  WITH CHECK ADD  CONSTRAINT [FK62F277DE9AD43B2A] FOREIGN KEY([Zbozi])
REFERENCES [dbo].[TabKmenZbozi] ([ID])
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment] CHECK CONSTRAINT [FK62F277DE9AD43B2A]
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment]  WITH CHECK ADD  CONSTRAINT [FK6C43A5D52571587C] FOREIGN KEY([Property])
REFERENCES [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property] ([Id])
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment] CHECK CONSTRAINT [FK6C43A5D52571587C]
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment]  WITH CHECK ADD  CONSTRAINT [FK6C43A5D52E975978] FOREIGN KEY([Zbozi])
REFERENCES [dbo].[TabKmenZbozi] ([ID])
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment] CHECK CONSTRAINT [FK6C43A5D52E975978]
GO

