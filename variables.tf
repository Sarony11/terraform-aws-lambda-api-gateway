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

variable "enable_cloudwatch_logging" {
  type        = bool
  default     = true
  description = "Enables api gateway logging in AWS cloudwatch"
}
