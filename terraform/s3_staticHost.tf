provider "aws" {
  region = "us-east-1" # Change this if needed
}

# Create an S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = "my-task-app-bucket" # Change to a unique name
}

# Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Upload index.html to S3
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "../Frontend/index.html" # Ensure this file is in the same directory as Terraform
  content_type = "text/html"
  acl          = "public-read"
}

# Make the bucket public
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.website_bucket.id}/*"
    }
  ]
}
POLICY
}

# Output the website URL
output "website_url" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}