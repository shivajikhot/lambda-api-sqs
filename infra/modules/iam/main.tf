# Execution role
resource "aws_iam_role" "lambda_execution_role" {
  name = "terraform-lambda-greetings-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# Access policy
resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "terraform-lambda-s3-access-policy"
  description = "Grants access to source and destination buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:ListBucket"],
        Effect   = "Allow",
        Resource = [
          var.src_bucket_arn
        ]
      },
      {
        Action   = ["s3:GetObject"],
        Effect   = "Allow",
        Resource = [
          "${var.src_bucket_arn}/*"
        ]
      },
      {
        Action   = ["s3:PutObject"],
        Effect   = "Allow",
        Resource = [
          "${var.dst_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Attaches the policy to the role
resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}
###################################################
resource "aws_iam_policy" "greeting_lambda_sqs_policy" {
  name        = "greeting_lambda_sqs_policy"
  description = "Grants access to read messages from SQS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMEssage", "sqs:GetQueueAttributes"],
        Effect   = "Allow",
        Resource = [var.greeting_queue_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "greeting_lambda_sqs_policy_attachment" {
  policy_arn = aws_iam_policy.greeting_lambda_sqs_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}


################# Create IAM Role and policy for invoking the Greetings Queue
resource "aws_iam_role" "api_gateway_greeting_queue_role" {
  name = "api_gateway_greeting_queue_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_greeting_queue_role_policy" {
  name = "api_gateway_greeting_queue_role_policy"
  role = aws_iam_role.api_gateway_greeting_queue_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = var.greeting_queue_arn
      }
    ]
  })
}

###############MONITORING###################
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_attach" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_Xray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.lambda_execution_role.name
}
