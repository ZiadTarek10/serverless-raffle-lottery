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
  bucket       = aws_s3_bucket.website.id
  key          = "apply.html"
  source       = "./apply.html"
  content_type = "text/html"
}

resource "aws_s3_object" "drawfile" {
  bucket       = aws_s3_bucket.website.id
  key          = "draw.html"
  source       = "./draw.html"
  content_type = "text/html"
}

# Add a bucket policy that makes your bucket content publicly available
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.bucket_content_publicly_available.json
}

data "aws_iam_policy_document" "bucket_content_publicly_available" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
  }
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

#Create the certificate for the domain name areulucky.com
resource "aws_acm_certificate" "cert2" {
  domain_name       = "areulucky.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#Create the record for the certificate in route53
resource "aws_route53_record" "cert2_validation" {
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

# Validate the ACM certificate
resource "aws_acm_certificate_validation" "cert2_validation" {
  certificate_arn         = aws_acm_certificate.cert2.arn
  validation_record_fqdns = [for record in aws_route53_record.cert2_validation : record.name]
}

#Create cloudfront distribution without logging

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  default_root_object = "apply.html"

  aliases = ["areulucky.com", "www.areulucky.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:417650894786:certificate/e1581fb2-953c-4bd9-833e-e0f929b49350"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "S3OriginAccessControl"
  description                       = "OAC for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
