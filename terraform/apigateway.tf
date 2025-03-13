# API Gateway REST API
resource "aws_api_gateway_rest_api" "tasks_api" {
  name        = "tasks-api"
  description = "API Gateway for tasks service"
}

# API Gateway Resource (/tasks)
resource "aws_api_gateway_resource" "tasks" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id   = aws_api_gateway_rest_api.tasks_api.root_resource_id
  path_part   = "tasks"
}

# API Gateway Method (GET /tasks)
resource "aws_api_gateway_method" "get_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.tasks.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration (Lambda)
resource "aws_api_gateway_integration" "lambda_get_tasks" {
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.tasks.id
  http_method             = aws_api_gateway_method.get_tasks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tasks_api.invoke_arn
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "tasks_api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_get_tasks]
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  stage_name  = "prod"
}