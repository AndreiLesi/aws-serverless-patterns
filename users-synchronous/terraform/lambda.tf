### USERS Lambda
module "lambda_users" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-UsersFunction"
  description   = "My awesome lambda function"
  handler       = "users.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/users.py",
    {
      pip_requirements = "${path.module}/../src/api/requirements.txt",
    }
  ]

  environment_variables = {
    USERS_TABLE = aws_dynamodb_table.users.name
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode = "Active"

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
      # source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/Prod/*/*"
    }
  }

  publish = true
  tags = {
    Name = "UsersFunction"
  }
}

### AUTHORIZER LAMBDA
module "lambda_auth" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-AuthorizerLambda"
  description   = "My awesome lambda auth function"
  handler       = "authorizer.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 300

  source_path = [
    "${path.module}/../src/api/authorizer.py",
    {
      pip_requirements = "${path.module}/../src/api/requirements.txt",
    }
  ]

  environment_variables = {
    USER_POOL_ID = aws_cognito_user_pool.this.id
    APPLICATION_CLIENT_ID = aws_cognito_user_pool_client.this.id
    ADMIN_GROUP_NAME = local.UserPoolAdminGroupName
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  tracing_mode = "Active"

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/authorizers/*"
      # source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/Prod/*/*"
    }
  }

  publish = true
  tags = {
    Name = "${var.project}-AuthorizerLambda"
  }
}
