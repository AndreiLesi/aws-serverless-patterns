### Add Address
module "lambda_add_user_address" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-AddUserAddress"
  description   = "My awesome lambda function"
  handler       = "add_user_address.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/address/add_user_address.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME              = aws_dynamodb_table.address.name,
    POWERTOOLS_SERVICE_NAME = "userprofile",
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode                       = "Active"
  layers = [
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
  ]

  allowed_triggers = {
    EventBus = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.AddressAdded.arn
    }
  }

  create_current_version_allowed_triggers = false
}

### Edit Address
module "lambda_edit_user_address" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-EditUserAddress"
  description   = "My awesome lambda function"
  handler       = "edit_user_address.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/address/edit_user_address.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME              = aws_dynamodb_table.address.name,
    POWERTOOLS_SERVICE_NAME = "userprofile",
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode                       = "Active"
  layers = [
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
  ]

  allowed_triggers = {
    EventBus = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.AddressUpdated.arn
    }
  }

  create_current_version_allowed_triggers = false
}

### Delete Address
module "lambda_delete_user_address" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-DeleteUserAddress"
  description   = "My awesome lambda function"
  handler       = "delete_user_address.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/address/delete_user_address.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME              = aws_dynamodb_table.address.name,
    POWERTOOLS_SERVICE_NAME = "userprofile",
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode                       = "Active"
  layers = [
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
  ]

  allowed_triggers = {
    EventBus = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.AddressDeleted.arn
    }
  }

  create_current_version_allowed_triggers = false
}

### List Address
module "lambda_list_user_addresses" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-ListUserAddresses"
  description   = "My awesome lambda function"
  handler       = "list_user_addresses.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/address/list_user_addresses.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME              = aws_dynamodb_table.address.name,
    POWERTOOLS_SERVICE_NAME = "userprofile",
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode                       = "Active"
  layers = [
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
  ]

  allowed_triggers = {
    ApiGateway = {
      principal  = "apigateway.amazonaws.com"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
    }
  }

  create_current_version_allowed_triggers = false
}

######################################################
## Favorites Service - List User Favorite Restaurants
######################################################
module "lambda_list_user_favorites" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-ListUserFavorites"
  description   = "My awesome lambda function"
  handler       = "list_user_favorites.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/favorites/list_user_favorites.py",
  ]

  environment_variables = {
    TABLE_NAME              = aws_dynamodb_table.favorites.name,
    POWERTOOLS_SERVICE_NAME = "favorites",
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode                       = "Active"
  layers = [
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
  ]

  allowed_triggers = {
    ApiGateway = {
      principal  = "apigateway.amazonaws.com"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/GET/favorite"
    }
  }

  create_current_version_allowed_triggers = false
}

##################################################
## Favorites Service - Process Favorite Restaurant
##################################################
module "lambda_list_process_favorites_queue" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-ProcessFavoritesQueue"
  description   = "My awesome lambda function"
  handler       = "process_favorites_queue.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/favorites/process_favorites_queue.py",
  ]

  environment_variables = {
    TABLE_NAME              = aws_dynamodb_table.favorites.name,
    POWERTOOLS_SERVICE_NAME = "favorites",
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"]
  attach_policies                    = true
  number_of_policies                 = 2
  tracing_mode                       = "Active"
  layers = [
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
  ]

  event_source_mapping = {
    sqs = {
      event_source_arn        = aws_sqs_queue.favorites.arn
      # scaling_config = {
      #   maximum_concurrency = 20
      # }
      # metrics_config = {
      #   metrics = ["EventCount"]
      # }
      }
    }

  create_current_version_allowed_triggers = false
}
