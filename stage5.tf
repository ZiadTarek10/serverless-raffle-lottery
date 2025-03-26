#Creating the bucket
resource "aws_s3_bucket" "website" {
  bucket = "areulucky.com"
}

#allow public access to the bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#enable the website configuration
resource "aws_s3_bucket_website_configuration" "properties" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "apply.html"
  }
}

#upload the files to the bucket
resource "aws_s3_object" "applyfile" {
  bucket      = aws_s3_bucket.website.id
  key         = "apply.html"
  source      = "./apply.html"
  content_type = "text/html"
}

resource "aws_s3_object" "drawfile" {
  bucket      = aws_s3_bucket.website.id
  key         = "draw.html"
  source      = "./draw.html"
  content_type = "text/html"
}


# Add a bucket policy that makes your bucket content publicly available
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.bucket_content_publicly_available.json
}

  data "aws_iam_policy_document" "bucket_content_publicly_available" {
    statement {
      sid       = "PublicReadGetObject"
      effect    = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions   = ["s3:GetObject"]
      resources = ["${aws_s3_bucket.website.arn}/*"]
    }
  }

resource "aws_acm_certificate" "cert2" {
  domain_name       = "areulucky.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#Create the record for the certificate in route53
resource "aws_route53_record" "cert_validation2" {
  depends_on = [aws_acm_certificate.cert2]

  for_each = {
    for dvo in aws_acm_certificate.cert2.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = "Z0844770XWSLLLJPO29E" 
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}
#validat the certificate

resource "aws_acm_certificate_validation" "cert_validation_record2" {
  certificate_arn         = aws_acm_certificate.cert2.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation2 : record.fqdn]
}

resource "aws_s3_object" "applyhtml" {
  bucket = "areulucky.com"
  key    = "apply.html"
  source = "./apply.html"
}
resource "aws_s3_object" "drawhtml" {
  bucket = "areulucky.com"
  key    = "draw.html"
  source = "./draw.html"
}


#create cloudfront
#create the record of the cloud front in route53