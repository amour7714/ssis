USE arrowdw
go


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'process.start_Task_sp') AND type in (N'P', N'PC'))
	DROP PROCEDURE process.start_Task_sp
go



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************************************************************************
-- Author:		Grant Schulte
-- Create date: 2013-12-16
-- Description:	Creates a new task in process.Task from the parameters passed in, returns the TaskID to be able to update it later
***********************************************************************************************************************************/

CREATE PROCEDURE process.start_Task_sp
	@BatchID int,
	@TaskDescript varchar(100)
AS
BEGIN

	SET NOCOUNT ON;

	declare @TaskID int = NEXT VALUE FOR process.TaskID; --get the next TaskID from the sequence

	INSERT INTO [process].[Task]
           ([BatchID]
           ,[TaskDescript]
           ,[StartDateTime]
           ,[EndDateTime]
           ,[TaskStatus]
           ,[NumRowsInserted]
           ,[NumRowsUpdated]
           ,[ErrorMessage])
     VALUES
           (@BatchID
           ,@TaskDescript
           ,getdate()
           ,NULL
           ,'r' --running
           ,0
           ,0
           ,'')

	
	return @TaskID;

END
GO

