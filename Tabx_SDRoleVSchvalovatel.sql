USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDRoleVSchvalovatel]    Script Date: 02.07.2025 10:26:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDRoleVSchvalovatel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdRole] [int] NULL,
	[IdSchvalovatel] [int] NULL,
 CONSTRAINT [PK__Tabx_SDRoleVSchvalovatel__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDRoleVSchvalovatel]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_SDRoleVSchvalovatel__IdRole] FOREIGN KEY([IdRole])
REFERENCES [dbo].[Tabx_SDRole] ([ID])
GO

ALTER TABLE [dbo].[Tabx_SDRoleVSchvalovatel] CHECK CONSTRAINT [FK__Tabx_SDRoleVSchvalovatel__IdRole]
GO

