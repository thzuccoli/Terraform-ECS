module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  
  cluster_name = var.ambiente
  cluster_settings = [
    {
      "name" : "containerInsights",
      "value" : "enabled"
    }
  ]
  default_capacity_provider_use_fargate = true
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy ={
        weight = 1
      }
    }
  }
}

resource "aws_ecs_task_definition" "Django-API-task" {
  family                   = "Django-API-Task"      # as tarefas criadas podem ser executadas + 1 vez (familia de tasks) (nome é a aplicação_)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn         # linha referente a role criada para acesso ao ECR e o cargo de execução   
  container_definitions    = jsonencode(    # configurações do container (portas da aplicação, limites que a aplicação pode chegar, como fazer as requisições para a aplicação)
[
  {
    "name" = "producao"      # nome do container
    "image" = "897729100836.dkr.ecr.us-east-1.amazonaws.com/producao:v2"    # imagem do container (puxar no docker push)
    "cpu" = 256    # limite da CPU para aplicação conforme informado no CPU do fargate acima
    "memory" = 512     # limite de memória para aplicação conforme informado no memory do fargate acima
    "essential" = true     # essencial o gerenciamento/ manuseio do container 
    "portMappings" = [         # configuração das portas do container e do host (instancia criada pelo fargate)
        {
          "containerPort" = 8000
          "hostPort"      = 8000
        }
      ]
    }
]
)
  # opção abaixo é somente para criação de cluster via EC2 (usando o fargate, o mesmo decide essa configuração)
  # runtime_platform {
    # operating_system_family = "WINDOWS_SERVER_2019_CORE"
    # cpu_architecture        = "X86_64"
}

resource "aws_ecs_service" "Django-API-service" {
  name            = "Django-API-Service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.Django-API-task.arn
  desired_count   = 3         # qtdade de instancias a ser criada os serviços
  # iam_role        = aws_iam_role.foo.arn      (linha ignorado devido o IAM Role conter dentro da task definition)

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alvo.arn
    container_name   = "producao"
    container_port   = 8000
  }

  network_configuration {        # configuração que garante sempre que a nossa apicação seja criada na rede correta e reconhecida pelo loadbalancer
    subnets = module.vpc.private_subnets
    security_groups = [aws_security_group.private.id]
  }

  capacity_provider_strategy {      # configuração que define sempre a subida de instancias pelo fargate (evitar pelo ec2)
    capacity_provider = "FARGATE"     # opções FARGATE, FARGET SPOT OU EC2
    weight = 1   # 100/100 = 1    (linha referente ao peso (queremos 100% da capacidade no fargate))
  }
}