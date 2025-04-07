# Create an IAM Role for AWS Lambda to interact with DynamoDB
resource "aws_iam_role" "lambda_dynamodb_role" {
  name = "lambda_dynamodb_role"
  
  # Define the trust policy that allows Lambda to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com" # Allows Lambda to assume this role
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach the AWS Lambda Basic Execution Role, allowing logging to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_dynamodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # Allows logging to CloudWatch
}

# Attach full access to DynamoDB for Lambda
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_dynamodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess" # Grants full access to DynamoDB
}

# Attach a policy for Lambda invocation from DynamoDB Streams
resource "aws_iam_role_policy_attachment" "lambda-invocatoion" {
  role       = aws_iam_role.lambda_dynamodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaInvocation-DynamoDB" # Allows DynamoDB to trigger Lambda
}

# Attach full access to CloudWatch Logs for debugging and monitoring
resource "aws_iam_role_policy_attachment" "cloud-watch-logs" {
  role       = aws_iam_role.lambda_dynamodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess" # Full access to CloudWatch Logs
}

# Attach the AWS Lambda DynamoDB Execution Role
resource "aws_iam_role_policy_attachment" "dynamodbexecutionrole" {
  role       = aws_iam_role.lambda_dynamodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole" # Grants necessary permissions for Lambda to interact with DynamoDB
}

# Package the Lambda function files as ZIP archives
data "archive_file" "lambda-apply" {
  type        = "zip"
  source_file = "./Code/apply-function.js"
  output_path = "lambda-apply-function.zip"
}

data "archive_file" "lambda-count" {
  type        = "zip"
  source_file = "./Code/count-function.js"
  output_path = "lambda-count-function.zip"
}

data "archive_file" "lambda-draw" {
  type        = "zip"
  source_file = "./Code/draw-function.js"
  output_path = "lambda-draw-function.zip"
}

# Create AWS Lambda function for the 'apply' functionality
resource "aws_lambda_function" "apply-function" {
  filename         = "lambda-apply-function.zip"
  function_name    = "apply-function"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "apply-function.handler"
  source_code_hash = data.archive_file.lambda-apply.output_base64sha256
  runtime          = "nodejs18.x"

  # Define environment variables
  environment {
    variables = {
      foo = "bar"
    }
  }
}

# Create AWS Lambda function for the 'count' functionality
resource "aws_lambda_function" "count-function" {
  filename         = "lambda-count-function.zip"
  function_name    = "count-function"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "count-function.handler"
  source_code_hash = data.archive_file.lambda-count.output_base64sha256
  runtime          = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# Create AWS Lambda function for the 'draw' functionality
resource "aws_lambda_function" "draw-function" {
  filename         = "lambda-draw-function.zip"
  function_name    = "draw-function"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "draw-function.handler"
  source_code_hash = data.archive_file.lambda-draw.output_base64sha256
  runtime          = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# Define a custom IAM policy for Lambda to perform CRUD operations on DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:438465140342:table/dynamodb-table-lottery"
      }
    ]
  })
}

# Attach the custom IAM policy to the Lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_dynamodb_role.name
}
