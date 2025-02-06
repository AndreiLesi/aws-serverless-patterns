resource "aws_cognito_user_pool" "this" {
    name = "${var.project}-UserPool"
    schema {
      name = "name"
      attribute_data_type = "String"
      mutable = true
      required = true
    }
    schema {
      name = "email"
      attribute_data_type = "String"
      mutable = true
      required = true
    }
    username_attributes = [ "email" ]
    admin_create_user_config {
      allow_admin_create_user_only = false
    }
    user_pool_tier = "LITE"
    auto_verified_attributes = [ "email" ]
}

resource "aws_cognito_user_pool_client" "this" {
  name = "${var.project}-UserPoolClient"
  user_pool_id = aws_cognito_user_pool.this.id
  explicit_auth_flows = [ 
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
   ]
   generate_secret = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid"]
  callback_urls = ["http://localhost"]
  refresh_token_validity = 30
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "this" {
    domain = "${var.project}"
    user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_group" "admin" {
    name = local.UserPoolAdminGroupName
    user_pool_id = aws_cognito_user_pool.this.id
    precedence = 0
}
