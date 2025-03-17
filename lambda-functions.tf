data "archive_file" "lambda" {
  type        = "zip"
  source_file = "apply-function.js"
  output_path = "lambda-apply-function.zip"
}



resource "aws_lambda_function" "apply-function" {
  filename      = "lambda-apply-function.zip"
  function_name = "apply-function"
  role          = aws_iam_role.lambda_dynamodb_role.arn
  handler       = "apply-function.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
