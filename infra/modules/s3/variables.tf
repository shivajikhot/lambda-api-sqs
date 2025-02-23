variable "bucket_names" {  
  type    = list(string)  
  default = ["src-bucket-greeting-card", "dst-bucket-greeting-card"]  
}  
variable "tag_environment" {
  type = string
}
