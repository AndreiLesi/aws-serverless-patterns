resource "aws_ssm_parameter" "this" {
  name = "/${var.project}/outputs/service/userprofile"
  type = "String"
  value = jsonencode({
    "AddressBuss" = aws_cloudwatch_event_bus.AddressBus.name,
    "AddressTable" = aws_dynamodb_table.address.name,
    "ProfileApiEndpoint" = aws_api_gateway_stage.this.invoke_url,
    "FavoriteSQSUrl" = aws_sqs_queue.favorites.url,
    "FavoriteTable" = aws_dynamodb_table.favorites.name
  })
}

