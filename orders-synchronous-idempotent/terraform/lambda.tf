### Add Order
module "lambda_add_order" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-AddOrder"
  description   = "My awesome lambda function"
  handler       = "create_order.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/order/create/create_order.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.orders.name,
    IDEMPOTENCY_TABLE_NAME = aws_dynamodb_table.idempotency.name
    POWERTOOLS_SERVICE_NAME = "orders",
    POWERTOOLS_METRICS_NAMESPACE = "ServerlessWorkshop"
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode = "Active"

  layers = ["arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"]

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
      # source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/Prod/*/*"
    }
  }

  create_current_version_allowed_triggers = false
}

### LAMBDA LAYER
module "lambda_layer_pyutils" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "PyUtils"
  description         = "PyUtils for reading item from db"
  compatible_runtimes = ["python3.10"]

  source_path = "${path.module}/../src/layers/"
}

### Get Order
module "lambda_get_order" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-GetOrder"
  description   = "My awesome lambda function"
  handler       = "get_order.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/order/get/get_order.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.orders.name,
        POWERTOOLS_SERVICE_NAME = "orders",
        POWERTOOLS_METRICS_NAMESPACE = "ServerlessWorkshop"
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode = "Active"
  layers = [
    module.lambda_layer_pyutils.lambda_layer_arn,
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
    ]

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
      # source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/Prod/*/*"
    }
  }

  create_current_version_allowed_triggers = false
}

### List Orders
module "lambda_list_orders" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-ListOrders"
  description   = "My awesome lambda function"
  handler       = "list_orders.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/order/list/list_orders.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.orders.name,
    POWERTOOLS_SERVICE_NAME = "orders",
    POWERTOOLS_METRICS_NAMESPACE = "ServerlessWorkshop"
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode = "Active"
  layers = ["arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"]

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
      # source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/Prod/*/*"
    }
  }

  create_current_version_allowed_triggers = false
}

### Edit Order
module "lambda_edit_order" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-EditOrder"
  description   = "My awesome lambda function"
  handler       = "edit_order.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/order/edit/edit_order.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.orders.name,
    POWERTOOLS_SERVICE_NAME = "orders",
    POWERTOOLS_METRICS_NAMESPACE = "ServerlessWorkshop"
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode = "Active"
  layers = [
    module.lambda_layer_pyutils.lambda_layer_arn,
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
  ]

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
      # source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/Prod/*/*"
    }
  }

  create_current_version_allowed_triggers = false
}

### Cancel Order
module "lambda_cancel_order" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-CancelOrder"
  description   = "My awesome lambda function"
  handler       = "cancel_order.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/order/cancel/cancel_order.py",
    # {
    #   pip_requirements = "${path.module}/../src/api/requirements.txt",
    # }
  ]

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.orders.name,
    POWERTOOLS_SERVICE_NAME = "orders",
    POWERTOOLS_METRICS_NAMESPACE = "ServerlessWorkshop"
  }

  ignore_source_code_hash            = false
  attach_cloudwatch_logs_policy      = true
  attach_tracing_policy              = true
  attach_create_log_group_permission = true
  policies                           = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_policies                    = true
  number_of_policies                 = 1
  tracing_mode = "Active"
  layers = [
    module.lambda_layer_pyutils.lambda_layer_arn,
    "arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:7"
    ]

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
      # source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/Prod/*/*"
    }
  }

  create_current_version_allowed_triggers = false
}
