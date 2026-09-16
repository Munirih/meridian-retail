resource "aws_security_group" "sg" {
  name_prefix = var.name
  description = "Security group with inbound rules for ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-sg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  count             = length(var.ingress_rules)
  security_group_id = aws_security_group.sg.id

  description = var.ingress_rules[count.index].description
  ip_protocol = var.ingress_rules[count.index].protocol
  from_port   = var.ingress_rules[count.index].protocol == "-1" ? null : var.ingress_rules[count.index].from_port
  to_port     = var.ingress_rules[count.index].protocol == "-1" ? null : var.ingress_rules[count.index].to_port
  cidr_ipv4   = var.ingress_rules[count.index].cidr_blocks[0]
}

resource "aws_vpc_security_group_egress_rule" "sg" {
  count             = length(var.egress_rules)
  security_group_id = aws_security_group.sg.id

  ip_protocol = var.egress_rules[count.index].protocol
  from_port   = var.egress_rules[count.index].protocol == "-1" ? null : var.egress_rules[count.index].from_port
  to_port     = var.egress_rules[count.index].protocol == "-1" ? null : var.egress_rules[count.index].to_port
  cidr_ipv4   = var.egress_rules[count.index].cidr_blocks[0]
}