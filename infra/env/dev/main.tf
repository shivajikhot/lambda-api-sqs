module "s3" {
  source          = "../../modules/s3"
  tag_environment = var.environment
}
module "iam" {
  source         = "../../modules/iam"
  src_bucket_arn = module.s3.src_bucket_arn
  dst_bucket_arn = module.s3.dst_bucket_arn
}


module "lambda" {
  source                     = "../../modules/lambda"
  depends_on = [ module.s3, module.iam ]
  lambda_execution_role_arn  = module.iam.lambda_execution_role_arn
  src_bucket_arn = module.s3.src_bucket_arn
  src_bucket_id = module.s3.src_bucket_id
  dst_bucket_arn = module.s3.dst_bucket_arn
  dst_bucket_id = module.s3.dst_bucket_id
  lambda_memory_size = var.lambda_memory_size
  tag_environment = var.environment
}

module "apigateway" {
  source = "../../modules/apigateway"
  depends_on = [ module.lambda ]
  greeting_lambda_invoke_arn = module.lambda.greeting_lambda_invoke_arn
  tag_environment = var.environment
}

output "greeting_api_endpoint" {
  value = module.apigateway.greeting_api_endpoint
}
