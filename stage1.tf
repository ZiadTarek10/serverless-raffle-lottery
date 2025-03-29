# Create a DynamoDB table for storing lottery-related data
resource "aws_dynamodb_table" "dynamodb-table-lottery" {
  name         = "dynamodb-table-lottery" # Table name
  billing_mode = "PAY_PER_REQUEST"        # Use on-demand pricing (scales automatically)
  hash_key     = "email"                  # Define the primary key (hash key)

  # Define the primary key attribute
  attribute {
    name = "email" # Attribute name used as the primary key
    type = "S"     # 'S' indicates the attribute type is a String
  }

  # Assign tags to the DynamoDB table
  tags = {
    Name = "dynamodb-table-lottery"
  }
}
