############################
# HTTP API
############################

resource "aws_apigatewayv2_api" "application_http_api" {
  name          = "${var.project_name}-${var.environment}-http-api"
  protocol_type = "HTTP"
}

############################
# Cognito JWT Authorizer
############################

resource "aws_apigatewayv2_authorizer" "cognito_jwt_authorizer" {
  api_id          = aws_apigatewayv2_api.application_http_api.id
  name            = "${var.project_name}-${var.environment}-jwt-authorizer"
  authorizer_type = "JWT"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = "https://${var.cognito_user_pool_endpoint}"
  }
}

############################
# Lambda Integrations
############################

resource "aws_apigatewayv2_integration" "add_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.application_http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.add_lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "query_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.application_http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.query_lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

############################
# Routes (Protected)
############################

resource "aws_apigatewayv2_route" "add_route" {
  api_id    = aws_apigatewayv2_api.application_http_api.id
  route_key = "POST /add"
  target    = "integrations/${aws_apigatewayv2_integration.add_lambda_integration.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}

resource "aws_apigatewayv2_route" "query_route" {
  api_id    = aws_apigatewayv2_api.application_http_api.id
  route_key = "POST /query"
  target    = "integrations/${aws_apigatewayv2_integration.query_lambda_integration.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}

############################
# Stage
############################

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.application_http_api.id
  name        = "$default"
  auto_deploy = true
}

############################
# Lambda Permissions
############################

resource "aws_lambda_permission" "allow_add_lambda" {
  statement_id  = "AllowAPIGatewayInvokeAdd"
  action        = "lambda:InvokeFunction"
  function_name = var.add_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.application_http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_query_lambda" {
  statement_id  = "AllowAPIGatewayInvokeQuery"
  action        = "lambda:InvokeFunction"
  function_name = var.query_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.application_http_api.execution_arn}/*/*"
}