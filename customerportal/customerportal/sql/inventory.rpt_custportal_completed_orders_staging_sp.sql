USE [invman]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inventory].[rpt_custportal_completed_orders_staging_sp]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [inventory].[rpt_custportal_completed_orders_staging_sp]
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==================================================================================================
-- Author:		Grant Schulte
-- Create date: 2013-07-15
-- Description: Stages data for use by the Completed Orders chart on the customer portal dashboard
-- Updated by:	
-- Update Date: 
-- Update Description: 
-- ==================================================================================================

CREATE PROCEDURE [inventory].[rpt_custportal_completed_orders_staging_sp]
AS
BEGIN

	SET NOCOUNT ON;

	declare @14_months_ago datetime;

	set @14_months_ago = convert(datetime, convert(varchar(4), year(getdate())-1) + '-' + right('0' + convert(varchar(2), month(getdate())-1), 2) + '-01')

	select o.customer_id,
		   d.branch_code,
		   year(completion_date)*100 + month(completion_date) as order_date_order,
		   convert(varchar(3), datename(month, completion_date)) + '-' + convert(varchar(4), year(completion_date)) as order_month_display,
		   count(*) as total_orders
	from inventory.orders o
	join rdata.division d on d.division_id = o.division_id
	where o.division_id > 0 and 
		  o.completion_date > @14_months_ago
	group by o.customer_id,
			d.branch_code,
			year(completion_date)*100 + month(completion_date),
			convert(varchar(3), datename(month, completion_date)) + '-' + convert(varchar(4), year(completion_date))
	order by d.branch_code, o.customer_id, year(completion_date)*100 + month(completion_date)

end

GO



grant execute on [inventory].[rpt_custportal_completed_orders_staging_sp] to inv
go



