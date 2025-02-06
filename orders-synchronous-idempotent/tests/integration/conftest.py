import boto3
import os
import pytest
import uuid
import json
from datetime import datetime
from decimal import Decimal


SSM_OUTPUTS_PATH_USERS = "/tf-serverless/outputs/service/users"
SSM_OUTPUTS_PATH_ORDERS = "/tf-serverless/outputs/service/orders"
globalConfig = {}


def get_stack_outputs(parameter_name):
    ssm = boto3.client("ssm")
    
    response = ssm.get_parameter(Name=parameter_name)
    outputs = json.loads(response["Parameter"]["Value"])  # Convert JSON string to dictionary
    
    return outputs

def create_cognito_accounts():
    result = {}
    sm_client = boto3.client('secretsmanager')
    idp_client = boto3.client('cognito-idp')
    
    # Get a random password from Secrets Manager
    secrets_manager_response = sm_client.get_random_password(
        ExcludeCharacters='"''`[]{}():;,$/\\<>|=&', RequireEachIncludedType=True)
    result["user1UserName"] = "user1User@example.com"
    result["user1UserPassword"] = secrets_manager_response["RandomPassword"]

    # Delete any existing users before creating new
    try:
        idp_client.admin_delete_user(UserPoolId=globalConfig["UserPool"],
                                     Username=result["user1UserName"])
    except idp_client.exceptions.UserNotFoundException:
        print('User1 not found; no deletion necessary. Continuing...')

    # Create a new user
    idp_response = idp_client.admin_create_user(
        UserPoolId=globalConfig["UserPool"],
        Username=result["user1UserName"],
        UserAttributes=[{"Name": "name", "Value": result["user1UserName"]}],
        TemporaryPassword=result["user1UserPassword"],
        MessageAction='SUPPRESS',
        DesiredDeliveryMediums=[],
    )
    # Change the temporary password
    secrets_manager_response = sm_client.get_random_password(
        ExcludeCharacters='"''`[]{}():;,$/\\<>|=&', RequireEachIncludedType=True)
    result["user1UserPassword"] = secrets_manager_response["RandomPassword"]    
    idp_client.admin_set_user_password(
        UserPoolId=globalConfig["UserPool"],
        Username=result["user1UserName"],
        Password=result["user1UserPassword"],
        Permanent=True
    )
    result["user1UserSub"] = idp_response["User"]["Username"]

    # Get new user authentication info
    idp_response = idp_client.initiate_auth(
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': result["user1UserName"],
            'PASSWORD': result["user1UserPassword"]
        },
        ClientId=globalConfig["UserPoolClient"],
    )
    result["user1UserIdToken"] = idp_response["AuthenticationResult"]["IdToken"]
    result["user1UserAccessToken"] = idp_response["AuthenticationResult"]["AccessToken"]
    result["user1UserRefreshToken"] = idp_response["AuthenticationResult"]["RefreshToken"]

    return result

def clear_dynamo_tables():
    """
    Clear all pre-existing data from the tables prior to testing.
    """
    dbd_client = boto3.client('dynamodb')
    db_response = dbd_client.scan(
        TableName=globalConfig['OrdersTable'],
        AttributesToGet=['userId', 'orderId']
    )
    for item in db_response["Items"]:
        dbd_client.delete_item(
            TableName=globalConfig['OrdersTable'],
            Key={'userId': {'S': item['userId']["S"]},
                 'orderId': {'S': item['orderId']["S"]}}
        )

@pytest.fixture(scope='session')
def global_config(request):
    """
    Load stack outputs, create user accounts, and clear database tables.
    """
    global globalConfig
    # load outputs of the stacks to test
    globalConfig.update(get_stack_outputs(SSM_OUTPUTS_PATH_USERS))
    globalConfig.update(get_stack_outputs(SSM_OUTPUTS_PATH_ORDERS))
    globalConfig.update(create_cognito_accounts())
    clear_dynamo_tables()
    return globalConfig

@pytest.fixture(scope='function')
def acknowledge_order_hook(request):
    """
    Fixture to set up an order to test cancel_order() operation.
     - Before test: Creates an order in the database with "ACKNOWLEDGED" order status
     - After test: Removes previously created order
    """
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(globalConfig['OrdersTable'])

    # Create an order with "ACKNOWLEDGED" status
    order_id = str(uuid.uuid4())
    user_id = globalConfig['user1UserSub']
    order_data = {
        'orderId': order_id,
        'userId': user_id,
        'data': {
            'orderId': order_id,
            'userId': user_id,
            'restaurantId': 2,
            'orderItems': [
                {
                    'name': 'Artichoke Ravioli',
                    'price': 9.99,
                    'id': 1,
                    'quantity': 1
                }
            ],
            'totalAmount': 9.99,
            'status': 'ACKNOWLEDGED',
            'orderTime': datetime.strftime(datetime.utcnow(), '%Y-%m-%dT%H:%M:%SZ'),
        }
    }

    ddb_item = json.loads(json.dumps(order_data), parse_float=Decimal)
    table.put_item(Item=ddb_item)

    globalConfig['ackOrderId'] = order_id

    # Next, the test will run...
    yield

    # After the test runs; delete the item
    key = {
        'userId': user_id,
        'orderId': order_id
    }

    table.delete_item(Key=key)