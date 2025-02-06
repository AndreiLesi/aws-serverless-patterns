output "AddressBus" {
  value = aws_cloudwatch_event_bus.AddressBus.id
}

output "AddressTable" {
  value = aws_dynamodb_table.address.name
}

output "UserProfileApiGateway" {
  value = aws_api_gateway_stage.this.invoke_url
}

output "FavoriteSQSUrl" {
  value = aws_sqs_queue.favorites.url
}

output "FavoriteTable" {
  value = aws_dynamodb_table.favorites.name
}