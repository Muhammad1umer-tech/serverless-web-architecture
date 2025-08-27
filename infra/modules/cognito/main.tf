resource "aws_cognito_user_pool" "serverless_user_pool" {
  name = "serverless-user-pool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  schema {
    name     = "email"
    attribute_data_type = "String"
    required = true
    mutable  = true

    string_attribute_constraints {
      min_length = 5
      max_length = 50
    }

  }

  schema {
    name     = "given_name"
    attribute_data_type = "String"
    required = true
    mutable  = true

    string_attribute_constraints {
      min_length = 3
      max_length = 8
    }

  }

  schema {
    name     = "family_name"
    attribute_data_type = "String"
    required = true
    mutable  = true

    string_attribute_constraints {
      min_length = 3
      max_length = 8
    }
  }

}

resource "aws_cognito_user_pool_client" "serverless_app_client" {
  name         = "nextjs-client"
  user_pool_id = aws_cognito_user_pool.serverless_user_pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"

  write_attributes = [
  "email",
  "given_name",
  "family_name"
  ]

  read_attributes = [
    "email",
    "email_verified",
    "given_name",
    "family_name"
  ]

  refresh_token_validity = 7

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

}

