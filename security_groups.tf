################################################################################
# CREATING ALB SECUIRTY  GROUP
################################################################################

resource "aws_security_group" "alb_sg" {
  name        = "${var.component}-alb-sg"
  description = "Allow access on http and https from everywhere"
  vpc_id      = local.vpc_id

  tags = {
    Name = "${var.component}-alb-sg"
  }
}

resource "aws_security_group_rule" "ingress_access_on_http" {

  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_access_on_https" {

  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_access_from_everywhere" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

################################################################################
# CREATING APP1 SECUIRTY  GROUP
################################################################################

resource "aws_security_group" "app_static_sg" {
  name        = "${var.component}-app-static-sg"
  description = "Allow alb on port 80"
  vpc_id      = local.vpc_id

  tags = {
    Name = "${var.component}-app-static-sg"
  }
}

resource "aws_security_group_rule" "app_ingress_access_on_http" {

  security_group_id        = aws_security_group.app_static_sg.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "egress_access_from_for_static" {
  security_group_id = aws_security_group.app_static_sg.id
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

################################################################################
# CREATING APP2 SECUIRTY  GROUP
################################################################################
# TODO

################################################################################
# CREATING REGISTRATION APP SECUIRTY  GROUP
################################################################################
resource "aws_security_group" "registration-app-sg" {
  name        = "${var.component}-registration-app-sg"
  description = "Allow alb on port 8080"
  vpc_id      = local.vpc_id

  tags = {
    Name = "${var.component}-registration-app-sg"
  }
}

resource "aws_security_group_rule" "registration_ingress_access_on_http" {

  security_group_id        = aws_security_group.registration-app-sg.id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "registration_access_from_everywhere" {
  security_group_id = aws_security_group.registration-app-sg.id
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

################################################################################
# CREATING DATABASE SECUIRTY  GROUP
################################################################################

resource "aws_security_group" "registration-database-sg" {
  name        = "${var.component}-registration-database-sg"
  description = "Allow registration app on port ${var.port}"
  vpc_id      = local.vpc_id

  tags = {
    Name = "${var.component}-registration-database-sg"
  }
}

resource "aws_security_group_rule" "db-security_ingress_access_on_http" {

  security_group_id        = aws_security_group.registration-database-sg.id
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.registration-app-sg.id
}

resource "aws_security_group_rule" "db-users-security_ingress_access_on_http" {

  security_group_id = aws_security_group.registration-database-sg.id
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = aws_subnet.private_subnet.*.cidr_block
}
