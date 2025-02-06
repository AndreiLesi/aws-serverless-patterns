resource "aws_dynamodb_table" "address" {
  name           = "${var.project}-AddressTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "user_id"
  range_key      = "address_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "address_id"
    type = "S"
  }
}

#########################
## Favorites Service DB
#########################

resource "aws_dynamodb_table" "favorites" {
  name           = "${var.project}-FavoritesTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "user_id"
  range_key      = "restaurant_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "restaurant_id"
    type = "S"
  }
}