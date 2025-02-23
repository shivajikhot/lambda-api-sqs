module "s3" {
  source          = "../../modules/s3"
  tag_environment = var.environment
}
module "iam" {
  source         = "../../modules/iam"
  src_bucket_arn = module.s3.src_bucket_arn
  dst_bucket_arn = module.s3.dst_bucket_arn
  greeting_queue_arn = module.sqs.greeting_queue_arn
}

module "sqs" {
  source          = "../../modules/sqs"
  tag_environment = var.environment
}

module "lambda" {
  source                     = "../../modules/lambda"
  depends_on = [ module.s3, module.sqs, module.iam ]
  lambda_execution_role_arn  = module.iam.lambda_execution_role_arn
  src_bucket_arn = module.s3.src_bucket_arn
  src_bucket_id = module.s3.src_bucket_id
  dst_bucket_arn = module.s3.dst_bucket_arn
  dst_bucket_id = module.s3.dst_bucket_id
  lambda_memory_size = var.lambda_memory_size
  greeting_queue_arn = module.sqs.greeting_queue_arn
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn
  tag_environment = var.environment
}
