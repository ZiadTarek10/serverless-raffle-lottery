#Create s3 bucket

resource "aws_s3_bucket" "ca-bucket" {
  bucket = "raffle-ca-api-gateway"
}

#Upload the ca certificate to the s3 bucket
#you have to have the RootCA.pem file in the same directory as the terraform files
resource "aws_s3_object" "rootca" {
  bucket = "raffle-ca-api-gateway"
  key    = "RootCA.pem"
  source = "./RootCA.pem"
}

#add the link of the ca in the s3 bucket to the api gateway custom domain name
#Disable the default endpoint 