# Output value definitions
output "base_url" {
  description = "Base URL for API Gateway stage."

  value = module.lambda-api-gateway.base_url
}

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.app.function_name
}