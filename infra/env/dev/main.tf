module "s3" {
  source          = "../../modules/s3"
  tag_environment = var.environment
}
