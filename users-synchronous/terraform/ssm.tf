resource "aws_ssm_parameter" "module-1" {
  name = "/${var.project}/outputs/service/users"
  type = "String"
  value = jsonencode({
    "UsersTable" = aws_dynamodb_table.users.name,
    "UserFunction" = module.lambda_users.lambda_function_arn,
    "APIEndpoint"= aws_api_gateway_stage.this.invoke_url,
    "UserPool" = aws_cognito_user_pool.this.id,
    "UserPoolClient" = aws_cognito_user_pool_client.this.id,
    "UserPoolAdminGroupName" = aws_cognito_user_group.admin.name,
    "CognitoLoginURL" = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.this.id}&response_type=code&redirect_uri=http://localhost",
    "CongitoAuthCommand" = "aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --client-id ${aws_cognito_user_pool_client.this.id} --auth-parameters USERNAME=<user@example.com>,PASSWORD=<password> --query 'AuthenticationResult.IdToken' --output text"
  })
}

