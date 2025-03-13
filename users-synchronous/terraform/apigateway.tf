# API Gateway REST API
resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project}-API"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode([
        aws_api_gateway_rest_api.this.body
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_method.GetUsers,
    aws_api_gateway_method.PostUser,
    aws_api_gateway_method.GetUser,
    aws_api_gateway_method.DeleteUser,
    aws_api_gateway_method.PostUser,
    aws_api_gateway_method.UpdateUser,
    aws_api_gateway_integration.GetUsers,
    aws_api_gateway_integration.PostUser,
    aws_api_gateway_integration.GetUser,
    aws_api_gateway_integration.DeleteUser,
    aws_api_gateway_integration.PostUser,
    aws_api_gateway_integration.UpadteUser,
    aws_api_gateway_authorizer.this
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name = "Prod"
  xray_tracing_enabled = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigateway-prod.arn
    format          = jsonencode({
      requestId         = "$context.requestId"
      ip                = "$context.identity.sourceIp"
      requestTime       = "$context.requestTime"
      httpMethod        = "$context.httpMethod"
      routeKey          = "$context.routeKey"
      status            = "$context.status"
      protocol          = "$context.protocol"
      integrationStatus = "$context.integrationStatus"
      integrationLatency = "$context.integrationLatency"
      responseLength    = "$context.responseLength"
    })
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "apigateway-prod" {
  name = "/aws/apigateway/${aws_api_gateway_rest_api.this.name}" 
}

# Resources/Paths definitions
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  path_part = "users"
}

resource "aws_api_gateway_resource" "users-userid" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_resource.users.id
  path_part = "{userid}"
}

# Methods
resource "aws_api_gateway_method" "GetUsers" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "PostUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "UpdateUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users-userid.id
  http_method = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "GetUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users-userid.id
  http_method = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "DeleteUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users-userid.id
  http_method = "DELETE"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

# Lambda Integrations
resource "aws_api_gateway_integration" "GetUsers" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.GetUsers.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.lambda_users.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "PostUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.PostUser.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.lambda_users.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "UpadteUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users-userid.id
  http_method = aws_api_gateway_method.UpdateUser.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.lambda_users.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "GetUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users-userid.id
  http_method = aws_api_gateway_method.GetUser.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.lambda_users.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "DeleteUser" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.users-userid.id
  http_method = aws_api_gateway_method.DeleteUser.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.lambda_users.lambda_function_invoke_arn
}

# API Gateway Authorizer
resource "aws_api_gateway_authorizer" "this" {
  name = "${var.project}-AuthorizerLambda"
  rest_api_id = aws_api_gateway_rest_api.this.id
  authorizer_uri = module.lambda_auth.lambda_function_invoke_arn
}

# API Gateway Logging
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = module.role_apigateway_logging.iam_role_arn
  reset_on_delete = true
}

# IAM Role for API Gateway Logging
module "role_apigateway_logging" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  role_name         = "${var.project}-ApiGatewayLoggingRole"
  role_requires_mfa = false
  create_role             = true
  trusted_role_services = [
    "apigateway.amazonaws.com"
  ]
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
}