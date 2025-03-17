import { DynamoDBClient, ScanCommand } from "@aws-sdk/client-dynamodb";
const client = new DynamoDBClient({});

export const handler = async (event, context) => {
    console.log("--devops--start--handler");
    console.log("--devops--event", event);
    let TableName = "dynamodb-table-lottery";
    try {
        const command = new ScanCommand({
            TableName: TableName,
            Select : "COUNT"
        });
    
        const result = await client.send(command);

        console.log("--devops--result", result);
        return result.Count;
    } catch (e) {
        console.log("--devops--error", e);
        return e.message;
    }
};

    