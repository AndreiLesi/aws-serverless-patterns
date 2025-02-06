resource "aws_ssm_parameter" "this" {
  name = "/${var.project}/outputs/service/orderstatus"
  type = "String"
  value = jsonencode({
    "RestaurantBusName" = module.event_bus_restaurant.eventbridge_bus_name,
  })
}

