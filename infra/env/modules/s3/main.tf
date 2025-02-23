
resource "aws_s3_bucket" "buckets" {  
  for_each = toset(var.bucket_names)  
  bucket   = each.value  
}  

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {  
  for_each = toset(var.bucket_names)  
  bucket   = aws_s3_bucket.buckets[each.key].id  

  rule {  
    object_ownership = "BucketOwnerPreferred"  
  }  
}  

resource "aws_s3_bucket_acl" "bucket_acls" {  
  for_each = toset(var.bucket_names)  
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_controls]  

  bucket = aws_s3_bucket.buckets[each.key].id  
  acl    = "private"  
}
