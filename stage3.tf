#the certificate

resource "aws_acm_certificate" "cert" {
  domain_name       = "api.areulucky.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#Create the record for the certificate in route53

resource "aws_route53_record" "cert_validation" {
  depends_on = [aws_acm_certificate.cert]

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "cert_validation_record" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

#Create HTTP API

resource "aws_apigatewayv2_api" "api_raffle" {
  name          = "raffle"
  protocol_type = "HTTP"
}

#Create the stage

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id = aws_apigatewayv2_api.api_raffle.id
  name   = "dev"
  auto_deploy = true
}


#Create custom domain name

resource "aws_apigatewayv2_domain_name" "custom_domain_name" {
  domain_name              = "api.areulucky.com"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.cert_validation_record.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}



#Create the mapping

resource "aws_apigatewayv2_api_mapping" "api_mappin_1" {
  api_id      = aws_apigatewayv2_api.api_raffle.id
  domain_name = aws_apigatewayv2_domain_name.custom_domain_name.id
  stage       = aws_apigatewayv2_stage.dev_stage.id
  api_mapping_key = "raffle"
}

#Create route for the count function in the api
#add the record of the custom domain name to the route53