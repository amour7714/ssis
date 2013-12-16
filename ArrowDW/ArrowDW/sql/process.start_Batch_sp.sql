USE arrowdw
go


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'process.start_Batch_sp') AND type in (N'P', N'PC'))
	DROP PROCEDURE process.start_Batch_sp
go



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************************************************************************
-- Author:		Grant Schulte
-- Create date: 2013-12-16
-- Description:	Creates a new batch in process.Batch from the parameters passed in and returns the BatchID to the calling process
***********************************************************************************************************************************/

CREATE PROCEDURE process.start_Batch_sp
	@BatchDescript varchar(100)
AS
BEGIN

	SET NOCOUNT ON;

	declare @BatchID int = NEXT VALUE FOR process.BatchID; --get the next BatchID from the sequence

	insert into [process].[Batch]
		([BatchID]
		,[BatchDescript]
		,[StartDateTime]
		,[EndDateTime]
		,[BatchStatus]
		,[ErrorMessage])
	values
		(@BatchID
		,@BatchDescript
		,getdate()
		,NULL
		,'r' --running
		,'');

	return @BatchID;

END
GO

