# Create the API Gateway
resource "aws_api_gateway_rest_api" "greeting_api" {
  name        = "greeting_api"
  description = "API for invoking the Greeting Lambda Function"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    environment: var.tag_environment
  }
}

resource "aws_api_gateway_resource" "greet_resource" {
  rest_api_id = aws_api_gateway_rest_api.greeting_api.id
  parent_id   = aws_api_gateway_rest_api.greeting_api.root_resource_id
  path_part   = "greet"
}

resource "aws_api_gateway_method" "greet_method" {
  rest_api_id   = aws_api_gateway_rest_api.greeting_api.id
  resource_id   = aws_api_gateway_resource.greet_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_api_gateway_integration" "greet_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.greeting_api.id
  resource_id             = aws_api_gateway_resource.greet_resource.id
  http_method             = "ANY" #aws_api_gateway_method.greet_method.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.current.account_id}/${var.greeting_queue_name}"
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
  credentials = var.api_gateway_greeting_queue_role_arn
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.greeting_api.id
  resource_id = aws_api_gateway_resource.greet_resource.id
  http_method = aws_api_gateway_method.greet_method.http_method
  status_code = 200
  selection_pattern = "^2[0-9][0-9]" # Any 2xx response

  response_templates = {
    "application/json" = "{\"status\": \"success\"}"
  }

  depends_on = [aws_api_gateway_integration.greet_method_integration]
}

resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.greeting_api.id
  resource_id = aws_api_gateway_resource.greet_resource.id
  http_method = aws_api_gateway_method.greet_method.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_deployment" "greeting_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.greeting_api.id

  triggers = {
    redeployment = sha256(jsonencode(aws_api_gateway_rest_api.greeting_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_method.greet_method, aws_api_gateway_integration.greet_method_integration]
}
########################MONITORING###################################
resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name = "/aws/api-gateway/greeting_api"
}

resource "aws_api_gateway_stage" "greeting_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.greeting_api.id
  deployment_id = aws_api_gateway_deployment.greeting_api_deployment.id
  stage_name    = var.tag_environment
  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
    format = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      caller          = "$context.identity.caller"
      user            = "$context.identity.user"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      resourcePath    = "$context.resourcePath"
      status          = "$context.status"
      responseLength  = "$context.responseLength"
    })
  }
}
resource "aws_api_gateway_account" "apigateway_account" {
  cloudwatch_role_arn = var.api_gateway_greeting_queue_role_arn
}
