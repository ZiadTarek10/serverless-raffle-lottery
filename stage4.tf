# Create an S3 bucket for storing CA certificates
resource "aws_s3_bucket" "ca-bucket" {
  bucket = "raffle-ca-api-gateway"
}

# Upload the CA certificate to the S3 bucket
# Ensure the RootCA.pem file is in the same directory as the Terraform files
resource "aws_s3_object" "rootca" {
  bucket = aws_s3_bucket.ca-bucket.id
  key    = "RootCA.pem"
  source = "./RootCA.pem"
}
#add the link of the ca in the s3 bucket to the api gateway custom domain name
#Disable the default endpoint 
#create draw and apply routes 