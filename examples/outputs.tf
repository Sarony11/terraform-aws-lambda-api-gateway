# Output value definitions

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = module.lambda-api-gateway.lambda_bucket_name
}

output "function_name" {
  description = "Name of the Lambda function."

  value = module.lambda-api-gateway.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = module.lambda-api-gateway.base_url
}