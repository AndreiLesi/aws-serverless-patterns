locals {
  project = "tf-serverless"
  create_users_service = true
  create_orders_service = true
  create_userprofile_service = true
  create_orderstatus_service = true
  default_tags = {
    tags = {
      Creator     = "Andrei Lesi",
      Project     = "ServerlessPatterns"
      Environment = "Production"
    }
  }
}