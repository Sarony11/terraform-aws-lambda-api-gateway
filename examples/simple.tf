module "lambda-api-gateway" {
    source = "../"
    name = "maa-ml-lambda-api"
    stage_name = "staging"
    enable_cloudwatch_logging = true
}

provider "aws" {

  profile = "personal"
  region  = "us-east-1"

}