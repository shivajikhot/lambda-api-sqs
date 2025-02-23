variable "bucket_names" {  
  type    = list(string)  
  default = ["src-bucket-some-random-string", "dst-bucket-some-random-string"]  
}  
variable "tag_environment" {
  type = string
}
