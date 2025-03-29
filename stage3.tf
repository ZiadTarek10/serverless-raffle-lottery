# Step 1: You should have a domain name or create one manually using Route 53

# Step 2: Request an SSL/TLS certificate for your API domain
resource "aws_acm_certificate" "cert" {
  domain_name       = "api.areulucky.com"  # Replace with your actual domain
  validation_method = "DNS"  # DNS-based validation

  lifecycle {
    create_before_destroy = true
  }
}

# Step 3: Create a Route 53 DNS record for certificate validation
resource "aws_route53_record" "cert_validation" {
  depends_on = [aws_acm_certificate.cert]

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = "Z0844770XWSLLLJPO29E"  # Replace with your hosted zone ID
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Step 4: Validate the certificate using the Route 53 record
resource "aws_acm_certificate_validation" "cert_validation_record" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Step 5: Create an HTTP API in API Gateway
resource "aws_apigatewayv2_api" "api_raffle" {
  name          = "raffle"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = ["http://areulucky.com.s3-website-us-east-1.amazonaws.com", "https://areulucky.com"]
    allow_methods  = ["*"]
    allow_headers  = ["*"]
    expose_headers = ["*"]
  }
}

# Step 6: Create a deployment stage for the API
resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id      = aws_apigatewayv2_api.api_raffle.id
  name        = "dev"
  auto_deploy = true  # Enables automatic deployment when changes are made
}

# Step 7: Create a custom domain name for API Gateway
resource "aws_apigatewayv2_domain_name" "custom_domain_name" {
  domain_name = "api.areulucky.com"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.cert_validation_record.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  mutual_tls_authentication {
    truststore_uri = "s3://raffle-ca-api-gateway/RootCA.pem"  # The Root CA certificate stored in S3
  }
}

# Step 8: Map the custom domain to the API Gateway stage
resource "aws_apigatewayv2_api_mapping" "api_mappin_1" {
  api_id          = aws_apigatewayv2_api.api_raffle.id
  domain_name     = aws_apigatewayv2_domain_name.custom_domain_name.id
  stage           = aws_apigatewayv2_stage.dev_stage.id
  api_mapping_key = "raffle"
}

# Step 9: (Pending) Create route for the count function in the API

# Step 10: (Pending) Add a DNS record for the custom domain in Route 53
