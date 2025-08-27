# -------------------------------
# 2. API Gateway (HTTP API)
# -------------------------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id     = aws_apigatewayv2_api.http_api.id
  name       = "cognito-authorizer"
  authorizer_type = "JWT"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.serverless_cognito_client_id]
    issuer   = "https://${var.serverless_cognito_pool_endpoint}"
  }
}

# -------------------------------
# 4. Lambda Integration
# -------------------------------
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_function_invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# -------------------------------
# 5. Route (with Cognito auth)
# -------------------------------
resource "aws_apigatewayv2_route" "secure_route_query" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /query"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
}

resource "aws_apigatewayv2_route" "secure_route_add" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /add"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
}

# -------------------------------
# 6. Deployment + Stage
# -------------------------------
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# -------------------------------
# 7. Lambda Permission for API Gateway
# -------------------------------
resource "aws_lambda_permission" "api_gw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}