USE [HCvicna]
GO

/****** Object:  Table [dbo].[TabCisZam_EXT]    Script Date: 02.07.2025 13:25:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TabCisZam_EXT](
	[ID] [int] NOT NULL,
	[_KodZamestnance] [nvarchar](20) NULL,
	[_Redenge_RedengeKit_Maps_EmployeeColor] [int] NULL,
	[_RadPrac] [bit] NULL,
	[_zpcsob] [bit] NULL,
	[_Redenge_LastChangeDate] [datetime] NULL,
	[_Redenge_LastProcessDate] [datetime] NULL,
	[_PinTab] [nvarchar](4) NULL,
	[_PinMzda] [nvarchar](4) NULL,
	[_KvalZam] [nvarchar](2) NULL,
	[_EXT_B2ADIMA_IsTHP] [bit] NULL,
	[_operatorHermle] [bit] NULL,
	[_EXKvalZam] [nvarchar](3) NULL,
	[_GDPRSouhl] [nvarchar](25) NULL,
	[_EXT_B2ADIMA_WorkplaceId] [int] NULL,
	[_predak] [bit] NULL,
	[_zastupce] [bit] NULL,
	[_datumZadosti] [datetime] NULL,
	[_typZadosti] [nvarchar](40) NULL,
	[_datumVyreseni] [datetime] NULL,
	[_EXT_B2ADIMA_ProductionUnitId] [int] NULL,
	[_Odd] [nvarchar](4) NULL,
	[_Skup] [nvarchar](10) NULL,
	[_EXT_RS_recommended_by] [int] NULL,
	[_DS_RS_vyroba_rezim_VP] [nvarchar](6) NULL,
	[_EXT_RS_zamestnanci_lokalita_obed] [nvarchar](30) NULL,
	[_EXT_RS_zamesntanci_lokalita_tym] [nvarchar](30) NULL,
	[_EXT_RS_ComFunction] [int] NULL,
	[_EXT_RS_ComLanguage] [int] NULL,
	[_EXT_RS_workplace_IDForeman] [int] NULL,
	[_EXT_RS_workplace_IDWorkplace] [int] NULL,
	[_EXT_RS_Kooperant] [int] NULL,
	[_EXT_RS_ZamSKCislo] [int] NULL,
	[_EXT_RS_CisloDodatku] [int] NULL,
	[_EXT_RS_KVyplaceniDne] [datetime] NULL,
	[_EXT_RS_workplace_IDDispatcher] [int] NULL,
 CONSTRAINT [PK__TabCisZam_EXT__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

