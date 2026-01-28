## Sumo Logic Query

The Sumo txt file is a baseline query for based on the response time of greater than three seconds.  The response_time shows 3000, but that is because it is set in milliseconds.  We then created a timeslice of 10 minutes to ensure we detect the entries during this window.

## Lambda Function

Creating the lambda function was a little rough for me due to not having much experience with Python.  I am not sure if I said in the video, but I did spend the majority of my day yesterday looking through documentation and trying practice examples for Python.  
This Lambda function successfully rebooted our EC2 instance, and allow SNS to send the notification.

## Terraform IAC

Terraform is definetely my go-to for creating IAC.  The documentation that covers every Terraform resource/module is immense, and will typically be all one needs to look at.  While that may very for extrememly in-depth use cases, for our examples here, the documentation was perfect.  Using that, and base knowledge of Terraform and resources needed for Cloud infrastructure, I was able to create new resources that are able to connect with each other.  