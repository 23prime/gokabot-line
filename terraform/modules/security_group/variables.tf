variable "cost_tag" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "container-http-port" {
  type = number

  default = 8080
}