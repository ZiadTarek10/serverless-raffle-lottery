const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const { email, name, phone, won } = JSON.parse(event.body); // Parse JSON payload

    // Check if all fields are present
    if (!email || !name || !phone || !won) {
        console.log('Validation failed: missing fields');
        return {
            statusCode: 400,
            body: JSON.stringify({ message: 'Missing required fields.' }),
        };
    }

    const params = {
        TableName: 'dynamodb-table-lottery', // DynamoDB table name
        Item: {
            email: email,
            name: name,
            phone: phone,
            won: won,
            timestamp: new Date().toISOString(), // Add timestamp for record
        },
    };

    try {
        // Store the data in DynamoDB
        await dynamoDb.put(params).promise();
        console.log(`Data successfully saved for email: ${email}`);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Data saved successfully!' }),
        };
    } catch (error) {
        console.error('Error storing data in DynamoDB:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error saving data.' }),
        };
    }
};
