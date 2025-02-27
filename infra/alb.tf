resource "aws_lb" "alb" {
name = "ecs-django"
load_balancer_type = "application"
security_groups = [aws_security_group.alb.id]
subnets = module.vpc.public_subnets
#enable_deletion_protection = true     ( linha para proteção do load balancer referente a edições)
}

resource "aws_lb_listener" "http_listener_alb" {     # recurso relacionado a entrada das requisições do load balancer
  load_balancer_arn = aws_lb.alb.arn
  port              = "8000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alvo.arn
  }
}

resource "aws_lb_target_group" "ecs_alvo" {
  name     = "ecs-django"     # recurso referente ao target será criado em sub rede diferente da do listener, por isso que vamos usar o mesmo nome)
  port     = 8000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = module.vpc.vpc_id
}

output "ip" {         # saida com a info do DNS (url referente a nossa aplicação) 
    value = aws_lb.alb.dns_name
}

