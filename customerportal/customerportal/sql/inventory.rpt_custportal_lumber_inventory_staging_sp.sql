USE [invman]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inventory].[rpt_custportal_lumber_inventory_staging_sp]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [inventory].[rpt_custportal_lumber_inventory_staging_sp]
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==================================================================================================
-- Author:		Grant Schulte
-- Create date: 2013-06-26
-- Description: Returns data for use by the Inventory (Lumber) report on the customer portal
-- Updated by:	
-- Update Date: 
-- Update Description: 
-- ==================================================================================================

CREATE PROCEDURE [inventory].[rpt_custportal_lumber_inventory_staging_sp]
AS
BEGIN

	SET NOCOUNT ON;

	declare @today_less_35 datetime = convert(date, getdate() - 35)


	-- load process table from v_lumber view
		truncate table [process].[cp_vlumber];

		INSERT INTO [process].[cp_vlumber]
			   ([product_id],[master_product_id],[product_class],[master_product],[product],[dimension],[species],[grade],
				[drying],[planing],[pcs_pkg],[variable_item],[number_of_items],[bdft_per_lift],[length],[master_no_piece],[division_id])
		select [product_id],[master_product_id],[product_class],[master_product],[product],[dimension],[species],[grade],
				[drying],[planing],[pcs_pkg],[variable_item],[number_of_items],[bdft_per_lift],[length],[master_no_piece],[division_id]
		from product.v_lumber l 
		where division_id > -1; 

	-- load process table from product_detail and other tables
		truncate table [process].[cp_pdtl];

		INSERT INTO [process].[cp_pdtl]
			   ([customer_id],[sales_rep_id],[number_of_items],[number_of_r_items],[variable_item_id],[quantity],[waybill_id],[product_id],[order_type],
				[order_number],[order_id],[customer_reference],[due_date],[destination],[mill_id],[product_group_id],[product_group],[branch_code])
		SELECT o.customer_id, 
			  o.sales_rep_id, 
			  p.number_of_items, 
			  p.number_of_r_items, 
			  p.variable_item_id, 
			  pd.quantity, 
			  pd.waybill_id, 
			  p.product_id, 
			  o.order_type, 
			  o.order_number, 
			  o.order_id, 
			  o.customer_reference, 
			  o.due_date, 
			  o.destination, 
			  pd.mill_id,
			  pg.product_group_id,
			  pg.product_group,
			  d.branch_code
		FROM inventory.product_detail AS pd
		INNER JOIN product.product AS p ON pd.product_id = p.product_id 
		LEFT OUTER JOIN inventory.product_division_group AS pdg ON p.product_id = pdg.product_id AND pd.division_id = pdg.division_id 
		LEFT OUTER JOIN inventory.product_group AS pg ON pdg.product_group_id = pg.product_group_id AND pd.division_id = pg.division_id 
		INNER JOIN product.product_item AS i ON p.variable_item_id = i.product_item_id 
		INNER JOIN inventory.orders AS o ON pd.order_id = o.order_id 
		INNER JOIN inventory.customer AS c ON o.customer_id = c.location_id AND o.division_id = c.division_id 
		INNER JOIN inventory.sales_rep AS s ON o.sales_rep_id = s.sales_rep_id 
		INNER JOIN rdata.division d on d.division_id = pd.division_id
		WHERE (pd.cancelled = 'n') AND 
			 (o.cancelled = 'n') and 
			 o.order_date < getdate(); --@today_less_35;


	-- load process table from inventory_transaction and other tables
	truncate table [process].[cp_vinventory];

	INSERT INTO [process].[cp_vinventory]
           ([inventory_transaction_id],[customer_name],[mill_name],[sales_rep],[waybill],[division_id],[waybill_id]
           ,[waybill_date],[number_of_items],[rpt_item_count],[trk_item_count],[customer_id],[product_id],[sales_rep_id]
           ,[package_name],[is_package],[customer_reference],[product_group],[product_name],[variable_item],[length]
           ,[transaction_date],[piece_count],[mill_id],[variable_item_id],[product_group_id],[master_product_id],[master_product],[branch_code])
	select distinct 
		i.inventory_transaction_id,
		c.customer_name, 
		m.mill_name, 
		s.last_name + ', ' + s.first_name AS sales_rep, 
		w.waybill,
		i.division_id, 
		w.waybill_id, 
		w.waybill_date, 
		p.number_of_items, 
		p.number_of_r_items * i.quantity AS rpt_item_count, 
		i.quantity AS trk_item_count, 
		ii.customer_id, 
		p.product_id, 
		ii.sales_rep_id, 
		w.package_name,
		w.is_package,
		o.customer_reference, 
		pg.product_group, 
		p.descript AS product_name, 
		vi.descript AS variable_item, 
		p.length, 
		i.transaction_date, 
		i.quantity * p.number_of_items AS piece_count, 
		ii.mill_id, 
		p.variable_item_id, 
		pg.product_group_id, 
		p.master_product_id,
		mp.descript AS master_product,
		d.branch_code
	FROM inventory.inventory_transaction i
	INNER JOIN (SELECT DISTINCT 
				inventory_transaction_id, 
				linked_waybill_id, 
				order_id 
			  FROM inventory.product_detail pro) pd ON i.inventory_transaction_id = pd.inventory_transaction_id 
	INNER JOIN inventory.orders o ON pd.order_id = o.order_id 
	INNER JOIN inventory.inventory_item ii ON i.inventory_item_id = ii.inventory_item_id 
	INNER JOIN product.product p ON ii.product_id = p.product_id 
	INNER JOIN product.master_product mp ON p.master_product_id = mp.master_product_id 
	INNER JOIN product.product_item vi ON p.variable_item_id = vi.product_item_id 
	INNER JOIN inventory.product_division_group pdg ON p.product_id = pdg.product_id AND ii.division_id = pdg.division_id 
	INNER JOIN inventory.product_group pg ON pdg.product_group_id = pg.product_group_id 
	INNER JOIN inventory.sales_rep s ON ii.sales_rep_id = s.sales_rep_id AND ii.division_id = s.division_id
	INNER JOIN inventory.mill m on ii.mill_id = m.mill_id AND ii.division_id = m.division_id
	INNER JOIN inventory.customer AS c ON ii.customer_id = c.location_id AND ii.division_id = c.division_id
	INNER JOIN inventory.waybill AS w ON ii.waybill_id = w.waybill_id 
	INNER JOIN rdata.division d on i.division_id = d.division_id
	WHERE i.transaction_date < getdate() and --@today_less_35 and 
		 i.inventory_transaction_id <> 0; 


