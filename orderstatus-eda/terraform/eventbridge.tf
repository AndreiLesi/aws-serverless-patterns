module "event_bus_restaurant" {
  source = "terraform-aws-modules/eventbridge/aws"

  bus_name = "${var.project}-RestaurantBus"

  rules = {
    orders = {
      description   = "Capture all order data"
      event_pattern = jsonencode({
         "source" : ["restaurant"],
         "detail-type": ["order.updated"] 
         })
      enabled       = true
    }
  }

  targets = {
    orders = [
      {
        name            = "SendOrderToLambda"
        arn             = module.lambda_update_order_status.lambda_function_arn
      }
    ]
  }

}