![application](https://github.com/mortylen/sql-service-broker/blob/main/img/sbdiagram-anim.gif?raw=true)

# SQL Service Broker
## Service Broker for Microsoft SQL. Commands for setup and testing.

**[PROJECT ARTICLE](https://mortylen.hashnode.dev/sql-service-broker-my-first-steps)**
**|**
**☕[SUPPORT MY WORK](https://buymeacoffee.com/mortylen)**

## How do I imagine my testing purposes?

First, I will create a database called ***Test\_ServiceBroker.*** Within this database, I will create a table named ***tbl\_DataStorage*** to simulate a production table. This table will collect data from users for further processing.

Next, I will create a ***trigger*** for the ***tbl\_DataStorage*** table that will execute after the data is inserted. This trigger will utilize Service Broker to send the data to a stored procedure named ***sp\_ProcessRequestMessage***. This procedure will handle the data processing. Once the data is processed, the Service Broker will send a message to another stored procedure named ***sp\_ProcessResponseMessage***, which will update the status of the record in the ***tbl\_DataStorage*** table to mark it as complete.

I will create and configure the necessary Service Broker objects. Firstly, I will create a ***Message Type*** for the request message and another ***Message Type*** for the response message. Following that, I will establish a ***Contract*** between these Message Types, defining the allowable communication between them.

Afterward, I will create a ***Queue*** for the initiator and another ***Queue*** for the target. These queues will serve as the storage location for incoming messages.

Finally, I will create two ***Services***: one for the initiator and another for the target. These services will act as the endpoints for the conversation and will be associated with their respective queues.

![application](https://github.com/mortylen/sql-service-broker/blob/main/img/sbtest-anim.gif?raw=true)

## Create, set up and test in 4 steps:

You can find the source sql in **[src/](https://github.com/mortylen/sql-service-broker/blob/main/src/)**

- *[01_create_playground.sql](https://github.com/mortylen/sql-service-broker/blob/main/src/01_create_playground.sql)*
- *[02_configure_service_broker.sql](https://github.com/mortylen/sql-service-broker/blob/main/src/02_configure_service_broker.sql)*
- *[03_create_trigger_stored_procedure.sql](https://github.com/mortylen/sql-service-broker/blob/main/src/03_create_trigger_stored_procedure.sql)*
- *[04_test.sql](https://github.com/mortylen/sql-service-broker/blob/main/src/04_test.sql)*

### How does it all work? See the article: **[Project article.](https://mortylen.hashnode.dev/sql-service-broker-my-first-steps)**

---

If you found this useful, consider supporting me:

☕ [Buy Me a Coffee](https://buymeacoffee.com/mortylen)
