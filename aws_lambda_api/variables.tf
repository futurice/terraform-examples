variable "api_domain" {
  description = "Domain on which the Lambda will be made available (e.g. `\"api.example.com\"`)"
}

variable "name_prefix" {
  description = "Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility)"
  default     = "aws-lambda-api---"
}

variable "distribution_comment_prefix" {
  description = "This will be included as a comment on the CloudFront distribution that's created"
  default     = "Lambda API "
}

variable "price_class" {
  description = "CloudFront price class to use (`100`, `200` or `\"All\"`, see https://aws.amazon.com/cloudfront/pricing/)"
  default     = 100
}

variable "https_only" {
  description = "Set this to `false` if you want to support insecure HTTP access, in addition to HTTPS"
  default     = true
}

variable "function_zipfile" {
  description = "Path to a ZIP file that will be installed as the Lambda function (e.g. `\"my-api.zip\"`)"
}

variable "function_handler" {
  description = "Instructs Lambda on which function to invoke within the ZIP file"
  default     = "index.handler"
}

variable "function_runtime" {
  description = "Which node.js version should Lambda use for this function"
  default     = "nodejs8.10"
}

variable "function_env_vars" {
  description = "Which env vars (if any) to invoke the Lambda with"
  type        = "map"

  default = {
    # This effectively useless, but an empty map can't be used in the "aws_lambda_function" resource
    # -> this is 100% safe to override with your own env, should you need one
    aws_lambda_api = ""
  }
}

variable "stage_name" {
  description = "Name of the single stage created for the API on API Gateway" # we're not using the deployment features of API Gateway, so a single static stage is fine
  default     = "default"
}

variable "lambda_logging_enabled" {
  description = "When true, writes any console output to the Lambda function's CloudWatch group"
  default     = false
}

# IMPORTANT! Due to the way API Gateway works, if the related config is ever is changed, you probably need to:
# $ terraform taint aws_api_gateway_deployment.this

locals {
  prefix_with_domain = "${var.name_prefix}${replace("${var.api_domain}", "/[^a-z0-9-]+/", "-")}" # only lowercase alphanumeric characters and hyphens are allowed in e.g. S3 bucket names
}
