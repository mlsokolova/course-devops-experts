import json
import os

import boto3

client = boto3.client("secretsmanager")
secret_name = os.environ["SECRET_NAME"]


def lambda_handler(event, context):
    response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response["SecretString"])
    password = secret["password"]
    print(len(password))
    return {"ok": True}
