const { DynamoDBClient, ScanCommand, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({ region: "us-east-1" });

exports.handler = async (event) => {

    console.log("devops--start--handler");
    console.log("devops--event", event);

    let tableName = "dynamodb-table-lottery";
    let winners_count = 3;

    try {
        console.log("devops--start--try");
        
        const command = new ScanCommand({
            FilterExpression: "won = :w",
            ExpressionAttributeValues: {
                ":w": { S: "no" }  // Define 'no' as a string
            },
            TableName: tableName
        });

        const data = await client.send(command);

        console.log("devops--items-count", data.Items.length);

        if (data.Items.length < winners_count) {
            const log_item = `There are not enough participants. Only ${data.Items.length} available.`;
            console.log(log_item);  
            return log_item;
        }

        // Fisher-Yates shuffle algorithm
        function shuffleArray(array) {
            for (let i = array.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [array[i], array[j]] = [array[j], array[i]]; // Swap elements
            }
        }

        shuffleArray(data.Items);

        // Select the first 'winners_count' after shuffling
        const winners = data.Items.slice(0, winners_count);

        for (let i = 0; i < winners_count; i++) {
            const update_command = new UpdateItemCommand({
                TableName: tableName,
                Key: {
                    "email": winners[i].email
                },
                UpdateExpression: "SET won = :r",
                ExpressionAttributeValues: {
                    ":r": { S: "yes" }  // Define 'no' as a string
                }
            });

            const response = await client.send(update_command);
            console.log("devops--update-response", response);
        }

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Winners updated", winners: winners })
        };

    } catch (e) {
        console.error("devops--error", e);

        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Error updating winners", error: e.message })
        };
    }
};
