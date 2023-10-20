-- Use the 'Test_ServiceBroker' database
USE Test_ServiceBroker
GO

-- Create the message type for the request
CREATE MESSAGE TYPE [RequestMessage]
VALIDATION = WELL_FORMED_XML
GO

-- Create the message type for the response
CREATE MESSAGE TYPE [ResponseMessage]
VALIDATION = WELL_FORMED_XML
GO

-- Create the contract
CREATE CONTRACT [DataProcessContract]
(
    [RequestMessage] SENT BY INITIATOR,
    [ResponseMessage] SENT BY TARGET
)
GO

-- Create the queue for the initiator
CREATE QUEUE [InitiatorQueue]
WITH STATUS = ON
GO

-- Create the queue for the target
CREATE QUEUE [TargetQueue]
WITH STATUS = ON
GO

-- Create the service for the initiator
CREATE SERVICE [InitiatorService]
ON QUEUE [InitiatorQueue]
(
    [DataProcessContract]
)
GO

-- Create the service for the target
CREATE SERVICE [TargetService]
ON QUEUE [TargetQueue]
(
    [DataProcessContract]
)
GO

-- Altering the InitiatorQueue as a queue with an activation procedure
ALTER QUEUE [InitiatorQueue]
WITH ACTIVATION
(
    STATUS = ON,
    PROCEDURE_NAME = [sp_ProcessResponseMessage],
    MAX_QUEUE_READERS = 10,
    EXECUTE AS SELF
)
GO

-- Altering the TargetQueue as a queue with an activation procedure
ALTER QUEUE [TargetQueue]
WITH ACTIVATION
(
    STATUS = ON,
    PROCEDURE_NAME = [sp_ProcessRequestMessage],
    MAX_QUEUE_READERS = 10,
    EXECUTE AS SELF
)
GO
