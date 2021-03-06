variable "cost_tag" {
  type = string
}

variable "vpc" {
  type = any
}

variable "subnets" {
  type = object({
    a = any,
    c = any
  })
}

variable "target" {
  type = object({
    port        = number
    protocol    = string
    target_type = string

    health_check = object({
      enabled             = bool
      interval            = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })

    stickiness = object({
      enabled = bool
      type    = string
    })
  })

  default = {
    port        = 8080
    protocol    = "TCP"
    target_type = "ip"

    health_check = {
      enabled             = true
      interval            = 30
      healthy_threshold   = 3
      unhealthy_threshold = 3
    }

    stickiness = {
      enabled = false
      type    = "source_ip"
    }
  }
}

variable "domain" {
  type = string
}

variable "s3_bucket" {
  type = any
}
