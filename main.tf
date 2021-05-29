module "cognito" {
  source = "./modules/cognito"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "lambda" {
  source  = "./modules/lambda"
  handler = "boxesandthings-api"
  lambda_role = "${module.lambda.boxesandthings_api_lambda_role_arn}"
  policy_json_file = "${path.cwd}/lambda_iam_policy.json"
}

module "api_gateway" {
  source      = "./modules/api_gateway"
  lambda_name = "${module.lambda.boxesandthings_api_lambda_name}"
  lambda_uri  = "${module.lambda.boxesandthings_api_lambda_arn}"
  user_pool = "${module.cognito.cognito_user_pool_arn}"
}
