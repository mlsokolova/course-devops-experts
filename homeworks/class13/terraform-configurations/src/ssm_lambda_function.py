import os
import datetime
import boto3

ssm = boto3.client("ssm")
s3 = boto3.client("s3")

parameter_name = os.environ["PARAMETER_NAME"]
s3_bucket = os.environ["S3_BUCKET"]

def lambda_handler(event, context):
    response = ssm.get_parameter(Name=parameter_name, WithDecryption=False)
    value = response["Parameter"]["Value"]
    filename = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
    s3.put_object(
                   Bucket=s3_bucket,
                   Key=filename,
                   Body=value,
                   ContentType="text/plain",
                )
    return {"ok": True, "value": value}
