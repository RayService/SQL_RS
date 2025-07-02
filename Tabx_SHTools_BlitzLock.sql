USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SHTools_BlitzLock]    Script Date: 02.07.2025 10:28:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SHTools_BlitzLock](
	[ServerName] [nvarchar](256) NULL,
	[deadlock_type] [nvarchar](256) NULL,
	[event_date] [datetime] NULL,
	[database_name] [nvarchar](256) NULL,
	[spid] [smallint] NULL,
	[deadlock_group] [nvarchar](256) NULL,
	[query] [xml] NULL,
	[object_names] [xml] NULL,
	[isolation_level] [nvarchar](256) NULL,
	[owner_mode] [nvarchar](256) NULL,
	[waiter_mode] [nvarchar](256) NULL,
	[lock_mode] [nvarchar](256) NULL,
	[transaction_count] [bigint] NULL,
	[client_option_1] [varchar](500) NULL,
	[client_option_2] [varchar](500) NULL,
	[login_name] [nvarchar](256) NULL,
	[host_name] [nvarchar](256) NULL,
	[client_app] [nvarchar](1024) NULL,
	[wait_time] [bigint] NULL,
	[wait_resource] [nvarchar](max) NULL,
	[priority] [smallint] NULL,
	[log_used] [bigint] NULL,
	[last_tran_started] [datetime] NULL,
	[last_batch_started] [datetime] NULL,
	[last_batch_completed] [datetime] NULL,
	[transaction_name] [nvarchar](256) NULL,
	[status] [nvarchar](256) NULL,
	[owner_waiter_type] [nvarchar](256) NULL,
	[owner_activity] [nvarchar](256) NULL,
	[owner_waiter_activity] [nvarchar](256) NULL,
	[owner_merging] [nvarchar](256) NULL,
	[owner_spilling] [nvarchar](256) NULL,
	[owner_waiting_to_close] [nvarchar](256) NULL,
	[waiter_waiter_type] [nvarchar](256) NULL,
	[waiter_owner_activity] [nvarchar](256) NULL,
	[waiter_waiter_activity] [nvarchar](256) NULL,
	[waiter_merging] [nvarchar](256) NULL,
	[waiter_spilling] [nvarchar](256) NULL,
	[waiter_waiting_to_close] [nvarchar](256) NULL,
	[deadlock_graph] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

