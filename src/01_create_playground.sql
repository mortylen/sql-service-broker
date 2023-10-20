-- Create the 'Test_ServiceBroker' database
USE master
GO
IF db_id('Test_ServiceBroker') IS NOT NULL
    DROP DATABASE Test_ServiceBroker
CREATE DATABASE Test_ServiceBroker;
GO

-- Enable Service Broker for the 'Test_ServiceBroker' database
ALTER DATABASE Test_ServiceBroker SET ENABLE_BROKER
GO

-- Use the 'Test_ServiceBroker' database
USE Test_ServiceBroker
GO

-- Create the 'tbl_DataStorage' table
IF object_id('tbl_DataStorage') IS NOT NULL
  DROP TABLE tbl_DataStorage
GO
CREATE TABLE tbl_DataStorage
(
    Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    InsertDate DATETIME NOT NULL DEFAULT (GETDATE()),
    DataStorage NVARCHAR(MAX),
    DataStatus NVARCHAR(256),
    CompletionDate DATETIME,
);
GO
