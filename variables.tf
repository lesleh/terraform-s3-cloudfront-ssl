variable "bucket_name" {
  description = "Name of the s3 bucket. Must be unique."
  type        = string
}

variable "tags" {
  description = "Tags to set on the bucket."
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "Domain name to use for the cloudfront distribution."
  type        = string
}

variable "certificate_arn" {
  description = "Certificate ARN to use for the cloudfront distribution."
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 zone ID to apply the domain name to."
  type        = string
}
