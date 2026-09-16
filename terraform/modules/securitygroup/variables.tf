variable "name" {
  description = "The name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}


variable "ingress_rules" {
  description = "A list of ingress rules to apply to the security group"
  type = list(object({
    description = string
    from_port   = optional(number)
    to_port     = optional(number)
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "A list of egress rules to apply to the security group"
  type = list(object({
    description = string
    from_port   = optional(number)
    to_port     = optional(number)
    protocol    = string
    cidr_blocks = list(string)
  }))
}