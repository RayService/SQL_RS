USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDPredpisVRoleVSchvalovatel]    Script Date: 02.07.2025 10:24:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDPredpisVRoleVSchvalovatel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdPredpis] [int] NULL,
	[IdSchvalovatel] [int] NULL,
	[IdRole] [int] NULL,
	[Uroven] [int] NOT NULL,
	[VracetNaPrvniUroven] [bit] NULL,
 CONSTRAINT [PK__Tabx_SDPredpisVRoleVSchvalovatel__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisVRoleVSchvalovatel] ADD  CONSTRAINT [DF__Tabx_SDPredpisVRoleVSchvalovatel__VracetNaPrvniUroven]  DEFAULT ((0)) FOR [VracetNaPrvniUroven]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisVRoleVSchvalovatel]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_SDPredpisVRoleVSchvalovatel__IdPredpis] FOREIGN KEY([IdPredpis])
REFERENCES [dbo].[Tabx_SDPredpisy] ([ID])
GO

ALTER TABLE [dbo].[Tabx_SDPredpisVRoleVSchvalovatel] CHECK CONSTRAINT [FK__Tabx_SDPredpisVRoleVSchvalovatel__IdPredpis]
GO

ALTER TABLE [dbo].[Tabx_SDPredpisVRoleVSchvalovatel]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_SDPredpisVRoleVSchvalovatel__IdRole] FOREIGN KEY([IdRole])
REFERENCES [dbo].[Tabx_SDRole] ([ID])
GO

ALTER TABLE [dbo].[Tabx_SDPredpisVRoleVSchvalovatel] CHECK CONSTRAINT [FK__Tabx_SDPredpisVRoleVSchvalovatel__IdRole]
GO

