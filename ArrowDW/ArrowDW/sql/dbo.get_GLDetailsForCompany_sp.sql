USE dwloadobjects
go


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.get_GLDetailsForCompany_sp') AND type in (N'P', N'PC'))
	DROP PROCEDURE dbo.get_GLDetailsForCompany_sp
go



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************************************************************************
-- Author:		Grant Schulte
-- Create date: 2013-12-10
-- Description:	Loads GL detail data into the dbo.finance_FactGL_staging table for use in loading of finance.FactGL table in DW


Parameter Usage:

	@company_code: 
		if = 'ALL' (which is the default) then it will get the gl details for each company with GL installed
		if = <a valid company code> then it will get the gl details for just that company

	@lookback:
		if > 0 then it will get the gl details for the last @lookback number of days
		if = 0 (which is the default) then it will get the gl details for journals that have not already been processed into the DW

		* for incremental DW loads, use @lookback = 0 and for full or partial loads (i.e. refresh last 60 days), use @lookback = 60

***********************************************************************************************************************************/

CREATE PROCEDURE dbo.get_GLDetailsForCompany_sp
	@company_code varchar(8) = 'ALL',
	@lookback int = 0,
	@BatchID int = 0 -- comes from batch table on DW server, SSIS package gets this first and then passes into this SP
AS
BEGIN

	SET NOCOUNT ON;

	-- check inputs 

	if @lookback < 0
	begin
		print 'The @lookback parameter cannot be a negative number.';
		return;
	end



-- ************************************************************
-- *** get list of company databases that have GL installed ***
-- ************************************************************

	declare @sql varchar(8000),
			@cc varchar(8),
			@dbname varchar(128)
	
	-- create temp table to store the names of databases that have GL installed
	select company_code, [db_name]
	into #db_gl
	from Epicor_Control.dbo.ewcomp
	where 0=1;

	-- get list of all company databases
	declare cur_dblistGL cursor for
		select company_code, [db_name]
		from Epicor_Control.dbo.ewcomp; 
		
	open cur_dblistGL;
	
	FETCH NEXT FROM cur_dblistGL INTO @cc, @dbname;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @sql = 
			'use ' + @dbname + ' 
			 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[' + @dbname + '].[dbo].[gltrxdet]'') AND type in (N''U''))
				insert into #db_gl values (''' + @cc + ''', ''' + @dbname + ''')';
		
		exec (@sql);
			
		FETCH NEXT FROM cur_dblistGL INTO @cc, @dbname;
	END
	
	close cur_dblistGL;
	deallocate cur_dblistGL;


