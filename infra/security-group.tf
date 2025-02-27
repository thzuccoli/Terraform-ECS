resource "aws_security_group" "alb" {
  name        = "alb-ecs"
  vpc_id      = module.vpc.vpc_id     # modulo informado no arquivo vpc.tf
}

resource "aws_security_group_rule" "tcp_alb_public_ingress" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "tcp_alb_public_egress" {
  type              = "egress"
  from_port         = 0     #saida para qualquer porta
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "private" {
  name        = "private-ecs"
  vpc_id      = module.vpc.vpc_id     # modulo informado no arquivo vpc.tf
}

resource "aws_security_group_rule" "entrada_ecs" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id       = aws_security_group.alb.id     # receber requisições somente do grupo de segurança do load balancer
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "saida_ecs" {
  type              = "egress"
  from_port         = 0     #saida para qualquer porta
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
}