terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

provider "aws" {
    region = "us-east-2"
}

#EC2 Instance
resource "aws_instance" "coding_test" {
    ami = "ami-03ea746da1a2e36e7"
    instance_type = "t3.micro"
    tags = {
        Name = "Coding-test"
    }
}

#SNS
resource "aws_sns_topic" "update" {
    name = "ec2-restart-topic"
}

resource "aws_sns_topic_subscription" "email" {
    topic_arn = aws_sns_topic.update.arn
    protocol = "email"
    endpoint = "tgarpow45@yahoo.com"
}

#Lambda role
resource "aws_iam_role" "lambda_role" {
    name = "lambda_restart_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "lambda_policy" {
    name = "lambda_restart_policy"
    role = aws_iam_role.lambda_role.id
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = ["ec2:RebootInstances"],
                Effect = "Allow",
                Resource = aws_instance.coding_test.arn
            },
            {
                Action = ["sns:Publish"],
                Effect = "Allow",
                Resource = aws_sns_topic.update.arn
            },
            {
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_lambda_function" "ec2_restart" {
    function_name = "ec2_restart"
    runtime = "python3.9"
    handler = "lambda_function.lambda_handler"
    role = aws_iam_role.lambda_role.arn
    filename = "../lambda_function/lambda_function.zip"

    environment {
        variables = {
            EC2_INSTANCE_ID = aws_instance.coding_test.id
            SNS_TOPIC_ARN = aws_sns_topic.update.arn
        }
    }
}

resource "aws_lambda_permission" "allow" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.ec2_restart.function_name
    principal = "sns.amazonaws.com"
}