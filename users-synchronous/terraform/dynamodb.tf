resource "aws_dynamodb_table" "users" {
  name           = "${var.project}-Users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "userid"

  attribute {
    name = "userid"
    type = "S"
  }
}