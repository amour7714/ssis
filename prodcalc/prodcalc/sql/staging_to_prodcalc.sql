/*
  staging -> prodcalc
*/


-- insert new and update existing data in prodcalc.EquipmentType
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


-- insert new and update existing data in prodcalc.Product
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