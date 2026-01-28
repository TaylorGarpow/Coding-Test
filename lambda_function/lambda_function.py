import boto3
import os
import logging

#Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

#Env Vars
EC2_INSTANCE_ID = os.getenv('EC2_INSTANCE_ID')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')

ec2_client = boto3.client('ec2')
sns_client = boto3.client('sns')

#Function
def lambda_handler(event, context):
    try:
        logger.info(f"Restarting EC2 instance {EC2_INSTANCE_ID}")
        ec2_client.reboot_instances(InstanceIds=[EC2_INSTANCE_ID])
        message = f"EC2 instance {EC2_INSTANCE_ID} has been restarted successfully."
        logger.info(message)
    except Exception as e:
        logger.error(f"Failed to restart Ec2 instance {EC2_INSTANCE_ID}")
        message = f"Failed to restart EC2 instance {EC2_INSTANCE_ID}: {e}"

    #SNS
    try:
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message,
            Subject="EC2 Restart Notification"
        )
        logger.info(f"Notification sent to SNS {SNS_TOPIC_ARN}")
    except Exception as e:
        logger.error(f"Failed to send notification to SNS {SNS_TOPIC_ARN}: {e}")

    return {"status": "success"}