
######################################################
## Favorites Service - List User Favorite Restaurants
######################################################
module "lambda_update_order_status" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project}-UpdateOrderStatus"
  description   = "My awesome lambda function"
  handler       = "update_order_status.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 100

  source_path = [
    "${path.module}/../src/api/update_order_status.py",
  ]

  environment_variables = {
    ORDERS_TABLE_NAME              = "${var.project}-Orders",
    POWERTOOLS_SERVICE_NAME = "OrderStatus",
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
      source_arn = module.event_bus_restaurant.eventbridge_rule_arns["orders"]
    }
  }


  create_current_version_allowed_triggers = false
}