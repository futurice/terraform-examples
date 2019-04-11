# Add root resource to the API (it it needs to be included separately from the "proxy" resource defined below), which forwards to our Lambda:

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  resource_id   = "${aws_api_gateway_rest_api.this.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_root" {
  rest_api_id             = "${aws_api_gateway_rest_api.this.id}"
  resource_id             = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method             = "${aws_api_gateway_method.proxy_root.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.function_invoke_arn}"
}

# Add a "proxy" resource, that matches all paths (except the root, defined above) and forwards them to our Lambda:

resource "aws_api_gateway_resource" "proxy_other" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  parent_id   = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_other" {
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_other.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_other" {
  rest_api_id             = "${aws_api_gateway_rest_api.this.id}"
  resource_id             = "${aws_api_gateway_method.proxy_other.resource_id}"
  http_method             = "${aws_api_gateway_method.proxy_other.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.function_invoke_arn}"
}

resource "aws_api_gateway_method_response" "proxy_other" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${aws_api_gateway_resource.proxy_other.id}"
  http_method = "${aws_api_gateway_method.proxy_other.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "proxy_other" {
  depends_on  = ["aws_api_gateway_integration.proxy_other"]
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${aws_api_gateway_resource.proxy_other.id}"
  http_method = "${aws_api_gateway_method.proxy_other.http_method}"
  status_code = "${aws_api_gateway_method_response.proxy_other.status_code}"

  response_templates = {
    "application/json" = ""
  }
}
