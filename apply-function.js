const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { PutCommand, DynamoDBDocumentClient } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    console.log("---devops90---start-handler");
    console.log("---devops90---event", event);
    
    let TableName = "dynamodb-table-lottery";
    let body;

    try {
        if (event.body) {
            try {
                body = JSON.parse(event.body);
            } catch (e) {
                body = event.body;
            }
        } else {
            body = event;
        }
        console.log("---devops90---body", body);

        if (!body.email) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: "where is your email!" })
            };
        } else if (!body.phone) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: "where is your phone!" })
            };
        } else if (!body.name) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: "where is your name!" })
            };
        }
        
        const command = new PutCommand({
            TableName: TableName,
            Item: {
                email: body.email,
                phone: body.phone,
                name: body.name,
                won: "no"
            },
        });
        
        const dynamo_response = await docClient.send(command);
        console.log("---devops90---dynamo-response", dynamo_response);
        
        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Thanks, Your data may have been received ;)" })
        };
        
    } catch (e) {
        console.error("---devops90---error", e);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Something went wrong, please try again later." })
        };
    }
};
