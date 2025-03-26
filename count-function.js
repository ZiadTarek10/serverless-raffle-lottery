const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({ region: "us-east-1" });

exports.handler = async (event, context) => {
    console.log("---devops90---start-handler");
    console.log("---devops90---event", JSON.stringify(event));

    const TableName = "dynamodb-table-lottery";
    
    try {
        const command = new ScanCommand({
            TableName,
            Select: "COUNT"
        });

        const response = await client.send(command);
        console.log("---devops90---count", response.Count);

        return  response.Count ;
    } catch (e) {
        console.error("---devops90---error", e);
        return { error: e.message };
    }
};
