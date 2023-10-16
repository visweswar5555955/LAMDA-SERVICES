import json
import logging
import requests
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.client('dynamodb')

url = "https://daznsupport1690367622.zendesk.com/api/v2/users/create_or_update"


def lambda_handler(event, context):
  # TODO implement
  for record in event['Records']:
    logger.info(json.dumps(record))
    message_body = json.dumps(record['dynamodb'])
    logger.info(message_body)
    new_image = record['dynamodb']['NewImage']
    logger.info(new_image)
    new_body = {
      'user':{
        'external_id': new_image['dazn_id']['S'],
        'email': new_image['email']['S'],
        'name': new_image['first_name']['S']+' '+new_image['last_name']['S'],
        'user_fields':{
          'dazn_id': new_image['dazn_id']['S'],
          'country_code': new_image['country']['S'],
          'language_code': new_image['language']['S']
        }
      }
    }
    logger.info(new_body)
    headers = {"Content-Type": "application/json",}   
    response = requests.request("POST",url,auth=('Omkar.Salyan@dazn.com/token', 'AVgBTfI8OzgmIdNUGHFw5NJsCuoxuU0AJpXj5XDc'),headers=headers,json=new_body)
    print(response.text)
     
  #to send to zendesk   
  # payload = json.loads()   
   
  # 
  # 

  return {
    'statusCode': 200,
    'body': json.dumps('Hello from Lambda!')
  }