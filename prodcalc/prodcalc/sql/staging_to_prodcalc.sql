/********************
  staging -> prodcalc
********************/


-- insert new and update existing data in prodcalc.EquipmentType ********************************
MERGE [prodcalc].[EquipmentType] AS p
	USING [staging].[EquipmentType] AS s
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
	USING [staging].[Product] AS s
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
	USING [staging].[FacilityOwner] AS s
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
	USING [staging].[LostTimeReason] AS s
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
	USING [staging].[Division] AS s
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
	USING [staging].[Customer] AS s
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
	USING [staging].[Location] AS s
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