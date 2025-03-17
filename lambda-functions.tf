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
