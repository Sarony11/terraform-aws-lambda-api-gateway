module "lambda-api-gateway" {
    source = "../"

    # api gw resource
    name = "maa-ml-lambda-api"
    
    # api stage resource
    stage_name = "staging"
    api_log_enable = true

    # api integration resource
    integration_types       = ["AWS_PROXY"]
    integration_methods     = ["POST"]
    integration_uris        = ["arn:aws:lambda:us-east-1:173776345966:function:hello-world-lambda-app"]

    # api route resource
    route_key               = ["GET /hello"]

    lambda_function_name    = ["hello-world-lambda-app"]
}

provider "aws" {

  profile = "personal"
  region  = "us-east-1"

}