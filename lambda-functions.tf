// t

data "archive_file" "lambda-apply" {
  type        = "zip"
  source_file = "apply-function.js"
  output_path = "lambda-apply-function.zip"
}

data "archive_file" "lambda-count" {
  type        = "zip"
  source_file = "count-function.js"
  output_path = "lambda-count-function.zip"
}

data "archive_file" "lambda-draw" {
  type        = "zip"
  source_file = "draw-function.js"
  output_path = "lambda-draw-function.zip"
}

resource "aws_lambda_function" "apply-function" {
  filename      = "lambda-apply-function.zip"
  function_name = "apply-function"
  role          = aws_iam_role.lambda_dynamodb_role.arn
  handler       = "apply-function.handler"
  source_code_hash = data.archive_file.lambda-apply.output_base64sha256
  runtime = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_function" "count-function" {
  filename      = "lambda-count-function.zip"
  function_name = "count-function"
  role          = aws_iam_role.lambda_dynamodb_role.arn
  handler       = "count-function.handler"
  source_code_hash = data.archive_file.lambda-count.output_base64sha256
  runtime = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_function" "draw-function" {
  filename      = "lambda-draw-function.zip"
  function_name = "draw-function"
  role          = aws_iam_role.lambda_dynamodb_role.arn
  handler       = "draw-function.handler"
  source_code_hash = data.archive_file.lambda-draw.output_base64sha256
  runtime = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}


resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Policy for Lambda to access DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
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


resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_dynamodb_role.name
}
