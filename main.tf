## Deploy Service Users
module "service-users" {
    count = local.create_users_service ? 1:0
    source = "./users-synchronous/terraform"
    project = local.project
}

## Deploy Orders Service
module "service-orders" {
    count = local.create_orders_service ? 1:0
    source = "./orders-synchronous-idempotent/terraform"
    project = local.project
    UserPoolArn = module.service-users[0].UserPoolArn
}

## Deploy UserProfile Service
module "service-userprofile" {
    count = local.create_userprofile_service ? 1:0
    source = "./userprofile-asynchronous/terraform"
    project = local.project
    UserPoolArn = module.service-users[0].UserPoolArn
}

## Deploy OrderStatus Service
module "service-orderstatus" {
    count = local.create_orderstatus_service ? 1:0
    source = "./orderstatus-eda/terraform"
    project = local.project
    UserPoolArn = module.service-users[0].UserPoolArn
}