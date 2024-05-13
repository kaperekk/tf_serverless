provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
  acl    = "private"
}

resource "aws_sqs_queue" "queue" {
  name = "my-queue"
}


resource "aws_lambda_function" "lambda_function" {
  function_name = "image_resizer"
  image_uri = "<account-id>.dkr.ecr.<region>.amazonaws.com/my-lambda:latest"
  memory_size = 128
  timeout = 60
  role = aws_iam_role.example.arn
  package_type = "Image"
}

resource "aws_lambda_event_source_mapping" "sqs_mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.function.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
  }
}

resource "aws_iam_role" "lambda" {
  name = "lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
    }]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name = "lambda"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "s3:GetObject",
        "s3:PutObject",
      ],
      Resource = "*",
      Effect   = "Allow",
    }]
  })
}