output "function_name" {
  description = "This is the unique name of the Lambda function that was created"
  value       = "${local.function_id}"
}

output "api_gw_invoke_url" {
  description = "This URL can be used to invoke the Lambda through the API Gateway"
  value       = "${aws_api_gateway_deployment.this.invoke_url}"
}
