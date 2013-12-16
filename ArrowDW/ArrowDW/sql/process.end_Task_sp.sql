USE arrowdw
go


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'process.end_Task_sp') AND type in (N'P', N'PC'))
	DROP PROCEDURE process.end_Task_sp
go



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************************************************************
-- Author:		Grant Schulte
-- Create date: 2013-12-16
-- Description:	Ends the task for the TaskID passed in and updates with error message if there is one
**********************************************************************************************************/

CREATE PROCEDURE process.end_Task_sp
	@TaskID int,
	@NumRowsInserted int,
	@NumRowsUpdated int,
	@ErrorMessage varchar(max)
AS
BEGIN

	SET NOCOUNT ON;

	update process.Task
		set EndDateTime = getdate(),
			TaskStatus = 'c', --completed
			NumRowsInserted = @NumRowsInserted,
			NumRowsUpdated = @NumRowsUpdated,
			ErrorMessage = @ErrorMessage
	where TaskID = @TaskID;

END
GO

