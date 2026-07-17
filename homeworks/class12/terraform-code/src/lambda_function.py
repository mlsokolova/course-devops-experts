# Assumptions:
# - A message may contain non-SNS records
# - A message may contain a batch of records
import json
import boto3
import os

# Initialize the DynamoDB resource outside the handler for connection reuse
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE_NAME', 'default_table_name')
table = dynamodb.Table(table_name)

# Set data processing rules
## required fields
expected_fields = ["Message", "Subject"]
## Extract fields from SNS Event
keys = [ "MessageId", "Message", "Subject" ]
## Rename SNS Message fields for DynamoDB
mapping = { "MessageId": "message_id", "Message": "message" , "Subject": "subject" }

def get_sns_events_from_event(event):
    return [ rec["Sns"]  for rec in event.get("Records")  if rec.get("EventSource") == 'aws:sns' ]

def check_expected_fields(rec, expected_fields):
    res = False
    for field_name in expected_fields:
        try:
            val = rec[field_name]
            res = True
        except KeyError:
            print(f"Message {rec} does not contain field {field_name} and will not be processed")
            res = False
    return res

def get_select_keys( rec, keys ):
    return { key: rec[key] for key in keys }

def get_mapping_info(keys, mapping):
    return ",".join([ f"{key} => {mapping.get(key)}"  for key in keys if key in mapping.keys()])

def get_mapping(rec, mapping):
    return { mapping.get(key, key): rec[key] for key in keys }

def lambda_handler(event, context):
    print(event)
    print(context)
    sns_events = get_sns_events_from_event(event)
    print("Check if SNS Messages contains all expected fields")
    checked_sns_events = [ rec for rec in sns_events if check_expected_fields(rec, expected_fields) ]
    print(f"the following fields will be extracted from the SNS Events: { ','.join(keys)}")
    sns_events_selected_keys = [ get_select_keys(sns_event, keys) for sns_event in checked_sns_events ]
    print(f"the following fields will be renamed: {get_mapping_info(keys=keys, mapping=mapping)}")
    sns_events_mapped_fields = [ get_mapping(rec, mapping) for rec in  sns_events_selected_keys ]
    
    for record in sns_events_mapped_fields:
        try:
            # Write to DynamoDB
            print(f"Record {record} will be inserted into DynamoDB table {table_name}")
            table.put_item( Item=record )
            print(f"Successfully processed record: {record}")
            
        except Exception as e:
            print(f"Error processing record: {e}")
            continue

    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }