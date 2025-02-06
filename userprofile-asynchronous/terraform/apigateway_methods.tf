################
# List Address
###############
resource "aws_api_gateway_method" "ListAddress" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.address.id
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_integration" "ListAddress" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.address.id
  http_method             = aws_api_gateway_method.ListAddress.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_list_user_addresses.lambda_function_invoke_arn
}


################
# Create Address
###############
resource "aws_api_gateway_method" "CreateAddress" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.address.id
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.this.id
  request_validator_id = aws_api_gateway_request_validator.this.id
  request_models = {
    "application/json" = aws_api_gateway_model.UserAddressInputModel.name
  }
  request_parameters = {
    "method.request.header.Content-Type" = false,
    "method.request.header.X-Amz-Target" = false
  }
}

resource "aws_api_gateway_integration" "CreateAddress" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.address.id
  http_method             = aws_api_gateway_method.CreateAddress.http_method
  credentials             = module.iam_apigateway_eventbridgeaccess.iam_role_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:eu-central-1:events:action/PutEvents"
  request_templates = {
    "application/json" = <<EOF
#set($context.requestOverride.header.X-Amz-Target = "AWSEvents.PutEvents")
#set($context.requestOverride.header.Content-Type = "application/x-amz-json-1.1")
#set($inputRoot = $input.path("$"))
{
  "Entries": [
    {
        "Detail": "{#foreach($paramName in $inputRoot.keySet())\"$paramName\" : \"$util.escapeJavaScript($inputRoot.get($paramName))\" #if($foreach.hasNext),#end #end,\"userId\": \"$context.authorizer.claims.sub\",\"addressId\": \"$input.params().get('path').get('addressId')\"}",
      "DetailType": "address.added",
      "EventBusName": "${aws_cloudwatch_event_bus.AddressBus.name}",
      "Source": "customer-profile"
    }
  ]
}
EOF
  }
}

resource "aws_api_gateway_method_response" "CreateAddress-200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.address.id
  http_method = aws_api_gateway_method.CreateAddress.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration_response" "CreateAddress" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.address.id
  http_method = aws_api_gateway_method.CreateAddress.http_method
  status_code = aws_api_gateway_method_response.CreateAddress-200.status_code
  response_templates = {
    "application/json" : "{}"
  }
  depends_on = [ 
    aws_api_gateway_integration.CreateAddress,
    aws_api_gateway_method_response.CreateAddress-200
  ]
}
################
# Edit Address
###############
resource "aws_api_gateway_method" "EditAddress" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.address-addressId.id
  http_method          = "PUT"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.this.id
  request_validator_id = aws_api_gateway_request_validator.this.id
  request_parameters = {
    "method.request.header.Content-Type" = false,
    "method.request.header.X-Amz-Target" = false,
    "method.request.path.addressId" = true
  }
}

resource "aws_api_gateway_integration" "EditAddress" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.address-addressId.id
  http_method             = aws_api_gateway_method.EditAddress.http_method
  credentials             = module.iam_apigateway_eventbridgeaccess.iam_role_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:eu-central-1:events:action/PutEvents"
  request_templates = {
    "application/json" = <<EOF
#set($context.requestOverride.header.X-Amz-Target = "AWSEvents.PutEvents")
#set($context.requestOverride.header.Content-Type = "application/x-amz-json-1.1")
#set($inputRoot = $input.path("$"))
    { "Entries": [{
    "Detail": "{#foreach($paramName in $inputRoot.keySet())\"$paramName\" : \"$util.escapeJavaScript($inputRoot.get($paramName))\" #if($foreach.hasNext),#end #end,\"userId\": \"$context.authorizer.claims.sub\",\"addressId\": \"$input.params().get('path').get('addressId')\"}",
    "DetailType": "address.updated",
    "EventBusName": "${aws_cloudwatch_event_bus.AddressBus.name}",
    "Source": "customer-profile"
    }]}
EOF
  }
}

resource "aws_api_gateway_method_response" "EditAddress-200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.address-addressId.id
  http_method = aws_api_gateway_method.EditAddress.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "EditAddress" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.address-addressId.id
  http_method = aws_api_gateway_method.EditAddress.http_method
  status_code = aws_api_gateway_method_response.EditAddress-200.status_code
  response_templates = {
    "application/json" : "{}"
  }
  depends_on = [ 
    aws_api_gateway_integration.EditAddress,
    aws_api_gateway_method_response.EditAddress-200
  ]
}
################
# Dlete Address
###############
resource "aws_api_gateway_method" "DeleteAddress" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.address-addressId.id
  http_method          = "DELETE"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.this.id
  request_validator_id = aws_api_gateway_request_validator.this.id
  request_parameters = {
    "method.request.header.Content-Type" = false,
    "method.request.header.X-Amz-Target" = false,
    "method.request.path.addressId" = true
  }
}

