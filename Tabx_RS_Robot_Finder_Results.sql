USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_Robot_Finder_Results]    Script Date: 02.07.2025 9:46:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_Robot_Finder_Results](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[File_ID] [nvarchar](255) NOT NULL,
	[TDKK_01] [int] NULL,
	[TDKK_02] [int] NULL,
	[TDKK_03] [int] NULL,
	[TDKK_04] [int] NULL,
	[TDKK_05] [int] NULL,
	[TDKK_06] [int] NULL,
	[TDKK_07] [int] NULL,
	[TDV_00_univ] [int] NULL,
	[TDV_01] [int] NULL,
	[TDV_02] [int] NULL,
	[TDV_03] [int] NULL,
	[TDV_04] [int] NULL,
	[TDV_05] [int] NULL,
	[TDV_06] [int] NULL,
	[TDV_07_ATUM] [int] NULL,
	[DVC_01] [int] NULL,
	[DVC_02] [int] NULL,
	[DVC_03] [int] NULL,
	[DVC_04] [int] NULL,
	[DVC_05] [int] NULL,
	[SWITCH] [int] NULL,
	[END_00] [int] NULL,
	[END_01] [int] NULL,
	[END_02] [int] NULL,
	[END_03] [int] NULL,
	[END_04] [int] NULL,
	[END_05] [int] NULL,
	[PLG] [int] NULL,
	[RCE] [int] NULL,
	[CHINCH] [int] NULL,
	[DSUB] [int] NULL,
	[IND] [int] NULL,
	[SureSeal] [int] NULL,
	[RUSP] [int] NULL,
	[RUSU] [int] NULL,
	[RFP] [int] NULL,
	[RFU] [int] NULL,
	[IMG] [int] NULL,
	[IMGP] [int] NULL,
	[IMGU] [int] NULL,
	[SPIRAL] [int] NULL,
	[Key_Pos] [int] NULL,
	[Key_Pos_DSUB] [int] NULL,
	[Bushing] [int] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DVC_02_90] [int] NULL,
	[END_05_plus] [int] NULL,
	[PLG_90_st] [int] NULL,
	[PLG_90_st_] [int] NULL,
	[DSUB_90_st] [int] NULL,
	[Rel_st] [int] NULL,
	[TDKK_09] [int] NULL,
 CONSTRAINT [PK__Tabx_RS_Robot_Finder_Results__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_Robot_Finder_Results] ADD  CONSTRAINT [DF__Tabx_RS_Robot_Finder_Results__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_Robot_Finder_Results] ADD  CONSTRAINT [DF__Tabx_RS_Robot_Finder_Results__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

