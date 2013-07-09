USE [invman]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [process].[cp_vlumber](
	[product_id] [int] NOT NULL,
	[master_product_id] [int] NOT NULL,
	[product_class] [varchar](100) NOT NULL,
	[master_product] [varchar](1000) NOT NULL,
	[product] [varchar](1000) NOT NULL,
	[dimension] [varchar](100) NOT NULL,
	[species] [varchar](100) NOT NULL,
	[grade] [varchar](100) NOT NULL,
	[drying] [varchar](100) NOT NULL,
	[planing] [varchar](100) NOT NULL,
	[pcs_pkg] [varchar](100) NOT NULL,
	[variable_item] [varchar](100) NOT NULL,
	[number_of_items] [int] NOT NULL,
	[bdft_per_lift] [numeric](19, 3) NOT NULL,
	[length] [numeric](25, 8) NULL,
	[master_no_piece] [varchar](100) NULL,
	[division_id] [int] NOT NULL
) ON [PRIMARY]

GO



CREATE TABLE [process].[cp_pdtl](
	[customer_id] [int] NOT NULL,
	[sales_rep_id] [int] NOT NULL,
	[number_of_items] [int] NOT NULL,
	[number_of_r_items] [numeric](19, 3) NOT NULL,
	[variable_item_id] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[waybill_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[order_type] [varchar](10) NOT NULL,
	[order_number] [varchar](50) NOT NULL,
	[order_id] [int] NOT NULL,
	[customer_reference] [varchar](30) NOT NULL,
	[due_date] [datetime] NOT NULL,
	[destination] [varchar](25) NOT NULL,
	[mill_id] [int] NOT NULL,
	[product_group_id] [int] NULL,
	[product_group] [varchar](15) NULL,
	[branch_code] [varchar](8) NOT NULL
) ON [PRIMARY]

GO



CREATE TABLE [process].[cp_vinventory](
	[inventory_transaction_id] [int] NOT NULL,
	[customer_name] [varchar](500) NOT NULL,
	[mill_name] [varchar](100) NOT NULL,
	[sales_rep] [varchar](102) NOT NULL,
	[waybill] [varchar](50) NOT NULL,
	[division_id] [int] NOT NULL,
	[waybill_id] [int] NOT NULL,
	[waybill_date] [datetime] NOT NULL,
	[number_of_items] [int] NOT NULL,
	[rpt_item_count] [numeric](29, 3) NULL,
	[trk_item_count] [numeric](9, 0) NOT NULL,
	[customer_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[sales_rep_id] [int] NOT NULL,
	[package_name] [varchar](50) NULL,
	[is_package] [bit] NULL,
	[customer_reference] [varchar](30) NOT NULL,
	[product_group] [varchar](15) NOT NULL,
	[product_name] [varchar](1000) NOT NULL,
	[variable_item] [varchar](100) NOT NULL,
	[length] [numeric](19, 3) NOT NULL,
	[transaction_date] [datetime] NOT NULL,
	[piece_count] [numeric](20, 0) NULL,
	[mill_id] [int] NOT NULL,
	[variable_item_id] [int] NOT NULL,
	[product_group_id] [int] NOT NULL,
	[master_product_id] [int] NOT NULL,
	[master_product] [varchar](1000) NOT NULL,
	[branch_code] [varchar](8) NOT NULL
) ON [PRIMARY]

GO


SET ANSI_PADDING ON
GO


