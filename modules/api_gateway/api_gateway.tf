variable http_method { default = "ANY" }
variable lambda_uri {}
variable lambda_name {}
variable user_pool{}

resource "aws_api_gateway_rest_api" "boxesandthings_api" {
  name        = "boxesandthings_api"
  description = "API Gateway for Boxes and Things App"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.boxesandthings_api.id
  parent_id   = aws_api_gateway_rest_api.boxesandthings_api.root_resource_id
  path_part   = "{resource+}"
}

resource "aws_api_gateway_method" "root_method" {
  rest_api_id      = aws_api_gateway_rest_api.boxesandthings_api.id
  resource_id      = aws_api_gateway_resource.root.id
  http_method      = "ANY"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = "${aws_api_gateway_authorizer.box_things_auth.id}"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.boxesandthings_api.id
  resource_id = aws_api_gateway_method.root_method.resource_id
  http_method = aws_api_gateway_method.root_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_uri}"
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.boxesandthings_api.id
  stage_name  = "beta"
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.boxesandthings_api.execution_arn}/*/*"
}

resource "aws_api_gateway_authorizer" "box_things_auth" {
  name                   = "gateway_auth"
  rest_api_id            = aws_api_gateway_rest_api.boxesandthings_api.id
  type = "COGNITO_USER_POOLS"
  provider_arns = ["${var.user_pool}"]
}