resource "aws_api_gateway_integration" "DeleteAddress" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.address-addressId.id
  http_method             = aws_api_gateway_method.DeleteAddress.http_method
  credentials             = module.iam_apigateway_eventbridgeaccess.iam_role_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:eu-central-1:events:action/PutEvents"
  request_templates = {
    "application/json" = <<EOF
#set($context.requestOverride.header.X-Amz-Target = "AWSEvents.PutEvents")
#set($context.requestOverride.header.Content-Type = "application/x-amz-json-1.1")
{
    "Entries": [
    {
        "Detail": "{\"userId\": \"$context.authorizer.claims.sub\",\"addressId\": \"$input.params().get('path').get('addressId')\"}",
        "DetailType": "address.deleted",
        "EventBusName": "${aws_cloudwatch_event_bus.AddressBus.name}",
        "Source": "customer-profile"
    }
    ]
}
EOF
  }
}


resource "aws_api_gateway_method_response" "DeleteAddress-200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.address-addressId.id
  http_method = aws_api_gateway_method.DeleteAddress.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}
resource "aws_api_gateway_integration_response" "DeleteAddress" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.address-addressId.id
  http_method = aws_api_gateway_method.DeleteAddress.http_method
  status_code = aws_api_gateway_method_response.DeleteAddress-200.status_code
  response_templates = {
    "application/json" : "{}"
  }
  depends_on = [ 
    aws_api_gateway_integration.DeleteAddress,
    aws_api_gateway_method_response.DeleteAddress-200
  ]
}



###################
# Favorites - GET 
##################
resource "aws_api_gateway_method" "ListFavorites" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.favorite.id
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_integration" "ListFavorites" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.favorite.id
  http_method             = aws_api_gateway_method.ListFavorites.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_list_user_favorites.lambda_function_invoke_arn
}

###################
# Favorites - POST
###################
resource "aws_api_gateway_method" "AddFavorite" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.favorite.id
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.this.id
    
  request_parameters = {
    "method.request.header.Content-Type" = false,
    "method.request.header.X-Amz-Target" = false
  }
}

resource "aws_api_gateway_integration" "AddFavorite" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.favorite.id
  http_method             = aws_api_gateway_method.AddFavorite.http_method
  credentials             = module.iam_apigateway_sqs_access.iam_role_arn
  integration_http_method = "POST"
  passthrough_behavior    = "NEVER"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.favorites.name}"
  request_parameters = {
    "integration.request.header.Content-Type" : "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = <<EOF
${join("&", [
  "#set($inputRoot = $input.path('$'))",
  "Action=SendMessage",
  "MessageBody=$inputRoot.get('restaurantId')",
  "MessageAttributes.1.Name=CommandName",
  "MessageAttributes.1.Value.StringValue=AddFavorite",
  "MessageAttributes.1.Value.DataType=String",
  "MessageAttributes.2.Name=UserId",
  "MessageAttributes.2.Value.StringValue=$context.authorizer.claims.sub",
  "MessageAttributes.2.Value.DataType=String",
  "Version=2012-11-05"
])}
EOF
  }
}

resource "aws_api_gateway_method_response" "AddFavorite-200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.favorite.id
  http_method = aws_api_gateway_method.AddFavorite.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "AddFavorite" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.favorite.id
  http_method = aws_api_gateway_method.AddFavorite.http_method
  status_code = aws_api_gateway_method_response.AddFavorite-200.status_code
  response_templates = {
    "application/json" : "{}"
  }
  depends_on = [ 
    aws_api_gateway_integration.AddFavorite,
    aws_api_gateway_method_response.AddFavorite-200
  ]
}
# #################################
# # Favorite/{resturantId} - DELETE
# #################################
resource "aws_api_gateway_method" "DeleteFavorite" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.favorite-restaurantId.id
  http_method          = "DELETE"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.this.id
    
  request_parameters = {
    "method.request.header.Content-Type" = false,
    "method.request.header.X-Amz-Target" = false,
    "method.request.path.restaurantId" = true
  }
}

resource "aws_api_gateway_integration" "DeleteFavorite" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.favorite-restaurantId.id
  http_method             = aws_api_gateway_method.DeleteFavorite.http_method
  credentials             = module.iam_apigateway_sqs_access.iam_role_arn
  integration_http_method = "POST"
  passthrough_behavior    = "NEVER"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.favorites.name}"
  request_parameters = {
    "integration.request.header.Content-Type" : "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = <<EOF
${join("&", [
"Action=SendMessage",
"MessageBody=$input.params().get('path').get('restaurantId')",
"MessageAttributes.1.Name=CommandName",
"MessageAttributes.1.Value.StringValue=DeleteFavorite",
"MessageAttributes.1.Value.DataType=String",
"MessageAttributes.2.Name=UserId",
"MessageAttributes.2.Value.StringValue=$context.authorizer.claims.sub",
"MessageAttributes.2.Value.DataType=String",
"Version=2012-11-05"
])}
EOF
  }
}

resource "aws_api_gateway_method_response" "DeleteFavorite-200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.favorite-restaurantId.id
  http_method = aws_api_gateway_method.DeleteFavorite.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "DeleteFavorite" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.favorite-restaurantId.id
  http_method = aws_api_gateway_method.DeleteFavorite.http_method
  status_code = aws_api_gateway_method_response.DeleteFavorite-200.status_code
  response_templates = {
    "application/json" : "{}"
  }
  depends_on = [ 
    aws_api_gateway_integration.DeleteFavorite,
    aws_api_gateway_method_response.DeleteFavorite-200
  ]
}