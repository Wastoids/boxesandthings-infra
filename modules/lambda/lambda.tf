variable lambda_role {}
variable handler {}
variable policy_json_file {}

resource "aws_lambda_function" "boxesandthings_api_lambda" {
  function_name = "boxesandthings_api_lambda"
  role          = "${var.lambda_role}"
  runtime       = "go1.x"
  handler       = "${var.handler}"
  timeout       = 30
  filename      = "boxesandthings-api.zip"
}

resource "aws_iam_role" "boxesandthings_api_lambda_execution" {
  name = "boxesandthings_api_lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
       }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "lambda_iam_policy"
  description = "IAM policy for Lambda"

  policy = "${file(var.policy_json_file)}"
}

resource "aws_iam_role_policy_attachment" "lambda_iam_policy_attachment" {
  role       = "${aws_iam_role.boxesandthings_api_lambda_execution.name}"
  policy_arn = "${aws_iam_policy.lambda_iam_policy.arn}"
}

output boxesandthings_api_lambda_role_arn {
  value = "${aws_iam_role.boxesandthings_api_lambda_execution.arn}"
}

output "boxesandthings_api_lambda_arn" {
  value = "${aws_lambda_function.boxesandthings_api_lambda.invoke_arn}"
}

output "boxesandthings_api_lambda_name" {
  value = "${aws_lambda_function.boxesandthings_api_lambda.function_name}"
}
