resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project}-Orders"
}

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
    aws_api_gateway_method.CreateOrder,
    aws_api_gateway_integration.CreateOrder,
    aws_api_gateway_method.GetOrder,
    aws_api_gateway_integration.GetOrder,
    aws_api_gateway_method.ListOrders,
    aws_api_gateway_integration.ListOrders,
    aws_api_gateway_method.EditOrder,
    aws_api_gateway_integration.EditOrder,
    aws_api_gateway_method.CancelOrder,
    aws_api_gateway_integration.CancelOrder,
    aws_api_gateway_authorizer.this,
    ]
}

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
      responseLength    = "$context.responseLength"})
    }
    
}

resource "aws_cloudwatch_log_group" "apigateway-prod" {
    name = "/aws/apigateway/${aws_api_gateway_rest_api.this.name}" 
}


# Resources/Paths definitions
resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  path_part = "orders"
}

resource "aws_api_gateway_resource" "orders-orderId" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_resource.orders.id
  path_part = "{orderId}"
}

# Methods 
resource "aws_api_gateway_method" "CreateOrder" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "GetOrder" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders-orderId.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "ListOrders" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "EditOrder" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders-orderId.id
  http_method = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_method" "CancelOrder" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders-orderId.id
  http_method = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

# Lambda Integrations
resource "aws_api_gateway_integration" "CreateOrder" {
    rest_api_id = aws_api_gateway_rest_api.this.id
    resource_id = aws_api_gateway_resource.orders.id
    http_method = aws_api_gateway_method.CreateOrder.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = module.lambda_add_order.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "GetOrder" {
    rest_api_id = aws_api_gateway_rest_api.this.id
    resource_id = aws_api_gateway_resource.orders-orderId.id
    http_method = aws_api_gateway_method.GetOrder.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = module.lambda_get_order.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "ListOrders" {
    rest_api_id = aws_api_gateway_rest_api.this.id
    resource_id = aws_api_gateway_resource.orders.id
    http_method = aws_api_gateway_method.ListOrders.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = module.lambda_list_orders.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "EditOrder" {
    rest_api_id = aws_api_gateway_rest_api.this.id
    resource_id = aws_api_gateway_resource.orders-orderId.id
    http_method = aws_api_gateway_method.EditOrder.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = module.lambda_edit_order.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "CancelOrder" {
    rest_api_id = aws_api_gateway_rest_api.this.id
    resource_id = aws_api_gateway_resource.orders-orderId.id
    http_method = aws_api_gateway_method.CancelOrder.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = module.lambda_cancel_order.lambda_function_invoke_arn
}

# AUTHORIZER FCN
# Note: Invoke Permissions are granted in the lambda section using apigateway/authorizers/*
resource "aws_api_gateway_authorizer" "this" {
    name = "${var.project}-CognitoUserPool-Authorizer"
    type = "COGNITO_USER_POOLS"
    rest_api_id = aws_api_gateway_rest_api.this.id
    provider_arns = [ var.UserPoolArn ]
}
