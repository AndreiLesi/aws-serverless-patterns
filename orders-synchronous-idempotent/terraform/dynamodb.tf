resource "aws_dynamodb_table" "orders" {
  name           = "${var.project}-Orders"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "userId"
  range_key = "orderId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "orderId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "idempotency" {
  name           = "${var.project}-Idempotency"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expiration"
    enabled = true
  }
}