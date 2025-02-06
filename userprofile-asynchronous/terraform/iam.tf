#####################################
# ApiGateway Put to EventBridge Role
#####################################
module "iam_apigateway_eventbridgeaccess" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  role_name             = "${aws_api_gateway_rest_api.this.name}-EventBridgeAccessRole"
  trusted_role_services = ["apigateway.amazonaws.com"]
  role_requires_mfa     = false
  create_role           = true
  inline_policy_statements = [
    {
      sid       = "EBPutEvents",
      effect    = "Allow",
      actions   = ["events:PutEvents"],
      resources = [aws_cloudwatch_event_bus.AddressBus.arn]
    }
  ]

}
################################
# ApiGateway Put To Queue Role
################################
module "iam_apigateway_sqs_access" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  role_name             = "${aws_api_gateway_rest_api.this.name}-SQSAccessRole"
  trusted_role_services = ["apigateway.amazonaws.com"]
  role_requires_mfa     = false
  create_role           = true
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
  inline_policy_statements = [
    {
      sid       = "SQSSendMessage",
      effect    = "Allow",
      actions   = ["sqs:SendMessage"],
      resources = [aws_sqs_queue.favorites.arn]
    }
  ]
  

}
