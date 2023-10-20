USE Test_ServiceBroker
GO
  
-- Create the trigger
CREATE TRIGGER [dbo].[trg_DataStorage_insert]  
    ON [Test_ServiceBroker].[dbo].[tbl_DataStorage]
    AFTER INSERT
AS
BEGIN TRY
    BEGIN TRANSACTION ;
        DECLARE @DataContent NVARCHAR(MAX)
        DECLARE @Id int
        SET @DataContent = (SELECT [DataStorage] FROM inserted i)   
        SET @Id = (SELECT Id FROM inserted i)  
        If (@DataContent IS NOT NULL)
        BEGIN
            UPDATE [Test_ServiceBroker].[dbo].[tbl_DataStorage] SET [DataStatus] = 'pending processing' WHERE [Id] = @Id;
            SET @DataContent = @DataContent + '<Id_DataStorage>' + CAST(@Id AS NVARCHAR(10)) + '</Id_DataStorage>';
            DECLARE @DialogHandle UNIQUEIDENTIFIER;  
            BEGIN DIALOG CONVERSATION @DialogHandle  
                FROM SERVICE [InitiatorService]  
                TO SERVICE 'TargetService'  
                ON CONTRACT [DataProcessContract]  
                WITH ENCRYPTION = OFF;  
            SEND ON CONVERSATION @DialogHandle  
                MESSAGE TYPE [RequestMessage](@DataContent);
      END
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
END CATCH
GO

-- Create the stored procedure sp_ProcessRequestMessage
CREATE PROCEDURE [dbo].[sp_ProcessRequestMessage]
AS
BEGIN
    DECLARE @DialogHandle UNIQUEIDENTIFIER
    DECLARE @MessageName VARCHAR(256)
    DECLARE @MessageBody XML
    DECLARE @Id_DataStorage INT
        WHILE (1 = 1)
            BEGIN
                BEGIN TRY
                    BEGIN TRANSACTION;
                        WAITFOR (
                            RECEIVE TOP(1)
                                @DialogHandle = conversation_handle,
                                @MessageName = message_type_name,    
                                @MessageBody = CAST(message_body AS XML)
                            FROM dbo.TargetQueue ), TIMEOUT 5000   
                            IF (@@ROWCOUNT = 0)
                            BEGIN
                                ROLLBACK TRANSACTION
                                BREAK
                            END
                            IF ( @MessageName = 'RequestMessage' )
                            BEGIN
                                -- any data processing here... replace WAITFOR DELAY ;
                                WAITFOR DELAY '00:01:00';
                                SET @Id_DataStorage =  @MessageBody.value('/Id_DataStorage[1]', 'INT');
                                SET @MessageBody = '<Id_DataStorage>' + CAST(@Id_DataStorage AS VARCHAR(10)) + '</Id_DataStorage>' + '<ProcessStatus>Complete</ProcessStatus>';
                                SEND ON CONVERSATION @DialogHandle MESSAGE TYPE [ResponseMessage] (@MessageBody);
                            END
                            ELSE IF ( @MessageName = 'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog' )
                            BEGIN
                                END CONVERSATION @DialogHandle ;
                            END
                            ELSE IF ( @MessageName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error' )
                            BEGIN
                                END CONVERSATION @DialogHandle ;
                            END
                    COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                  ROLLBACK TRANSACTION
                END CATCH
            END
END
GO

-- Create the stored procedure sp_ProcessResponseMessage
CREATE PROCEDURE [dbo].[sp_ProcessResponseMessage]
AS
BEGIN
    DECLARE @DialogHandle UNIQUEIDENTIFIER
    DECLARE @MessageName VARCHAR(256)
    DECLARE @MessageBody XML
    DECLARE @Id_DataStorage INT
    DECLARE @ProcessStatus NVARCHAR(64)
        WHILE (1 = 1)
            BEGIN
                BEGIN TRY
                    BEGIN TRANSACTION;
                        WAITFOR (
                            RECEIVE TOP(1)
                                @DialogHandle = conversation_handle,
                                @MessageName = message_type_name,    
                                @MessageBody = CAST(message_body AS XML)
                            FROM dbo.InitiatorQueue ), TIMEOUT 5000   
                            IF (@@ROWCOUNT = 0)
                            BEGIN
                                ROLLBACK TRANSACTION
                                BREAK
                            END
                            IF ( @MessageName = 'ResponseMessage' )
                            BEGIN
                                SET @Id_DataStorage =  @MessageBody.value('/Id_DataStorage[1]', 'INT');
                                SET @ProcessStatus =  @MessageBody.value('/ProcessStatus[1]', 'NVARCHAR(64)');
                                UPDATE [Test_ServiceBroker].[dbo].[tbl_DataStorage] SET [DataStatus] = @ProcessStatus, [CompletionDate] = GETDATE() WHERE [Id] = @Id_DataStorage;
                                END CONVERSATION @DialogHandle;
                            END
                            ELSE IF ( @MessageName = 'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog' )
                            BEGIN
                                END CONVERSATION @DialogHandle ;
                            END
                            ELSE IF ( @MessageName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error' )
                            BEGIN
                                END CONVERSATION @DialogHandle ;
                            END
                    COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                  ROLLBACK TRANSACTION
                END CATCH
            END
END
GO
