USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotVKonfiguraceUzivatele]    Script Date: 02.07.2025 8:37:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotVKonfiguraceUzivatele](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdKonfigurace] [int] NOT NULL,
	[LoginName] [nvarchar](128) NULL,
 CONSTRAINT [PK__Tabx_BalikobotVKonfiguraceUzivatele__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVKonfiguraceUzivatele]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotVKonfiguraceUzivatele__IdKonfigurace] FOREIGN KEY([IdKonfigurace])
REFERENCES [dbo].[Tabx_BalikobotKonfigurace] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotVKonfiguraceUzivatele] CHECK CONSTRAINT [FK__Tabx_BalikobotVKonfiguraceUzivatele__IdKonfigurace]
GO

