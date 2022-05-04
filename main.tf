resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = <<POLICY
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowCloudFrontOriginAccess",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.cf_access_identity.id}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.s3_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3_bucket.bucket}/*"
        ]
      }
    ]
  }
POLICY
}

resource "aws_cloudfront_origin_access_identity" "cf_access_identity" {
  comment = "Identity for static site"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = [var.domain_name]
  # Huh? Is the next line a spoiler of a future article?
  # web_acl_id          = aws_waf_web_acl.static_site.id

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.s3_bucket.bucket
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    min_ttl     = 0
    default_ttl = 5 * 60
    max_ttl     = 60 * 60

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code = 404
    error_caching_min_ttl = 300
    response_code = 200
    response_page_path = "/index.html"
  }

  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.s3_bucket.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_access_identity.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

resource "aws_route53_record" "static_site_route53_record" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
