USE [prodcalc]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[process].[merge_staging_into_prodcalc_sp]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [process].[merge_staging_into_prodcalc_sp]
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================================
-- Author:	 Grant Schulte
-- Create date: 2013-04-23
-- Description: Inserts or Updates data in the prodcalc schema tables from the staging schema tables
-- Updated by:	
-- Update Date: 
-- Update Description:	
-- ==================================================================================================

CREATE PROCEDURE [process].[merge_staging_into_prodcalc_sp]
AS
BEGIN

	SET NOCOUNT ON;

	-- insert new and update existing data in prodcalc.EquipmentType ********************************
	MERGE [prodcalc].[EquipmentType] AS p
		USING (select distinct [key], type, customerReportable from [staging].[EquipmentType]) AS s
		ON p.equipmentTypeKey = s.[key]
	WHEN MATCHED AND (s.[type] <> p.equipmentType OR s.customerReportable <> p.customerReportable)
	THEN
		UPDATE SET
		p.equipmentType = s.[type],
		p.customerReportable = s.customerReportable,
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (equipmentTypeKey, equipmentType, customerReportable, date_added, date_last_updated)
		VALUES (s.[key], s.[type], s.customerReportable, GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.Product **************************************
	MERGE [prodcalc].[Product] AS p
		USING (select distinct [key], name from [staging].[Product]) AS s
		ON p.productKey = s.[key]
	WHEN MATCHED AND (s.[name] <> p.productName)
	THEN
		UPDATE SET
		p.productName = s.[name],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (productKey, productName, date_added, date_last_updated)
		VALUES (s.[key], s.[name], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.FacilityOwner  *******************************
	MERGE [prodcalc].[FacilityOwner] AS p
		USING (select distinct [key], name from [staging].[FacilityOwner]) AS s
		ON p.facilityOwnerKey = s.[key]
	WHEN MATCHED AND (s.[name] <> p.facilityOwnerName)
	THEN
		UPDATE SET
		p.facilityOwnerName = s.[name],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (facilityOwnerKey, facilityOwnerName, date_added, date_last_updated)
		VALUES (s.[key], s.[name], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.LostTimeReason  ******************************
	MERGE [prodcalc].[LostTimeReason] AS p
		USING (select distinct [key], reason from [staging].[LostTimeReason]) AS s
		ON p.lostTimeReasonKey = s.[key]
	WHEN MATCHED AND (s.[reason] <> p.lostTimeReason)
	THEN
		UPDATE SET
		p.lostTimeReason = s.[reason],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (lostTimeReasonKey, lostTimeReason, date_added, date_last_updated)
		VALUES (s.[key], s.[reason], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.Division  ************************************
	MERGE [prodcalc].[Division] AS p
		USING (select distinct [key], facilityOwnerKey, id, name, timeZone, utcOffset, multiRailed, multiShifted, 
				monHours, tueHours, wedHours, thuHours, friHours, satHours, sunHours from [staging].[Division]) AS s
		ON p.divisionKey = s.[key]
	WHEN MATCHED AND (s.[facilityOwnerKey] <> p.[facilityOwnerKey] OR s.[id] <> p.[division_id] 
					OR s.[name] <> p.[divisionName] OR s.[timeZone] <> p.[timeZone] 
					OR s.[utcOffset] <> p.[utcOffset] OR s.[multiRailed] <> p.[multiRailed] 
					OR s.[multiShifted] <> p.[multiShifted] OR s.[monHours] <> p.[monHours]
					OR s.[tueHours] <> p.[tueHours] OR s.[wedHours] <> p.[wedHours]
					OR s.[thuHours] <> p.[thuHours] OR s.[friHours] <> p.[friHours]
					OR s.[satHours] <> p.[satHours] OR s.[sunHours] <> p.[sunHours])
	THEN
		UPDATE SET
		p.[facilityOwnerKey] = s.[facilityOwnerKey],
		p.[division_id] = s.[id],
		p.[divisionName] = s.[name],
		p.[timeZone] = s.[timeZone],
		p.[utcOffset] = s.[utcOffset],
		p.[multiRailed] = s.[multiRailed],
		p.[multiShifted] = s.[multiShifted],
		p.[monHours] = s.[monHours],
		p.[tueHours] = s.[tueHours],
		p.[wedHours] = s.[wedHours],
		p.[thuHours] = s.[thuHours],
		p.[friHours] = s.[friHours],
		p.[satHours] = s.[satHours],
		p.[sunHours] = s.[sunHours],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (divisionKey, facilityOwnerKey, division_id, divisionName, timeZone, utcOffset, multiRailed, multiShifted, 
				monHours, tueHours, wedHours, thuHours, friHours, satHours, sunHours, date_added, date_last_updated)
		VALUES (s.[key], s.[facilityOwnerKey], s.[id], s.[name], s.[timeZone], s.[utcOffset], s.[multiRailed], s.[multiShifted], 
				s.[monHours], s.[tueHours], s.[wedHours], s.[thuHours], s.[friHours], s.[satHours], s.[sunHours], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.Customer **************************************
	MERGE [prodcalc].[Customer] AS p
		USING (select distinct [key], divisionKey, name from [staging].[Customer]) AS s
		ON p.customerKey = s.[key]
	WHEN MATCHED AND (s.[divisionKey] <> p.[divisionKey] OR s.[name] <> p.[customerName])
	THEN
		UPDATE SET
		p.[divisionKey] = s.[divisionKey],
		p.[customerName] = s.[name],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (customerKey, divisionKey, customerName, date_added, date_last_updated)
		VALUES (s.[key], s.[divisionKey], s.[name], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.Location **************************************
	MERGE [prodcalc].[Location] AS p
		USING (select distinct [key], divisionKey, capacity, name, customerReportable from [staging].[Location]) AS s
		ON p.locationKey = s.[key]
	WHEN MATCHED AND (s.[divisionKey] <> p.[divisionKey] OR s.[name] <> p.[locationName] 
					OR s.[capacity] <> p.[capacity] OR s.[customerReportable] <> p.[customerReportable])
	THEN
		UPDATE SET
		p.[divisionKey] = s.[divisionKey],
		p.[locationName] = s.[name],
		p.[capacity] = s.[capacity],
		p.[customerReportable] = s.[customerReportable],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (locationKey, divisionKey, capacity, locationName, customerReportable, date_added, date_last_updated)
		VALUES (s.[key], s.divisionKey, s.[capacity], s.[name], s.[customerReportable], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.ProcessingTarget ******************************
	MERGE [prodcalc].[ProcessingTarget] AS p
		USING (select distinct [key], divisionKey, equipmentTypeKey, productKey, loadTarget, unloadTarget from [staging].[ProcessingTarget]) AS s
		ON p.processingTargetKey = s.[key]
	WHEN MATCHED AND (s.[divisionKey] <> p.[divisionKey] OR s.[equipmentTypeKey] <> p.[equipmentTypeKey] 
					OR s.[productKey] <> p.[productKey] OR s.[loadTarget] <> p.[loadTarget]
					OR s.[unloadTarget] <> p.[unloadTarget])
	THEN
		UPDATE SET
		p.[divisionKey] = s.[divisionKey],
		p.[equipmentTypeKey] = s.[equipmentTypeKey],
		p.[productKey] = s.[productKey],
		p.[loadTarget] = s.[loadTarget],
		p.[unloadTarget] = s.[unloadTarget],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (processingTargetKey, divisionKey, equipmentTypeKey, productKey, loadTarget, unloadTarget, date_added, date_last_updated)
		VALUES (s.[key], s.divisionKey, s.[equipmentTypeKey], s.[productKey], s.[loadTarget], s.[unloadTarget], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.OtherLabel *************************************
	MERGE [prodcalc].[OtherLabel] AS p
		USING (select distinct [key], divisionKey, label, active, customerReportable from [staging].[OtherLabel]) AS s
		ON p.otherLabelKey = s.[key]
	WHEN MATCHED AND (s.[divisionKey] <> p.[divisionKey] OR s.[label] <> p.[label] 
					OR s.[active] <> p.[active] OR s.[customerReportable] <> p.[customerReportable])
	THEN
		UPDATE SET
		p.[divisionKey] = s.[divisionKey],
		p.[label] = s.[label],
		p.[active] = s.[active],
		p.[customerReportable] = s.[customerReportable],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (otherLabelKey, divisionKey, label, active, customerReportable, date_added, date_last_updated)
		VALUES (s.[key], s.divisionKey, s.[label], s.[active], s.[customerReportable], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.Shift ******************************************
	MERGE [prodcalc].[Shift] AS p
		USING (select distinct [key], divisionKey, name from [staging].[Shift]) AS s
		ON p.shiftKey = s.[key]
	WHEN MATCHED AND (s.[divisionKey] <> p.[divisionKey] OR s.[name] <> p.[shiftName])
	THEN
		UPDATE SET
		p.[divisionKey] = s.[divisionKey],
		p.[shiftName] = s.[name],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (shiftKey, divisionKey, shiftName, date_added, date_last_updated)
		VALUES (s.[key], s.divisionKey, s.[name], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.DailyActivity  **********************************
	MERGE [prodcalc].[DailyActivity] AS p
		USING (select distinct [key], divisionKey, dateIn, equipmentNumber, equipmentTypeKey, productKey, locationKey, 
				activityType, duration, customerKey, completed, completedDate, shiftKey, railOwnerKey from [staging].[DailyActivity]) AS s
		ON p.dailyActivityKey = s.[key]
	WHEN MATCHED AND (s.[divisionKey] <> p.[divisionKey] OR s.[dateIn] <> p.[dateIn] 
					OR s.[equipmentNumber] <> p.[equipmentNumber] OR s.[equipmentTypeKey] <> p.[equipmentTypeKey] 
					OR s.[productKey] <> p.[productKey] OR s.[locationKey] <> p.[locationKey] 
					OR s.[customerKey] <> p.[customerKey] OR s.[shiftKey] <> p.[shiftKey]
					OR s.[railOwnerKey] <> p.[facilityOwnerKey] OR s.[activityType] <> p.[activityType]
					OR s.[duration] <> p.[duration] OR s.[completed] <> p.[completed] OR s.[completedDate] <> p.[completedDate])
	THEN
		UPDATE SET
		p.[divisionKey] = s.[divisionKey],
		p.[dateIn] = s.[dateIn],
		p.[equipmentNumber] = s.[equipmentNumber],
		p.[equipmentTypeKey] = s.[equipmentTypeKey],
		p.[productKey] = s.[productKey],
		p.[locationKey] = s.[locationKey],
		p.[customerKey] = s.[customerKey],
		p.[shiftKey] = s.[shiftKey],
		p.[facilityOwnerKey] = s.[railOwnerKey],
		p.[activityType] = s.[activityType],
		p.[duration] = s.[duration],
		p.[completed] = s.[completed],
		p.[completedDate] = s.[completedDate],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (dailyActivityKey, divisionKey, dateIn, equipmentNumber, equipmentTypeKey, productKey, locationKey, customerKey, 
				shiftKey, facilityOwnerKey, activityType, duration, completed, completedDate, date_added, date_last_updated)
		VALUES (s.[key], s.[divisionKey], s.[dateIn], s.[equipmentNumber], s.[equipmentTypeKey], s.[productKey], s.[locationKey], s.[customerKey], 
				s.[shiftKey], s.[railOwnerKey], s.[activityType], s.[duration], s.[completed], s.[completedDate], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.WorkDay ******************************************
	MERGE [prodcalc].[WorkDay] AS p
		USING (select distinct [key], divisionKey, shiftKey, date, processed, availableMinutes, comments from [staging].[WorkDay]) AS s
		ON p.workDayKey = s.[key]
	WHEN MATCHED AND (s.[divisionKey] <> p.[divisionKey] OR s.[shiftKey] <> p.[shiftKey] 
					OR s.[date] <> p.[workDate] OR s.[processed] <> p.[processed]
					OR s.[availableMinutes] <> p.[availableMinutes] OR s.[comments] <> p.[comments])
	THEN
		UPDATE SET
		p.[divisionKey] = s.[divisionKey],
		p.[shiftKey] = s.[shiftKey],
		p.[workDate] = s.[date],
		p.[processed] = s.[processed],
		p.[availableMinutes] = s.[availableMinutes],
		p.[comments] = s.[comments],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (workDayKey, divisionKey, shiftKey, workDate, processed, availableMinutes, comments, date_added, date_last_updated)
		VALUES (s.[key], s.divisionKey, s.[shiftKey], s.[date], s.[processed], s.[availableMinutes], s.[comments], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.LocationStaff *************************************
	MERGE [prodcalc].[LocationStaff] AS p
		USING (select distinct [key], locationKey, workDayKey, staffMinutes from [staging].[LocationStaff]) AS s
		ON p.locationStaffKey = s.[key] AND p.[workDayKey] = s.[workDayKey]
	WHEN MATCHED AND (s.[locationKey] <> p.[locationKey] OR s.[staffMinutes] <> p.[staffMinutes])
	THEN
		UPDATE SET
		p.[locationKey] = s.[locationKey],
		p.[staffMinutes] = s.[staffMinutes],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (locationStaffkey, locationKey, workDayKey, staffMinutes, date_added, date_last_updated)
		VALUES (s.[key], s.[locationKey], s.[workDayKey], s.[staffMinutes], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.OtherValue ****************************************
	MERGE [prodcalc].[OtherValue] AS p
		USING (select distinct [key], workDayKey, otherLabelKey, value from [staging].[OtherValue]) AS s
		ON p.otherValueKey = s.[key] AND p.[workDayKey] = s.[workDayKey]
	WHEN MATCHED AND (s.[otherLabelKey] <> p.[otherLabelKey] OR s.[value] <> p.[value])
	THEN
		UPDATE SET
		p.[otherLabelKey] = s.[otherLabelKey],
		p.[value] = s.[value],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (otherValueKey, workDayKey, otherLabelKey, value, date_added, date_last_updated)
		VALUES (s.[key], s.[workDayKey], s.[otherLabelKey], s.[value], GETDATE(), NULL);


	-- insert new and update existing data in prodcalc.LostTime ******************************************
	MERGE [prodcalc].[LostTime] AS p
		USING (select distinct [key], workDayKey, locationKey, lostTimeReasonKey, duration from [staging].[LostTime]) AS s
		ON p.lostTimeKey = s.[key] AND p.[workDayKey] = s.[workDayKey]
	WHEN MATCHED AND (s.[locationKey] <> p.[locationKey] OR s.[lostTimeReasonKey] <> p.[lostTimeReasonKey]
					OR s.[duration] <> p.[duration])
	THEN
		UPDATE SET
		p.[locationKey] = s.[locationKey],
		p.[lostTimeReasonKey] = s.[lostTimeReasonKey],
		p.[duration] = s.[duration],
		p.date_last_updated = GETDATE()
	WHEN NOT MATCHED
	THEN
		INSERT (lostTimeKey, workDayKey, locationKey, lostTimeReasonKey, duration, date_added, date_last_updated)
		VALUES (s.[key], s.[workDayKey], s.[locationKey], s.[lostTimeReasonKey], s.[duration], GETDATE(), NULL);

end