locals {
    create_log_group = var.api_log_enable == true
}
# Creates api gateway and sets the protocol
resource "aws_apigatewayv2_api" "lambda" {
  name          = "${var.name}-gw"
  protocol_type = "HTTP"
}

# Creates api stage
resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "${var.stage_name}"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw[0].arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "app" {
  count              = length(var.integration_types)
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = length(var.integration_uris) > 0 ? element(var.integration_uris, count.index) : ""
  integration_type   = length(var.integration_types) > 0 ? element(var.integration_types, count.index) : "AWS_PROXY"
  integration_method = length(var.integration_methods) > 0 ? element(var.integration_methods, count.index) : null
  connection_type    = length(var.integration_connection_types) > 0 ? element(var.integration_connection_types, count.index) : "INTERNET"
  connection_id      = length(var.integration_connection_ids) > 0 ? element(var.integration_connection_ids, count.index) : null
  timeout_milliseconds = length(var.integration_timeout_milliseconds) > 0 ? element(var.integration_timeout_milliseconds, count.index) : 29000
}

# Maps the http to the lambda
resource "aws_apigatewayv2_route" "app" {
  count = length(var.route_key)
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = var.route_key[count.index]
  target    = "integrations/${aws_apigatewayv2_integration.app[count.index].id}"
}

# Creates log group for the lambda stage
resource "aws_cloudwatch_log_group" "api_gw" {
  count = local.create_log_group ? 1 : 0
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

# Gives api gateway permissions to invoke the lambda function
resource "aws_lambda_permission" "api_gw" {
  for_each      = toset(var.lambda_function_name)
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}