const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({ region: "us-east-1" });

exports.handler = async (event) => {
  console.log("Received event: ", JSON.stringify(event, null, 2));

  try {
    // Parse incoming data
    const { email, name, phone } = JSON.parse(event.body);  

    // Set the default value for 'won'
    const won = "no";

    // Prepare the data for DynamoDB (Ensure correct attribute structure)
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

    // Return success response
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
