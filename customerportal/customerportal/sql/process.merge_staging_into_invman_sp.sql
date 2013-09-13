USE [customerportal]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[process].[merge_staging_into_invman_sp]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [process].[merge_staging_into_invman_sp]
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===============================================================================================
-- Author:	 Grant Schulte
-- Create date: 2013-09-06
-- Description: Inserts or Updates data in the invman schema tables from the staging schema tables 
-- Updated by:	
-- Update Date: 
-- Update Description:	
-- ===============================================================================================

CREATE PROCEDURE [process].[merge_staging_into_invman_sp]
AS
BEGIN

	SET NOCOUNT ON;


	-- insert new and update existing data in [invman].[v_waybill_wtperm] ********************************
	MERGE [invman].[v_waybill_wtperm] AS i
		USING (select distinct [waybill_id], [wt_per_m] from [staging].[v_waybill_wtperm]) AS s
		ON i.[waybill_id] = s.[waybill_id]
	WHEN MATCHED AND (s.[wt_per_m] <> i.[wt_per_m])
	THEN
		UPDATE SET
		i.[wt_per_m] = s.[wt_per_m],
		i.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT ([waybill_id], [wt_per_m], date_added, date_last_updated)
		VALUES (s.[waybill_id], s.[wt_per_m], GETDATE(), NULL);



	-- insert new and update existing data in [invman].[v_waybill_wtperm] ********************************
	MERGE [invman].[v_lumber] AS i
		USING (select distinct product_id, master_product_id, product_class, master_product, product, 
							   dimension, species, grade, drying, planing, pcs_pkg, variable_item, 
							   number_of_items, bdft_per_lift, [length], master_no_piece, division_id 
			   from [staging].[v_lumber]) AS s
		ON i.product_id = s.product_id
	WHEN MATCHED AND (s.master_product_id <> i.master_product_id OR
					  s.product_class <> i.product_class OR
					  s.master_product <> i.master_product OR
					  s.product <> i.product OR
					  s.dimension <> i.dimension OR
					  s.species <> i.species OR
					  s.grade <> i.grade OR
					  s.drying <> i.drying OR
					  s.planing <> i.planing OR
					  s.pcs_pkg <> i.pcs_pkg OR
					  s.variable_item <> i.variable_item OR
					  s.number_of_items <> i.number_of_items OR
					  s.bdft_per_lift <> i.bdft_per_lift OR
					  s.[length] <> i.[length] OR
					  s.master_no_piece <> i.master_no_piece OR
					  s.division_id <> i.division_id)
	THEN
		UPDATE SET
			i.master_product_id = s.master_product_id,
			i.product_class = s.product_class,
			i.master_product = s.master_product,
			i.product = s.product,
			i.dimension = s.dimension,
			i.species = s.species,
			i.grade = s.grade,
			i.drying = s.drying,
			i.planing = s.planing,
			i.pcs_pkg = s.pcs_pkg,
			i.variable_item = s.variable_item,
			i.number_of_items = s.number_of_items,
			i.bdft_per_lift = s.bdft_per_lift,
			i.[length] = s.[length],
			i.master_no_piece = s.master_no_piece,
			i.division_id = s.division_id,
			i.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (product_id, master_product_id, product_class, master_product, product, dimension, species, 
				grade, drying, planing, pcs_pkg, variable_item, number_of_items, bdft_per_lift, length, 
				master_no_piece, division_id, date_added, date_last_updated)
		VALUES (s.product_id, s.master_product_id, s.product_class, s.master_product, s.product, s.dimension,
				s.species, s.grade, s.drying, s.planing, s.pcs_pkg, s.variable_item, s.number_of_items,
				s.bdft_per_lift, s.[length], s.master_no_piece, s.division_id, GETDATE(), NULL);



	-- insert new and update existing data in [invman].[pdtl] ***************************************
	MERGE [invman].[pdtl] AS i
		USING (select distinct product_detail_id, customer_id, sales_rep_id, number_of_items, number_of_r_items, 
							   variable_item_id, quantity, waybill_id, product_id, order_type, order_number, 
							   order_id, customer_reference, due_date, destination, mill_id, mill_name, 
							   customer_name, sales_rep, division_id, branch_code, order_date, product_group_id, 
							   product_group, export_status, posted_date, waybill_date
			   from [staging].[pdtl]) AS s
		ON i.product_detail_id = s.product_detail_id
	WHEN MATCHED AND (s.customer_id <> i.customer_id OR
					  s.sales_rep_id <> i.sales_rep_id OR
					  s.number_of_items <> i.number_of_items OR
					  s.number_of_r_items <> i.number_of_r_items OR
					  s.variable_item_id <> i.variable_item_id OR
					  s.quantity <> i.quantity OR
					  s.waybill_id <> i.waybill_id OR
					  s.product_id <> i.product_id OR
					  s.order_type <> i.order_type OR
					  s.order_number <> i.order_number OR
					  s.order_id <> i.order_id OR
					  s.customer_reference <> i.customer_reference OR
					  s.due_date <> i.due_date OR
					  s.destination <> i.destination OR
					  s.mill_id <> i.mill_id OR
					  s.mill_name <> i.mill_name OR
					  s.customer_name <> i.customer_name OR
					  s.sales_rep <> i.sales_rep OR
					  s.division_id <> i.division_id OR
					  s.branch_code <> i.branch_code OR
					  s.order_date <> i.order_date OR
					  s.product_group_id <> i.product_group_id OR
					  s.product_group <> i.product_group OR
					  s.export_status <> i.export_status OR
					  s.posted_date <> i.posted_date OR
					  s.waybill_date <> i.waybill_date)
	THEN
		UPDATE SET
			i.customer_id = s.customer_id,
			i.sales_rep_id = s.sales_rep_id,
			i.number_of_items = s.number_of_items,
			i.number_of_r_items = s.number_of_r_items,
			i.variable_item_id = s.variable_item_id,
			i.quantity = s.quantity,
			i.waybill_id = s.waybill_id,
			i.product_id = s.product_id,
			i.order_type = s.order_type,
			i.order_number = s.order_number,
			i.order_id = s.order_id,
			i.customer_reference = s.customer_reference,
			i.due_date = s.due_date,
			i.destination = s.destination,
			i.mill_id = s.mill_id,
			i.mill_name = s.mill_name,
			i.customer_name = s.customer_name,
			i.sales_rep = s.sales_rep,
			i.division_id = s.division_id,
			i.branch_code = s.branch_code,
			i.order_date = s.order_date,
			i.product_group_id = s.product_group_id,
			i.product_group = s.product_group,
			i.export_status = s.export_status,
			i.posted_date = s.posted_date,
			i.waybill_date = s.waybill_date,
			i.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (product_detail_id, customer_id, sales_rep_id, number_of_items, number_of_r_items, variable_item_id, 
				quantity, waybill_id, product_id, order_type, order_number, order_id, customer_reference, due_date, 
				destination, mill_id, mill_name, customer_name, sales_rep, division_id, branch_code, order_date, 
				product_group_id, product_group, export_status, posted_date, waybill_date, date_added, date_last_updated)
		VALUES (s.product_detail_id, s.customer_id, s.sales_rep_id, s.number_of_items, s.number_of_r_items, s.variable_item_id, 
				s.quantity, s.waybill_id, s.product_id, s.order_type, s.order_number, s.order_id, s.customer_reference, s.due_date, 
				s.destination, s.mill_id, s.mill_name, s.customer_name, s.sales_rep, s.division_id, s.branch_code, s.order_date, 
				s.product_group_id, s.product_group, s.export_status, s.posted_date, s.waybill_date, GETDATE(), NULL);



	-- insert new and update existing data in [invman].[inventory_trx] ********************************
	MERGE [invman].[inventory_trx] AS i
		USING (select distinct inventory_transaction_id, customer_name, mill_name, sales_rep, waybill, package_name, is_package, 
							   customer_reference, order_customer_reference, division_id, branch_code, waybill_id, waybill_date, 
							   product_group_id, product_group, product_id, product_name, variable_item, [length], number_of_items, 
							   transaction_date, rpt_item_count, trk_item_count, piece_count, customer_id, mill_id, sales_rep_id, 
							   variable_item_id, master_product_id, master_product
			   from [staging].[inventory_trx]) AS s
		ON i.inventory_transaction_id = s.inventory_transaction_id
	WHEN MATCHED AND (s.customer_name <> i.customer_name OR
					  s.mill_name <> i.mill_name OR
					  s.sales_rep <> i.sales_rep OR
					  s.waybill <> i.waybill OR
					  s.package_name <> i.package_name OR
					  s.is_package <> i.is_package OR
					  s.customer_reference <> i.customer_reference OR
					  s.order_customer_reference <> i.order_customer_reference OR
					  s.division_id <> i.division_id OR
					  s.branch_code <> i.branch_code OR
					  s.waybill_id <> i.waybill_id OR
					  s.waybill_date <> i.waybill_date OR
					  s.product_group_id <> i.product_group_id OR
					  s.product_group <> i.product_group OR
					  s.product_id <> i.product_id OR
					  s.product_name <> i.product_name OR
					  s.variable_item <> i.variable_item OR
					  s.[length] <> i.[length] OR
					  s.number_of_items <> i.number_of_items OR
					  s.transaction_date <> i.transaction_date OR
					  s.rpt_item_count <> i.rpt_item_count OR
					  s.trk_item_count <> i.trk_item_count OR
					  s.piece_count <> i.piece_count OR
					  s.customer_id <> i.customer_id OR
					  s.mill_id <> i.mill_id OR
					  s.sales_rep_id <> i.sales_rep_id OR
					  s.variable_item_id <> i.variable_item_id OR
					  s.master_product_id <> i.master_product_id OR
					  s.master_product <> i.master_product)
	THEN
		UPDATE SET
			i.customer_name = s.customer_name,
			i.mill_name = s.mill_name,
			i.sales_rep = s.sales_rep,
			i.waybill = s.waybill,
			i.package_name = s.package_name,
			i.is_package = s.is_package,
			i.customer_reference = s.customer_reference,
			i.order_customer_reference = s.order_customer_reference,
			i.division_id = s.division_id,
			i.branch_code = s.branch_code,
			i.waybill_id = s.waybill_id,
			i.waybill_date = s.waybill_date,
			i.product_group_id = s.product_group_id,
			i.product_group = s.product_group,
			i.product_id = s.product_id,
			i.product_name = s.product_name,
			i.variable_item = s.variable_item,
			i.[length] = s.[length],
			i.number_of_items = s.number_of_items,
			i.transaction_date = s.transaction_date,
			i.rpt_item_count = s.rpt_item_count,
			i.trk_item_count = s.trk_item_count,
			i.piece_count = s.piece_count,
			i.customer_id = s.customer_id,
			i.mill_id = s.mill_id,
			i.sales_rep_id = s.sales_rep_id,
			i.variable_item_id = s.variable_item_id,
			i.master_product_id = s.master_product_id,
			i.master_product = s.master_product,
			i.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (inventory_transaction_id, customer_name, mill_name, sales_rep, waybill, package_name, is_package, 
				customer_reference, order_customer_reference, division_id, branch_code, waybill_id, waybill_date, 
				product_group_id, product_group, product_id, product_name, variable_item, [length], number_of_items, 
				transaction_date, rpt_item_count, trk_item_count, piece_count, customer_id, mill_id, sales_rep_id, 
				variable_item_id, master_product_id, master_product, date_added, date_last_updated)
		VALUES (s.inventory_transaction_id, s.customer_name, s.mill_name, s.sales_rep, s.waybill, s.package_name, s.is_package, 
				s.customer_reference, s.order_customer_reference, s.division_id, s.branch_code, s.waybill_id, s.waybill_date, 
				s.product_group_id, s.product_group, s.product_id, s.product_name, s.variable_item, s.[length], s.number_of_items, 
				s.transaction_date, s.rpt_item_count, s.trk_item_count, s.piece_count, s.customer_id, s.mill_id, s.sales_rep_id, 
				s.variable_item_id, s.master_product_id, s.master_product, GETDATE(), NULL);


end
go



grant execute on [process].[merge_staging_into_invman_sp] to custportalssis
go