# APIGateway 5xx Errors
resource "aws_cloudwatch_metric_alarm" "rest_api_errors_alarm" {
  alarm_name                = "${var.project}-RestApiErrorAlarms"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "5XXError"
  namespace                 = "AWS/ApiGateway"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "Goes off if Errors Are Found"
  actions_enabled = true
  alarm_actions = [aws_sns_topic.alarms.arn]
  insufficient_data_actions = []
  dimensions = {
    ApiName = aws_api_gateway_rest_api.this.name
  }
}

# Lambda Authorizer Errors
resource "aws_cloudwatch_metric_alarm" "lambda_authorizer_errors" {
  alarm_name                = "${var.project}-LambdaAuthorizorError"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "Goes off if Errors Are Found"
  actions_enabled = true
  alarm_actions = [aws_sns_topic.alarms.arn]
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_auth.lambda_function_name
  }
}

# Lambda Authorizer Throttles
resource "aws_cloudwatch_metric_alarm" "lambda_authorizer_throttling" {
  alarm_name                = "${var.project}-LambdaAuthorizorThrottle"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Throttles"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "Goes off if Errors Are Found"
  actions_enabled = true
  alarm_actions = [aws_sns_topic.alarms.arn]
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_auth.lambda_function_name
  }
}

# Lambda User Errors
resource "aws_cloudwatch_metric_alarm" "lambda_users_errors" {
  alarm_name                = "${var.project}-LambdaUsersError"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "Goes off if Errors Are Found"
  actions_enabled = true
  alarm_actions = [aws_sns_topic.alarms.arn]
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_users.lambda_function_name
  }
}

# Lambda User Throttles
resource "aws_cloudwatch_metric_alarm" "lambda_users_throttling" {
  alarm_name                = "${var.project}-LambdaUsersThrottle"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Throttles"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "Goes off if Errors Are Found"
  actions_enabled = true
  alarm_actions = [aws_sns_topic.alarms.arn]
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_users.lambda_function_name
  }
}