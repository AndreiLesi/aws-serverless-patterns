resource "aws_cloudwatch_event_bus" "AddressBus" {
  name = "${var.project}-AddressBus"
}

# ADD ADDRESS
resource "aws_cloudwatch_event_rule" "AddressAdded" {
  name           = "AddressAdded"
  event_bus_name = aws_cloudwatch_event_bus.AddressBus.arn
  event_pattern = jsonencode(
    { "source" : ["customer-profile"],
    "detail-type" : ["address.added"] }
  )
}

resource "aws_cloudwatch_event_target" "AddressAdded" {
  event_bus_name = aws_cloudwatch_event_bus.AddressBus.name
  rule           = aws_cloudwatch_event_rule.AddressAdded.name
  arn            = module.lambda_add_user_address.lambda_function_arn
}
# UPDATE ADDRESS
resource "aws_cloudwatch_event_rule" "AddressUpdated" {
  name           = "AddressUpdated"
  event_bus_name = aws_cloudwatch_event_bus.AddressBus.arn
  event_pattern = jsonencode(
    { "source" : ["customer-profile"],
    "detail-type" : ["address.updated"] }
  )
}

resource "aws_cloudwatch_event_target" "AddressUpdated" {
  event_bus_name = aws_cloudwatch_event_bus.AddressBus.name
  rule           = aws_cloudwatch_event_rule.AddressUpdated.name
  arn            = module.lambda_edit_user_address.lambda_function_arn
}

# DELETE ADDRESS
resource "aws_cloudwatch_event_rule" "AddressDeleted" {
  name           = "AddressDeleted"
  event_bus_name = aws_cloudwatch_event_bus.AddressBus.arn
  event_pattern = jsonencode(
    { "source" : ["customer-profile"],
    "detail-type" : ["address.deleted"] }
  )
}

resource "aws_cloudwatch_event_target" "AddressDeleted" {
  event_bus_name = aws_cloudwatch_event_bus.AddressBus.name
  rule           = aws_cloudwatch_event_rule.AddressDeleted.name
  arn            = module.lambda_delete_user_address.lambda_function_arn
}