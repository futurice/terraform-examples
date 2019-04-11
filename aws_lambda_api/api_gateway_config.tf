resource "aws_api_gateway_rest_api" "this" {
  name        = "${local.prefix_with_domain}"
  description = "${var.comment_prefix}${var.api_domain}"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"

  depends_on = [
    "aws_api_gateway_integration.proxy_root",
    "aws_api_gateway_integration.proxy_other",
  ]
}

resource "aws_api_gateway_stage" "this" {
  stage_name    = "${var.stage_name}"
  description   = "${var.comment_prefix}${var.api_domain}"
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  deployment_id = "${aws_api_gateway_deployment.this.id}"
  tags          = "${var.tags}"
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  stage_name  = "${aws_api_gateway_stage.this.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled        = "${var.api_gateway_cloudwatch_metrics}"
    logging_level          = "${var.api_gateway_logging_level}"
    data_trace_enabled     = "${var.api_gateway_logging_level == "OFF" ? false : true}"
    throttling_rate_limit  = "${var.throttling_rate_limit}"
    throttling_burst_limit = "${var.throttling_burst_limit}"
  }
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name              = "${var.api_domain}"
  regional_certificate_arn = "${aws_acm_certificate_validation.this.certificate_arn}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = "${aws_api_gateway_rest_api.this.id}"
  stage_name  = "${aws_api_gateway_stage.this.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.this.domain_name}"
}
