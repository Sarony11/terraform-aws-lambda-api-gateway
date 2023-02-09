# Input variable definitions
variable "name" {
  type        = string
  default     = null
  description = "Name of the project"
}

variable "bucket_name" {
  type        = string
  default     = null
  description = "The name of the bucket"
}

variable "api_name" {
  type        = string
  default     = ""
  description = "The name of the api gateway"
}

variable "stage_name" {
  type        = string
  default     = ""
  description = "The name of the stage"
}

variable "api_log_enable" {
  type        = bool
  default     = true
  description = "Whether to enable log for api with cloudwatch"
}

variable "authorizations" {
  type        = list(any)
  default     = []
  description = "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)."
}
# api integration resource
variable "integration_types" {
  type        = list(any)
  default     = []
  description = "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
}

variable "integration_methods" {
  type        = list(any)
  default     = []
  description = "The integration HTTP methods (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST."
}

variable "integration_uris" {
  type        = list(any)
  default     = []
  description = "The input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations."
  sensitive   = true
}

variable "integration_connection_types" {
  type        = list(any)
  default     = []
  description = "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
  sensitive   = true
}

variable "integration_connection_ids" {
  type        = list(any)
  default     = []
  description = "The id of the VpcLink used for the integration. Required if connection_type is VPC_LINK."
  sensitive   = true
}

variable "integration_timeout_milliseconds" {
  type        = list(any)
  default     = []
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
}

# api route variables
variable "route_key" {
  type        = list(any)
  default     = []
  description = "(Required) Route key for the route. For HTTP APIs, the route key can be either $default, or a combination of an HTTP method and resource path, for example, GET /pets."
}

variable "lambda_function_name" {
  type        = list(any)
  default     = []
  description = "(Required) Names of the lambdas functions to allow api gateway to InvokeFunction though permissions."
}