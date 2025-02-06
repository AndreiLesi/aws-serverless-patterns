resource "aws_ssm_parameter" "this" {
  name = "/${var.project}/outputs/service/orders"
  type = "String"
  value = jsonencode({
    "OrdersServiceEndpoint" = aws_api_gateway_stage.this.invoke_url,
    "OrdersTable" = aws_dynamodb_table.orders.name,
  })
}

