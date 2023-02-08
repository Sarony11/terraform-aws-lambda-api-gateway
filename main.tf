locals {
    create_log_group = var.enable_cloudwatch_logging == true
}
# Creates a bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.name}-lambda-app-code"
}

# Creates an ACL for the buckete
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

# Creates a zip file with the source code and loads it as data source
data "archive_file" "lambda_app" {
  type = "zip"

  source_dir  = "${path.module}/hello-world"
  output_path = "${path.module}/hello-world.zip"
}

# Creates an S3 object with the lambda code
resource "aws_s3_object" "lambda_app" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_app.output_path

  etag = filemd5(data.archive_file.lambda_app.output_path)
}
#####################
## LAMBDA FUNCTION ##
#####################
# Creates lambda function
resource "aws_lambda_function" "app" {
  function_name = "${var.name}-app"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_app.key

  runtime = "nodejs12.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.lambda_app.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

# Creates cloudwatch log group to store log messages from the lambda
resource "aws_cloudwatch_log_group" "app" {
  name = "/aws/lambda/${aws_lambda_function.app.function_name}"

  retention_in_days = 30
}

# Creates iam role for the lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

# Attaches the iam role to the lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#####################
## AWS API GATEWAY ##
#####################
# Creates api gateway and sets the protocol
resource "aws_apigatewayv2_api" "lambda" {
  name          = "${var.name}-gw"
  protocol_type = "HTTP"
}

# Creates api stage
resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "${var.name}-${var.stage_name}"
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
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.app.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Maps the http to the lambda
resource "aws_apigatewayv2_route" "app" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.app.id}"
}

# Creates log group for the lambda stage
resource "aws_cloudwatch_log_group" "api_gw" {
  count = local.create_log_group ? 1 : 0
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

# Gives api gateway permissions to invoke the lambda function
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}