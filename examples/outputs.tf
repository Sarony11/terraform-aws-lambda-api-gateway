# Output value definitions
output "base_url" {
  description = "Base URL for API Gateway stage."

  value = module.lambda-api-gateway.base_url
}