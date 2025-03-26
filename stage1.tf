#Create DynamoDB table
resource "aws_dynamodb_table" "dynamodb-table-lottery" {
  name           = "dynamodb-table-lottery"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "email" # Primary key (hash key)

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-lottery"
  }
}