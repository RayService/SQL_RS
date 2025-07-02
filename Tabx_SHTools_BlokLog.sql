USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SHTools_BlokLog]    Script Date: 02.07.2025 10:31:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SHTools_BlokLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDSber] [int] NOT NULL,
	[event_time] [datetime2](7) NULL,
	[database_name] [nvarchar](128) NULL,
	[currentdbname] [nvarchar](256) NULL,
	[contentious_object] [nvarchar](4000) NULL,
	[activity] [varchar](8) NULL,
	[blocking_tree] [varchar](8000) NULL,
	[spid] [int] NULL,
	[ecid] [int] NULL,
	[query_text] [xml] NULL,
	[wait_time_ms] [bigint] NULL,
	[status] [nvarchar](10) NULL,
	[isolation_level] [nvarchar](50) NULL,
	[lock_mode] [nvarchar](10) NULL,
	[resource_owner_type] [nvarchar](256) NULL,
	[transaction_count] [int] NULL,
	[transaction_name] [nvarchar](512) NULL,
	[last_transaction_started] [datetime2](7) NULL,
	[last_transaction_completed] [datetime2](7) NULL,
	[client_option_1] [varchar](261) NULL,
	[client_option_2] [varchar](307) NULL,
	[wait_resource] [nvarchar](100) NULL,
	[priority] [int] NULL,
	[log_used] [bigint] NULL,
	[client_app] [nvarchar](256) NULL,
	[host_name] [nvarchar](256) NULL,
	[login_name] [nvarchar](256) NULL,
	[transaction_id] [bigint] NULL,
	[blocked_process_report] [xml] NULL,
 CONSTRAINT [PK__Tabx_SHTools_BlokLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SHTools_BlokLog]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_SHTools_BlokLog__IDSber] FOREIGN KEY([IDSber])
REFERENCES [dbo].[Tabx_SHTools_BlokLogSber] ([ID])
GO

ALTER TABLE [dbo].[Tabx_SHTools_BlokLog] CHECK CONSTRAINT [FK__Tabx_SHTools_BlokLog__IDSber]
GO

