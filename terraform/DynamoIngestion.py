import boto3
import json
import logging
import base64

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
  # Initialize the DynamoDB client
  dynamodb = boto3.client('dynamodb')
   
  # Define the DynamoDB table name
  table_name = 'zendesk_stage'
   
  for record in event['Records']:
    # Parse the SQS message body as JSON
    kinesis_record = record['kinesis']
    message_body=json.loads(base64.b64decode(kinesis_record['data']).decode())
    logger.info(message_body)

    event_type = message_body['eventType']
    # If the event type is UserDeviceRegistered, ignore the message.
    if event_type == 'UserDeviceRegistered' or event_type == 'UserDevicesDeregistered':
      continue
    # Define the data you want to insert into the table from the SQS message
    message_body = {
      'dazn_id': {'S': message_body['id']},
      'object': {'S':'account' },
      'timestamp': {'N': str(message_body['updatedAt'])},
      'email': {'S': message_body['email']},
      'first_name': {'S': message_body['firstName']},
      'last_name': {'S': message_body['lastName']},
      'country': {'S': message_body['country']},
      'language': {'S': message_body['languageLocaleKey']},
      'event': {'S': message_body['eventType']},
    }
     
    try:
      # Insert the data into the DynamoDB table
      response = dynamodb.put_item(TableName=table_name, Item=message_body)
      print("Data inserted successfully:", response)
    except Exception as e:
      print("Error inserting data:", str(e))

  return {
    'statusCode': 200,
    'body': 'Data inserted successfully from SQS messages'
  }