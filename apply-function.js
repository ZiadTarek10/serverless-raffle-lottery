const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({ region: "us-east-1" });

exports.handler = async (event) => {
  console.log("Received event: ", JSON.stringify(event, null, 2));

  try {
    let requestBody;

    // Handle both API Gateway and direct Lambda invocations
    if (event.body) {
      requestBody = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    } else {
      requestBody = event; // If directly invoked (e.g., via test event in AWS Lambda)
    }

    const { email, name, phone } = requestBody;

    if (!email || !name || !phone) {
      throw new Error("Missing required fields: email, name, or phone");
    }

    // Set the default value for 'won'
    const won = "no";

    // Prepare the data for DynamoDB
    const params = {
      TableName: "dynamodb-table-lottery",
      Item: {
        email: { S: email },
        name: { S: name },
        phone: { S: phone },
        won: { S: won },
      },
    };

    // Save data to DynamoDB
    const command = new PutItemCommand(params);
    await client.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Data successfully saved to DynamoDB." }),
    };
  } catch (error) {
    console.error("Error saving data to DynamoDB:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Failed to save data to DynamoDB.", error: error.message }),
    };
  }
};
