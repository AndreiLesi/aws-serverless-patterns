resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project}-Profile"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode([
        aws_api_gateway_rest_api.this.id,
        aws_api_gateway_method.ListAddress.id,
        aws_api_gateway_method.CreateAddress.id,
        aws_api_gateway_method.EditAddress.id,
        aws_api_gateway_method.DeleteAddress.id,
        aws_api_gateway_method.ListFavorites.id,
        aws_api_gateway_method.AddFavorite.id,
        aws_api_gateway_method.DeleteFavorite.id,
        aws_api_gateway_integration.ListAddress.id,
        aws_api_gateway_integration.CreateAddress.id,
        aws_api_gateway_integration.EditAddress.id,
        aws_api_gateway_integration.DeleteAddress.id,
        aws_api_gateway_integration.ListFavorites.id,
        aws_api_gateway_integration.AddFavorite.id,
        aws_api_gateway_integration.DeleteFavorite.id,
        aws_api_gateway_method_response.CreateAddress-200.id,
        aws_api_gateway_method_response.EditAddress-200.id,
        aws_api_gateway_method_response.DeleteAddress-200.id,
        aws_api_gateway_method_response.AddFavorite-200.id,
        aws_api_gateway_method_response.DeleteFavorite-200.id,
        aws_api_gateway_integration_response.CreateAddress.id,
        aws_api_gateway_integration_response.EditAddress.id,
        aws_api_gateway_integration_response.DeleteAddress.id,
        aws_api_gateway_integration_response.AddFavorite.id,
        aws_api_gateway_integration_response.DeleteFavorite.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id        = aws_api_gateway_deployment.this.id
  rest_api_id          = aws_api_gateway_rest_api.this.id
  stage_name           = "Prod"
  xray_tracing_enabled = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigateway-prod.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      protocol           = "$context.protocol"
      integrationStatus  = "$context.integrationStatus"
      integrationLatency = "$context.integrationLatency"
    responseLength = "$context.responseLength" })
  }

}

resource "aws_cloudwatch_log_group" "apigateway-prod" {
  name = "/aws/apigateway/${aws_api_gateway_rest_api.this.name}"
}

# Validator
resource "aws_api_gateway_request_validator" "this" {
  name                        = "${var.project}Validator"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = true
  validate_request_parameters = false
}

# Models
resource "aws_api_gateway_model" "UserAddressInputModel" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = "UserAddressInputModel"
  content_type = "application/json"

  schema = jsonencode({
    type = "object",
    properties = {
      city = {
        type = "string"
      },
      line1 = {
        type = "string"
      },
      line2 = {
        type = "string"
      },
      postal = {
        type = "string"
      },
      stateProvince = {
        type = "string"
      }
    }
    required = ["city","line1","line2","postal","stateProvince"]
  })
}

# AUTHORIZER FCN
resource "aws_api_gateway_authorizer" "this" {
  name          = "${var.project}-CognitoUserPool-Authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.this.id
  provider_arns = [var.UserPoolArn]
}

##############################
# Resources/Paths definitions
##############################
resource "aws_api_gateway_resource" "address" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "address"
}

resource "aws_api_gateway_resource" "address-addressId" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_resource.address.id
  path_part = "{addressId}"
}

resource "aws_api_gateway_resource" "favorite" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "favorite"
}

resource "aws_api_gateway_resource" "favorite-restaurantId" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.favorite.id
  path_part   = "{restaurantId}"
}