-- ************************************************************
-- *** get list of company databases that have AM installed ***
-- ************************************************************
	
	-- create temp table to store the names of databases that have AM installed
	select [db_name]
	into #db_am
	from Epicor_Control.dbo.ewcomp
	where 0=1;
	
	-- get list of all company databases
	declare cur_dblistAM cursor for
		select [db_name]
		from Epicor_Control.dbo.ewcomp; 
		
	open cur_dblistAM;
	
	FETCH NEXT FROM cur_dblistAM INTO @dbname;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @sql = 
			'use ' + @dbname + ' 
			 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[' + @dbname + '].[dbo].[amasset]'') AND type in (N''U''))
				insert into #db_am values (''' + @dbname + ''')';
		
		exec (@sql);
			
		FETCH NEXT FROM cur_dblistAM INTO @dbname;
	END
	
	close cur_dblistAM;
	deallocate cur_dblistAM;



	-- **********************************************************************************************************
	-- at this point we have 2 temp tables telling us which companies have GL and AM (Asset Management) installed
	-- **********************************************************************************************************


	-- clear the staging table so that it will contain only the new data about to be loaded
	truncate table dbo.finance_FactGL_staging;


	-- loop through the list of companies and insert new data into staging table

	declare cur_companies cursor for
		select [db_name]
		from #db_gl -- only concerned with companies that have GL installed 
		where company_code = @company_code or @company_code = 'ALL';

	open cur_companies;

	fetch next from cur_companies into @dbname;

	while @@FETCH_STATUS = 0
	begin

		set @sql = '
			insert into dbo.finance_FactGL_staging (ApplyDate, TrxDate, PostedDate, PeriodEndDate, OrganizationCode, CompanyCode, BranchCode, DivisionCode, ReferenceCode, 
													JournalTypeCode, TrxCurrencyCode, HomeCurrencyCode, OperCurrencyCode, CustomerCode, VendorCode, TransactionTypeCode, 
													GLAccountCode, AssetCode, journal_ctrl_num, sequence_id, batch_ctrl_num, trx_description, trx_reference_1, trx_reference_2, 
													username, trx_amt, home_rate, home_amt, oper_rate, oper_amt, BatchID)
			select 
				  ApplyDate = isnull(convert(date, CoreReports.dbo.fnJulianToGregorianDate(glh.date_applied)), ''1900-01-01'')
				, TrxDate = isnull(convert(date, CoreReports.dbo.fnJulianToGregorianDate(glh.date_entered)), ''1900-01-01'') --change to CASE with lookups into other tables for actual trx dates (based on transaction type which other tables to look at): for AR can always use artrx_all only, everything goes there
				, PostedDate = isnull(convert(date, CoreReports.dbo.fnJulianToGregorianDate(glh.date_posted)), ''1900-01-01'')
				, PeriodEndDate = isnull(convert(date, DATEADD(dd, -DAY(DATEADD(mm, 1, CoreReports.dbo.fnJulianToGregorianDate(glh.date_applied))), 
											DATEADD(mm, 1, CoreReports.dbo.fnJulianToGregorianDate(glh.date_applied)))), ''1900-01-01'')
				, OrganizationCode = isnull(nullif(gld.org_id, ''''), ''[na]'') 
				, CompanyCode = isnull(nullif(gld.rec_company_code, ''''), ''[na]'') 
				, BranchCode = isnull(nullif(gld.seg2_code, ''''), ''[na]'') 
				, DivisionCode = isnull(nullif(cb.division_code, ''''), ''[na]'') 
				, ReferenceCode = isnull(nullif(gld.reference_code, ''''), ''[na]'')
				, JournalTypeCode = isnull(nullif(glh.journal_type, ''''), ''[na]'')
				, TrxCurrencyCode = isnull(nullif(gld.nat_cur_code, ''''), ''[na]'')
				, HomeCurrencyCode = isnull(nullif(glh.home_cur_code, ''''), ''[na]'')
				, OperCurrencyCode = isnull(nullif(glh.oper_cur_code, ''''), ''[na]'')
				, CustomerCode = case glh.journal_type when ''AR'' then isnull(nullif(gld.document_1, ''''), ''NO CUST'') else ''[na]'' end 
				--, CustomerCode2 = case when glh.journal_type = ''AR'' then ar.customer_code else ''[na]'' end 
				, VendorCode = case when glh.journal_type = ''AP'' and gld.document_2 LIKE ''VCH%'' then isnull(nullif(voh.vendor_code, ''''), ''NO VEND'') else ''[na]'' end 
				, TransactionTypeCode = isnull(nullif(ttd.trx_type_code, ''''), ''[na]'')
				, GLAccountCode = isnull(nullif(gld.account_code, ''''), ''[na]'')';

		if exists (select * from #db_am where [db_name] = @dbname)
			set @sql = @sql + '
				, AssetCode = isnull(a.asset_ctrl_num, ''[na]'')';
		else 
			set @sql = @sql + '
				, AssetCode = ''[na]''';

		set @sql = @sql + '
				, journal_ctrl_num = gld.journal_ctrl_num
				, sequence_id = gld.sequence_id
				, batch_ctrl_num = glh.batch_code
				, trx_description = gld.[description] 
				, trx_reference_1 = gld.document_1 
				, trx_reference_2 = gld.document_2 
				, username = isnull(nullif(u.[user_name], ''''), ''[na]'')
				, trx_amt = gld.nat_balance
				, home_rate = gld.rate
				, home_amt = gld.balance
				, oper_rate = gld.rate_oper
				, oper_amt = gld.balance_oper
				, BatchID = ' + convert(varchar(50), @BatchID) + '
			from ' + @dbname + '.dbo.gltrxdet gld
			left join ' + @dbname + '.dbo.gltrx_all glh on glh.journal_ctrl_num = gld.journal_ctrl_num
			left join Epicor_Control.dbo.atsi_CompanyBranches cb on cb.branch_code = gld.seg2_code
			left join ' + @dbname + '.dbo.gltrxtyp ttd on ttd.trx_type = gld.trx_type
			left join Epicor_Control.dbo.smusers u on u.[user_id] = glh.[user_id]';

		if exists (select * from #db_am where [db_name] = @dbname)
			set @sql = @sql + '
			left join (select ass1.asset_ctrl_num, isnull(nullif(ass1.account_reference_code, ''''), ''Not Assigned'') as reference_code -- do not want to join gl lines with no ref code to every line in amasset that does not have a ref code assigned
						from ' + @dbname + '.dbo.amasset ass1
						join (select account_reference_code, max(acquisition_date) as max_acquisition_date, max(co_asset_id) as max_co_asset_id
							  from ' + @dbname + '.dbo.amasset 
							  group by account_reference_code) ass2
							on ass1.account_reference_code = ass2.account_reference_code
							and ass1.acquisition_date = ass2.max_acquisition_date
							and ass1.co_asset_id = ass2.max_co_asset_id) a 
				on a.reference_code = gld.reference_code ';

		set @sql = @sql + '
			left join ' + @dbname + '.dbo.apvohdr_all voh on voh.trx_ctrl_num = gld.document_2
			--left join ' + @dbname + '.dbo.artrx_all ar on ar.doc_ctrl_num = gld.document_2
			where glh.posted_flag = 1';

		if @lookback > 0 
			set @sql = @sql + '
				  and convert(date, CoreReports.dbo.fnJulianToGregorianDate(glh.date_applied)) > getdate() - ' + convert(varchar(4), @lookback);

		else if @lookback = 0
			set @sql = @sql + '
				  and not exists (
							select NULL
							from dbo.finance_FactGL_tracking track
							where track.company_code = glh.company_code
								and track.journal_ctrl_num = glh.journal_ctrl_num
					  )'; 



		--print @sql;

		exec (@sql)


		-- insert the distinct list of journal_ctrl_nums for current company into the tracking table so we know these have been processed into the DW
		-- maybe here, maybe elsewhere in the processing... shouldn't finalize until the new data is actually in finance.FactGL


		fetch next from cur_companies into @dbname;

	end;

	close cur_companies;
	deallocate cur_companies;

	drop table #db_gl;
	drop table #db_am;

END
GO

