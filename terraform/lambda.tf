# Archive Node.js Code (Zip File)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../restapi_lambda"
  output_path = "lambda.zip"
}

# resource "aws_lambda_permission" "apigateway_invoke" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.tasks_api.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "arn:aws:execute-api:us-east-1:${var.account_id}:${aws_api_gateway_rest_api.tasks_api.id}/*/*"
# }
# Lambda Function
resource "aws_lambda_function" "tasks_api" {
  function_name = "tasks-api"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs18.x"
  handler       = "index.handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DB_USER     = "myuser"
      DB_HOST     = "${aws_db_instance.postgres.address}"
      DB_NAME     = "mydatabase"
      DB_PASSWORD = "##Linux##1"
      DB_PORT     = "5432"
    }
  }
}