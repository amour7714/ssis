USE [CoreReports]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[kpi_finance_trx_counts_monthly_sp]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[kpi_finance_trx_counts_monthly_sp]
go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================================
-- Author:		Grant Schulte
-- Create date: 2013-08-08
-- Description:	Generates the data for the monthly finance trx counts KPI
-- =============================================================================================
CREATE PROCEDURE [dbo].[kpi_finance_trx_counts_monthly_sp]
AS
BEGIN

	--SET NOCOUNT ON;

	declare @start_date varchar(19) = '2011-03-31 11:59:59'

	create table #temp (
		finance_function varchar(100),
		calendar_month char(7),
		transaction_count int
	)

-- PAYROLL ******************************************************************************************
	insert #temp
	select    'PAYROLL' as finance_function
			, convert(varchar(4), datename(yyyy, PayEndingDate)) + '-' + RIGHT('0'+convert(varchar(2), datepart(mm, PayEndingDate)),2) as calendar_month
			, count(*) as transaction_count 
	from ARROWAVA.dbo.History_Detail
	where PayEndingDate > @start_date
	group by convert(varchar(4), datename(yyyy, PayEndingDate)) + '-' + RIGHT('0'+convert(varchar(2), datepart(mm, PayEndingDate)),2)
	order by convert(varchar(4), datename(yyyy, PayEndingDate)) + '-' + RIGHT('0'+convert(varchar(2), datepart(mm, PayEndingDate)),2)


-- ACCOUNTS RECEIVABLE ***********************************************************************************************
	-- get list of company databases that have AR installed

	declare @sql varchar(8000),
			@dbname varchar(128)
	
	-- create temp table to store the names of databases that have AR installed
	select [db_name]
	into #db_ar
	from Epicor_Control.dbo.ewcomp
	where 0=1;
	
	-- get list of all company databases
	declare cur_dblist cursor for
		select [db_name]
		from Epicor_Control.dbo.ewcomp; 
		
	open cur_dblist;
	
	FETCH NEXT FROM cur_dblist INTO @dbname;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @sql = 
			'IF EXISTS (SELECT * FROM ' + @dbname + '.sys.objects WHERE object_id = OBJECT_ID(N''[' + @dbname + '].[dbo].[artrxage]'') AND type in (N''U''))
				insert into #db_ar values (''' + @dbname + ''')';
		
		exec (@sql);
			
		FETCH NEXT FROM cur_dblist INTO @dbname;
	END
	
	close cur_dblist;
	deallocate cur_dblist;
	
	declare cur_dbar cursor for
		select [db_name] from #db_ar;
	
	open cur_dbar;
	
	FETCH NEXT FROM cur_dbar INTO @dbname;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @sql = 
			'insert #temp
				select finance_function		= ''AR''
					 , calendar_month		= convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)
					 , transaction_count	= count(*)
				from ' + @dbname + '.dbo.artrxage
				where CoreReports.dbo.fnJulianToGregorianDate(date_applied) > ''' + @start_date + '''
				group by convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)
			';

		exec (@sql);
		
		FETCH NEXT FROM cur_dbar INTO @dbname;
	END
	
	drop table #db_ar;


-- ACCOUNTS PAYABLE ***********************************************************************************************
	-- get list of company databases that have AP installed
	
	-- create temp table to store the names of databases that have AP installed
	select [db_name]
	into #db_ap
	from Epicor_Control.dbo.ewcomp
	where 0=1;
	
	-- get list of all company databases
	declare cur_dblist cursor for
		select [db_name]
		from Epicor_Control.dbo.ewcomp; 
		
	open cur_dblist;
	
	FETCH NEXT FROM cur_dblist INTO @dbname;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @sql = 
			'IF EXISTS (SELECT * FROM ' + @dbname + '.sys.objects WHERE object_id = OBJECT_ID(N''[' + @dbname + '].[dbo].[apvodet]'') AND type in (N''U'')) AND EXISTS
					   (SELECT * FROM ' + @dbname + '.sys.objects WHERE object_id = OBJECT_ID(N''[' + @dbname + '].[dbo].[appydet]'') AND type in (N''U'')) AND EXISTS
					   (SELECT * FROM ' + @dbname + '.sys.objects WHERE object_id = OBJECT_ID(N''[' + @dbname + '].[dbo].[apdmdet]'') AND type in (N''U''))
				insert into #db_ap values (''' + @dbname + ''')';
		
		exec (@sql);
			
		FETCH NEXT FROM cur_dblist INTO @dbname;
	END
	
	close cur_dblist;
	deallocate cur_dblist;
	
	declare cur_dbap cursor for
		select [db_name] from #db_ap;
	
	open cur_dbap;
	
	FETCH NEXT FROM cur_dbap INTO @dbname;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @sql = 
			'insert #temp
				select ''AP'' as finance_function, convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2) as calendar_month, count(*) as transaction_count
				from ' + @dbname + '.dbo.apvodet d 
				join ' + @dbname + '.dbo.apvohdr_all h on d.trx_ctrl_num = h.trx_ctrl_num 
				where CoreReports.dbo.fnJulianToGregorianDate(date_applied) > ''' + @start_date + '''
				group by convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)
				order by convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)

				insert #temp
				select ''AP'' as finance_function,convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2) as calendar_month, count(*) as transaction_count
				from ' + @dbname + '.dbo.appydet 
				where CoreReports.dbo.fnJulianToGregorianDate(date_applied) > ''' + @start_date + '''
				group by convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)
				order by convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)

				insert #temp
				select ''AP'' as finance_function, convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2) as calendar_month, count(*) as transaction_count
				from ' + @dbname + '.dbo.apdmdet d 
				join ' + @dbname + '.dbo.apdmhdr_all h on d.trx_ctrl_num = h.trx_ctrl_num 
				where CoreReports.dbo.fnJulianToGregorianDate(date_applied) > ''' + @start_date + '''
				group by convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)
				order by convert(varchar(4), datename(yyyy, CoreReports.dbo.fnJulianToGregorianDate(date_applied))) + ''-'' + RIGHT(''0''+convert(varchar(2), datepart(mm, CoreReports.dbo.fnJulianToGregorianDate(date_applied))),2)
			';

		exec (@sql);
		
		FETCH NEXT FROM cur_dbap INTO @dbname;
	END
	
	drop table #db_ap;

-- insert the summarized data into the CoreReports table where it will be pulled into the arrowkpi db on the DW server
	truncate table CoreReports.dbo.monthly_transaction_counts

	insert CoreReports.dbo.monthly_transaction_counts (finance_function, calendar_month, transaction_count)
	select finance_function, calendar_month, sum(transaction_count) as transaction_count
	from #temp
	group by finance_function, calendar_month
	order by finance_function, calendar_month


	drop table #temp


END