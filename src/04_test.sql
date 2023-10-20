USE Test_ServiceBroker
GO

-- Sending test data.
INSERT INTO [Test_ServiceBroker].[dbo].[tbl_DataStorage] ([DataStorage]) VALUES ('<test>fooo</test>')

-- Viewing the table
SELECT * FROM [Test_ServiceBroker].[dbo].[tbl_DataStorage]
