output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}
output "api_gateway_greeting_queue_role_arn" {
  value = aws_iam_role.api_gateway_greeting_queue_role.arn
}
