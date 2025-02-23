output "greeting_lambda_invoke_arn" {
  value = aws_lambda_function.greeting_lambda.invoke_arn
}

output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.greeting_lambda.function_name
}
