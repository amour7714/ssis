USE [arrowkpi]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[process].[merge_telus_mobility_staging_into_kpi_sp]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [process].[merge_telus_mobility_staging_into_kpi_sp]
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =================================================================================================================
-- Author:		Grant Schulte
-- Create date: 2013-09-25
-- Description: Merges data from [staging].[telus_mobility_group_summary] into [kpi].[telus_mobility_group_summary]
-- Updated by:	
-- Update Date: 
-- Update Description: 
-- =================================================================================================================

CREATE PROCEDURE [process].[merge_telus_mobility_staging_into_kpi_sp]
AS
BEGIN

	SET NOCOUNT ON;

	declare @batch_id int;
	
	select @batch_id = isnull(max(batch_id), 0) + 1 from kpi.telus_mobility_group_summary;

	INSERT INTO [kpi].[telus_mobility_group_summary]
           ([phone_number]
           ,[username]
           ,[additional_username]
           ,[service_plan_name]
           ,[service_plan_price]
           ,[additional_local_airtime]
           ,[over_under]
           ,[contribution_to_pool]
           ,[service_plans_pooled]
           ,[service_plans_not_pooled]
           ,[long_distance_charges]
           ,[roaming_charges]
           ,[do_more_data_services]
           ,[do_more_voice_services]
           ,[pager_services]
           ,[value_added_services]
           ,[other_charges_and_credits]
           ,[other_fees]
           ,[pst_qst_hst]
           ,[subtotal_before_gst]
           ,[gst]
           ,[total]
           ,[billing_year]
           ,[billing_month]
           ,[batch_id])
	SELECT [phone_number]
		  ,[username]
		  ,[additional_username]
		  ,[service_plan_name]
		  ,[service_plan_price]
		  ,[additional_local_airtime]
		  ,[over_under]
		  ,[contribution_to_pool]
		  ,[service_plans_pooled]
		  ,[service_plans_not_pooled]
		  ,[long_distance_charges]
		  ,[roaming_charges]
		  ,[do_more_data_services]
		  ,[do_more_voice_services]
		  ,[pager_services]
		  ,[value_added_services]
		  ,[other_charges_and_credits]
		  ,[other_fees]
		  ,[pst_qst_hst]
		  ,[subtotal_before_gst]
		  ,[gst]
		  ,[total]
		  ,year(getdate()) as billing_year
		  ,month(getdate()) as billing_month
		  ,@batch_id as batch_id
	  FROM [staging].[telus_mobility_group_summary]

end

GO


grant execute on [process].[merge_telus_mobility_staging_into_kpi_sp] to dwssis
go