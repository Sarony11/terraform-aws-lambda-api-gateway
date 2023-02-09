module "lambda-api-gateway" {
    source = "../"

    # api gw resource
    name = "maa-ml-lambda-api"
    
    # api stage resource
    stage_name = "staging"
    api_log_enable = true

    # api integration resource
    integration_types       = ["AWS_PROXY", "AWS_PROXY"]
    integration_methods     = ["POST", "POST"]
    integration_uris        = ["${aws_lambda_function.app.invoke_arn}", "${aws_lambda_function.app.invoke_arn}"]

    # api route resource
    route_key               = ["GET /hello", "GET /bye"]
    route_authorization_type= ["NONE", "NONE"]

    lambda_function_name    = ["${aws_lambda_function.app.function_name}", "${aws_lambda_function.app.function_name}"]
}

# Creates a bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "hello-world-lambda-3ed4rf5tg-app-code"
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
  function_name = "hello-world-lambda-app"

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
  name = "lambda-app-role"

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

provider "aws" {

  profile = "personal"
  region  = "us-east-1"

}