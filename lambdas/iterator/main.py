import boto3
import os

client = boto3.client('lambda')


def lambda_handler(event, context):
    client.invoke(
        FunctionName=os.environ['LAMBDA_ARN'],
        InvocationType='Event',
        Payload=os.environ['PAYLOAD'].encode()
    )
    index = event['iterator']['index'] + 1
    return {
        'index': index,
        'continue': index < event['iterator']['count'],
        'count': event['iterator']['count']
    }
