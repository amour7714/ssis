USE [customerportal]
GO

/****** Object:  Schema [staging]    Script Date: 2013-09-09 9:39:59 AM ******/
CREATE SCHEMA [staging]
GO





USE [customerportal]
GO

/****** Object:  Table [staging].[inventory_trx]    Script Date: 2013-09-09 8:35:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [staging].[inventory_trx](
	[inventory_transaction_id] [int] NULL,
	[customer_name] [varchar](500) NULL,
	[mill_name] [varchar](100) NULL,
	[sales_rep] [varchar](102) NULL,
	[waybill] [varchar](50) NULL,
	[package_name] [varchar](50) NULL,
	[is_package] [bit] NULL,
	[customer_reference] [varchar](30) NULL,
	[order_customer_reference] [varchar](30) NULL,
	[division_id] [int] NULL,
	[branch_code] [varchar](8) NULL,
	[waybill_id] [int] NULL,
	[waybill_date] [datetime] NULL,
	[product_group_id] [int] NULL,
	[product_group] [varchar](15) NULL,
	[product_id] [int] NULL,
	[product_name] [varchar](1000) NULL,
	[variable_item] [varchar](100) NULL,
	[length] [numeric](19, 3) NULL,
	[number_of_items] [int] NULL,
	[transaction_date] [datetime] NULL,
	[rpt_item_count] [numeric](29, 3) NULL,
	[trk_item_count] [numeric](9, 0) NULL,
	[piece_count] [numeric](20, 0) NULL,
	[customer_id] [int] NULL,
	[mill_id] [int] NULL,
	[sales_rep_id] [int] NULL,
	[variable_item_id] [int] NULL,
	[master_product_id] [int] NULL,
	[master_product] [varchar](1000) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [customerportal]
GO

/****** Object:  Table [staging].[pdtl]    Script Date: 2013-09-09 8:35:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [staging].[pdtl](
	[product_detail_id] [int] NULL,
	[customer_id] [int] NULL,
	[sales_rep_id] [int] NULL,
	[number_of_items] [int] NULL,
	[number_of_r_items] [numeric](19, 3) NULL,
	[variable_item_id] [int] NULL,
	[quantity] [int] NULL,
	[waybill_id] [int] NULL,
	[product_id] [int] NULL,
	[order_type] [varchar](10) NULL,
	[order_number] [varchar](50) NULL,
	[order_id] [int] NULL,
	[customer_reference] [varchar](30) NULL,
	[due_date] [datetime] NULL,
	[destination] [varchar](25) NULL,
	[mill_id] [int] NULL,
	[mill_name] [varchar](100) NULL,
	[customer_name] [varchar](500) NULL,
	[sales_rep] [varchar](102) NULL,
	[division_id] [int] NULL,
	[branch_code] [varchar](8) NULL,
	[order_date] [datetime] NULL,
	[product_group_id] [int] NULL,
	[product_group] [varchar](15) NULL,
	[export_status] [int] NULL,
	[posted_date] [datetime] NULL,
	[waybill_date] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



USE [customerportal]
GO

/****** Object:  Table [staging].[v_lumber]    Script Date: 2013-09-09 8:35:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [staging].[v_lumber](
	[product_id] [int] NULL,
	[master_product_id] [int] NULL,
	[product_class] [varchar](100) NULL,
	[master_product] [varchar](1000) NULL,
	[product] [varchar](1000) NULL,
	[dimension] [varchar](100) NULL,
	[species] [varchar](100) NULL,
	[grade] [varchar](100) NULL,
	[drying] [varchar](100) NULL,
	[planing] [varchar](100) NULL,
	[pcs_pkg] [varchar](100) NULL,
	[variable_item] [varchar](100) NULL,
	[number_of_items] [int] NULL,
	[bdft_per_lift] [numeric](19, 3) NULL,
	[length] [numeric](25, 8) NULL,
	[master_no_piece] [varchar](100) NULL,
	[division_id] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



USE [customerportal]
GO

/****** Object:  Table [staging].[v_waybill_wtperm]    Script Date: 2013-09-09 8:35:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[v_waybill_wtperm](
	[waybill_id] [int] NULL,
	[wt_per_m] [int] NULL
) ON [PRIMARY]

GO




USE [customerportal]
GO

/****** Object:  Table [invman].[inventory_trx]    Script Date: 2013-09-09 8:36:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [invman].[inventory_trx](
	[inventory_transaction_id] [int] NOT NULL,
	[customer_name] [varchar](500) NULL,
	[mill_name] [varchar](100) NULL,
	[sales_rep] [varchar](102) NULL,
	[waybill] [varchar](50) NULL,
	[package_name] [varchar](50) NULL,
	[is_package] [bit] NULL,
	[customer_reference] [varchar](30) NULL,
	[order_customer_reference] [varchar](30) NULL,
	[division_id] [int] NULL,
	[branch_code] [varchar](8) NULL,
	[waybill_id] [int] NULL,
	[waybill_date] [datetime] NULL,
	[product_group_id] [int] NULL,
	[product_group] [varchar](15) NULL,
	[product_id] [int] NULL,
	[product_name] [varchar](1000) NULL,
	[variable_item] [varchar](100) NULL,
	[length] [numeric](19, 3) NULL,
	[number_of_items] [int] NULL,
	[transaction_date] [datetime] NULL,
	[rpt_item_count] [numeric](29, 3) NULL,
	[trk_item_count] [numeric](9, 0) NULL,
	[piece_count] [numeric](20, 0) NULL,
	[customer_id] [int] NULL,
	[mill_id] [int] NULL,
	[sales_rep_id] [int] NULL,
	[variable_item_id] [int] NULL,
	[master_product_id] [int] NULL,
	[master_product] [varchar](1000) NULL,
	[date_added] [datetime] NOT NULL,
	[date_last_updated] [datetime] NULL,
 CONSTRAINT [PK_invman_inventory_trx] PRIMARY KEY CLUSTERED 
(
	[inventory_transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




USE [customerportal]
GO

/****** Object:  Table [invman].[pdtl]    Script Date: 2013-09-09 8:36:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [invman].[pdtl](
	[product_detail_id] [int] NOT NULL,
	[customer_id] [int] NULL,
	[sales_rep_id] [int] NULL,
	[number_of_items] [int] NULL,
	[number_of_r_items] [numeric](19, 3) NULL,
	[variable_item_id] [int] NULL,
	[quantity] [int] NULL,
	[waybill_id] [int] NULL,
	[product_id] [int] NULL,
	[order_type] [varchar](10) NULL,
	[order_number] [varchar](50) NULL,
	[order_id] [int] NULL,
	[customer_reference] [varchar](30) NULL,
	[due_date] [datetime] NULL,
	[destination] [varchar](25) NULL,
	[mill_id] [int] NULL,
	[mill_name] [varchar](100) NULL,
	[customer_name] [varchar](500) NULL,
	[sales_rep] [varchar](102) NULL,
	[division_id] [int] NULL,
	[branch_code] [varchar](8) NULL,
	[order_date] [datetime] NULL,
	[product_group_id] [int] NULL,
	[product_group] [varchar](15) NULL,
	[export_status] [int] NULL,
	[posted_date] [datetime] NULL,
	[waybill_date] [datetime] NULL,
	[date_added] [datetime] NOT NULL,
	[date_last_updated] [datetime] NULL,
 CONSTRAINT [PK_invman_pdtl] PRIMARY KEY CLUSTERED 
(
	[product_detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




USE [customerportal]
GO

/****** Object:  Table [invman].[v_lumber]    Script Date: 2013-09-09 8:37:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [invman].[v_lumber](
	[product_id] [int] NOT NULL,
	[master_product_id] [int] NULL,
	[product_class] [varchar](100) NULL,
	[master_product] [varchar](1000) NULL,
	[product] [varchar](1000) NULL,
	[dimension] [varchar](100) NULL,
	[species] [varchar](100) NULL,
	[grade] [varchar](100) NULL,
	[drying] [varchar](100) NULL,
	[planing] [varchar](100) NULL,
	[pcs_pkg] [varchar](100) NULL,
	[variable_item] [varchar](100) NULL,
	[number_of_items] [int] NULL,
	[bdft_per_lift] [numeric](19, 3) NULL,
	[length] [numeric](25, 8) NULL,
	[master_no_piece] [varchar](100) NULL,
	[division_id] [int] NULL,
	[date_added] [datetime] NOT NULL,
	[date_last_updated] [datetime] NULL,
 CONSTRAINT [PK_invman_v_lumber] PRIMARY KEY CLUSTERED 
(
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




USE [customerportal]
GO

/****** Object:  Table [invman].[v_waybill_wtperm]    Script Date: 2013-09-09 8:37:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [invman].[v_waybill_wtperm](
	[waybill_id] [int] NOT NULL,
	[wt_per_m] [int] NOT NULL,
	[date_added] [datetime] NOT NULL,
	[date_last_updated] [datetime] NULL,
 CONSTRAINT [PK_invman_v_waybill_wtperm] PRIMARY KEY CLUSTERED 
(
	[waybill_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


