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
