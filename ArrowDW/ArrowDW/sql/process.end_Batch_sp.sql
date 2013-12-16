USE arrowdw
go


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'process.end_Batch_sp') AND type in (N'P', N'PC'))
	DROP PROCEDURE process.end_Batch_sp
go



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************************************************************
-- Author:		Grant Schulte
-- Create date: 2013-12-16
-- Description:	Ends the batch for the BatchID passed in and updates with error message if there is one
**********************************************************************************************************/

CREATE PROCEDURE process.end_Batch_sp
	@BatchID int,
	@ErrorMessage varchar(max)
AS
BEGIN

	SET NOCOUNT ON;

	declare @NumRowsInserted int,
			@NumRowsUpdated int;

	select @NumRowsInserted = isnull(sum(NumRowsUpdated), 0)
	from process.Task
	where BatchID = @BatchID;

	select @NumRowsUpdated = isnull(sum(NumRowsUpdated), 0)
	from process.Task
	where BatchID = @BatchID;

	update process.Batch
		set EndDateTime = getdate(),
			BatchStatus = 'c', --completed
			NumRowsInserted = @NumRowsInserted,
			NumRowsUpdated = @NumRowsUpdated,
			ErrorMessage = @ErrorMessage
	where BatchID = @BatchID

END
GO

