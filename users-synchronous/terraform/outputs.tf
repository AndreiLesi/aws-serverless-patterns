output "UserTable" {
  value = aws_dynamodb_table.users.name
}

output "APIEndpoint" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "CongitoURL" {
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.eu-central-1.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.this.id}&response_type=code&redirect_uri=http://localhost"
}

output "CongitoAuthCoomand" {
  value = "aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --client-id ${aws_cognito_user_pool_client.this.id} --auth-parameters USERNAME=lesi.andrei@gmail.com,PASSWORD=SeraDop13Okt#SS --query 'AuthenticationResult.IdToken' --output text"
}

output "UserPoolArn" {
  value = aws_cognito_user_pool.this.arn
}