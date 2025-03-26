import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, ScanCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const dynamo = new DynamoDBClient({ region: "us-east-1" });
const client = DynamoDBDocumentClient.from(dynamo);

export const handler = async (event) => {
    console.log("---devops90---start-handler");
    console.log("---devops90---event", JSON.stringify(event));

    const TableName = "dynamodb-table-lottery";
    const winners_count = 3;

    try {
        console.log("---devops90---fetching data");

        const command = new ScanCommand({
            FilterExpression: "won = :w",
            ExpressionAttributeValues: { ":w": "no" },
            TableName
        });

        const data = await client.send(command);

        if (!data.Items || data.Items.length < winners_count) {
            return `There is not enough data! Only ${data.Items ? data.Items.length : 0} entries available.`;
        }

        console.log("---devops90---items-count", data.Items.length);

        let indices = new Set();
        while (indices.size < winners_count) {
            indices.add(Math.floor(Math.random() * data.Items.length));
        }

        const winners = [...indices].map(index => data.Items[index]);

        console.log("---devops90---selected-winners", winners);

        await Promise.all(
            winners.map(winner => {
                const update_command = new UpdateCommand({
                    TableName,
                    Key: { email: winner.email },
                    UpdateExpression: "set won = :r",
                    ExpressionAttributeValues: { ":r": "yes" },
                });
                return client.send(update_command);
            })
        );

        return { winners };
    } catch (err) {
        console.error("---devops90---error", err);
        return { error: err.message };
    }
};
