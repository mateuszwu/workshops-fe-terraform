variable "price_class" {
  type = string
  description = "AWS cloudfront distribution price class"
  default = "PriceClass_100"
}

variable "origin" {
  type = object({
    domain_name = string
    origin_id = string
    origin_path = string
  })
  description = "AWS cloudfront origin object"
}

variable "route53" {
  type = object({
    zone_name = string
    domain_name = string
  })
  description = "AWS Route53 variables"
}