--create table #lumberinventory (
--	order_status varchar(50),
--	customer_id int,
--	customer_name varchar(500), 
--	sales_rep_id int,
--	sales_rep varchar(150), 
--	mill_name varchar(100),
--	order_number varchar(50),
--	customer_reference varchar(30), 
--	date_io datetime,
--	product_group_id int,
--	product_group varchar(15),
--	master_no_piece varchar(100), 
--	number_of_items int,
--	variable_item varchar(100),
--	[length] numeric(19,3),
--	measure int,  
--	fbm numeric(19,3),  
--	lift_count int,
--	branch_code varchar(8)
--);

--insert into #lumberinventory (order_status,customer_id,customer_name,sales_rep_id,sales_rep,mill_name,order_number,customer_reference,date_io,product_group_id,
--								product_group,master_no_piece, number_of_items,variable_item,[length],measure,fbm,lift_count,branch_code)
	SELECT 'On Ground' as order_status,
		  i.customer_id,
		  i.customer_name, 
		  i.sales_rep_id,
		  i.sales_rep, 
		  i.mill_name,
		  i.waybill as order_number,
		  o.customer_reference, 
		  i.waybill_date as date_io,
		  i.product_group_id,
		  i.product_group,
		  l.master_no_piece, 
		  i.number_of_items,
		  l.variable_item,
		  l.length,
		  wt.wt_per_m as measure,  
		  sum(rpt_item_count) as fbm,  
		  SUM(trk_item_count) as lift_count,
		  i.branch_code

	--into #lumberinventory

	FROM process.cp_vinventory i 
	inner join process.cp_vlumber l on i.product_id = l.product_id 
	INNER JOIN inventory.waybill w on i.waybill_id = w.waybill_id 
	INNER JOIN inventory.orders o on w.order_id = o.order_id 
	left join (SELECT w.waybill_id, 
			 CONVERT(int, ROUND(w.actual_weight * 1000 / p.number_of_r_items, 0)) AS wt_per_m
			 FROM inventory.waybill AS w 
			 INNER JOIN
				(SELECT w.waybill_id,
					  sum(p.number_of_r_items) as number_of_r_items
				FROM inventory.product_detail AS pd
				INNER JOIN product.product AS p ON pd.product_id = p.product_id 
				LEFT OUTER JOIN inventory.waybill AS w ON pd.waybill_id = w.waybill_id
				WHERE     (pd.cancelled = 'n') 
				and pd.plus_minus = '+'
				group by w.waybill_id) AS p ON w.waybill_id = p.waybill_id
			 WHERE w.actual_weight <> 0 AND 
				 p.number_of_r_items <> 0) wt on i.waybill_id = wt.waybill_id 
	WHERE i.division_id <> 0 
	GROUP BY i.customer_id,
			i.customer_name, 
			i.sales_rep_id,
			i.sales_rep,
			mill_name, 
			o.customer_reference, 
			i.waybill_date,
			i.product_group_id,
			i.product_group,
			i.waybill, 
			i.waybill_id, 
			l.master_no_piece, 
			l.variable_item, 
			l.length,
			i.number_of_items,
			wt.wt_per_m,
			i.branch_code
	HAVING SUM(trk_item_count) <> 0 

	UNION 

	SELECT 'Pending' as order_status,
		  c.location_id,
		  c.customer_name, 
		  a.sales_rep_id,
		  s.last_name + ', ' + s.first_name as sales_rep, 
		  CASE WHEN a.mill_id = 0 THEN destination ELSE m.mill_name END as mill_name, 
		  order_number, 
		  customer_reference, 
		  due_date as date_io, 
		  a.product_group_id,
		  a.product_group,
		  master_no_piece, 
		  number_of_items, 
		  variable_item, 
		  length, 
		  lf as measure, 
		  fbm, 
		  lift_count,
		  a.branch_code
	FROM (select pd.order_number, 
			   pd.due_date, 
			   pd.customer_reference, 
			   customer_id, 
			   sales_rep_id, 
			   pd.mill_id, 
			   pd.destination, 
			   pd.product_group_id,
			   pd.product_group,
			   l.master_no_piece, 
			   l.variable_item, 
			   l.length, 
			   l.number_of_items,
			   SUM(pd.quantity * -1) as lift_count, 
			   SUM(pd.quantity * l.number_of_items * -1) as piece_count, 
			   SUM(pd.quantity * l.length * -1) as lf, 
			   sum(pd.quantity * pd.number_of_r_items * -1) as fbm,
			   pd.branch_code
		 FROM process.cp_pdtl pd 
		 inner join process.cp_vlumber l on pd.product_id = l.product_id 
		 LEFT OUTER JOIN inventory.waybill w on pd.waybill_id = w.waybill_id 
		 WHERE pd.order_type = 's' and 
			  (w.export_status is null or w.export_status in (0,1) or (w.posted_date is not null and w.waybill_date >= @today_less_35)) 
		 GROUP BY pd.order_number, 
				pd.order_id,
				pd.due_date,
				pd.customer_reference, 
				pd.customer_id, 
				pd.sales_rep_id,
				pd.mill_id, 
				pd.destination,  
				pd.product_group_id,
				pd.product_group,
				l.master_no_piece, 
				l.number_of_items, 
				l.variable_item, 
				l.length,
				pd.branch_code
		 HAVING SUM(pd.quantity) <> 0 
	 
		 UNION 
	 
		 SELECT pd.order_number, 
			   pd.due_date, 
			   pd.customer_reference, 
			   customer_id, 
			   sales_rep_id, 
			   pd.mill_id, 
			   pd.destination, 
			   pd.product_group_id,
			   pd.product_group,
			   l.master_no_piece, 
			   l.variable_item, 
			   l.length, 
			   l.number_of_items, 
			   SUM(pd.quantity) as lift_count, 
			   SUM(pd.quantity * pd.number_of_items) as piece_count, 
			   SUM(pd.quantity * l.length) as lf, 
			   sum(pd.quantity * pd.number_of_r_items) as fbm,
			   pd.branch_code
		 FROM process.cp_pdtl pd 
		 inner join process.cp_vlumber l on pd.product_id = l.product_id 
		 LEFT OUTER JOIN inventory.waybill w on pd.waybill_id = w.waybill_id 
		 WHERE pd.order_type in ('r','v') and 
			  (w.export_status is null or w.export_status in (0,1) or (w.posted_date is not null and w.waybill_date >= @today_less_35)) 
		 GROUP BY pd.order_number, 
				pd.due_date, 
				pd.customer_reference,
				pd.customer_id, 
				pd.sales_rep_id,
				pd.mill_id, 
				pd.destination, 
				pd.product_group_id,
				pd.product_group,
				l.master_no_piece,  
				l.number_of_items, 
				l.variable_item, 
				l.length,
				pd.branch_code
		 HAVING SUM(pd.quantity) <> 0) a 
	join rdata.division d on d.branch_code = a.branch_code
	join inventory.customer c on a.customer_id = c.location_id AND c.division_id = d.division_id
	join inventory.sales_rep s on a.sales_rep_id = s.sales_rep_id AND s.division_id = d.division_id
	join inventory.mill m on a.mill_id = m.mill_id AND m.division_id = d.division_id
	order by order_status, i.customer_name, i.sales_rep, mill_name, l.master_no_piece


	--drop table #pdtl
	--drop table #vinventory
	--drop table #vlumber


	--select order_status,customer_id,customer_name,sales_rep_id,sales_rep,mill_name,order_number,customer_reference,date_io,product_group_id,
	--		product_group,master_no_piece, number_of_items,variable_item,[length],measure,fbm,lift_count,branch_code
	----into customerportal.invman.lumber_inventory
	--from #lumberinventory


	--drop table #lumberinventory

end

GO



grant execute on [inventory].[rpt_custportal_lumber_inventory_staging_sp] to inv
go



