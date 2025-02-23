# Create a zip file with function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../app/index.mjs"
  output_path = "lambda.zip"
}

# Create a Lambda function
resource "aws_lambda_function" "greeting_lambda" {
  function_name = "greetings-lambda-function"
  handler     = "index.handler"
  runtime     = "nodejs18.x"
  memory_size = var.lambda_memory_size
  role        = var.lambda_execution_role_arn
  tracing_config {
    mode = "Active"
   }
  environment {
    variables = {
      SRC_BUCKET = var.src_bucket_id,
      DST_BUCKET = var.dst_bucket_id
    }
  }

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags = {
    environment : var.tag_environment
  }
}
resource "aws_lambda_event_source_mapping" "greeting_sqs_mapping" {
  event_source_arn = var.greeting_queue_arn
  function_name    = aws_lambda_function.greeting_lambda.function_name
  batch_size       = 1
}
