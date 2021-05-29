resource "aws_cognito_user_pool" "box_things_pool" {
  name = "box_things"

  alias_attributes = [
    "email"
  ]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  mfa_configuration = "OFF"

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
    email_subject        = "Confirm your account"
    email_message        = "To confirm your account please click on the link. {####}"
  }

}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }
  }
}

resource "aws_cognito_user_pool_client" "box_things_client" {
  access_token_validity = 60
  id_token_validity     = 60
  name                  = "box_things_client"
  callback_urls = [
    "https://www.google.com",
  ]
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  logout_urls = [
    "https://www.google.com",
  ]
  supported_identity_providers = [
    "COGNITO",
  ]
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  user_pool_id = "${aws_cognito_user_pool.box_things_pool.id}"
}

output cognito_user_pool_arn {
  value = "${aws_cognito_user_pool.box_things_pool.arn}"
}
