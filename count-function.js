import { DynamoDBClient, ScanCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "us-east-1" });

export const handler = async (event, context) => {
    console.log("--devops--start--handler");
    console.log("--devops--event", event);
    
    let TableName = "dynamodb-table-lottery";
    
    try {
        const command = new ScanCommand({
            TableName: TableName,
            Select: "COUNT"
        });

        const result = await client.send(command);

        console.log("--devops--result", result);
        
        return {
            statusCode: 200,
            body: JSON.stringify({ count: result.Count }) 
        };

    } catch (e) {
        console.error("--devops--error", e);
        
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Error scanning table", error: e.message })
        };
    }
};