resource "aws_iam_role" "cargo" {
  name = "${var.cargoIAM}_cargo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ec2.amazonaws.com",
                     "ecs-tasks.amazonaws.com"] 
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_ecr" {    # recurso que o ECS acesse o ECR
  name = "ecs_ecr"
  role = aws_iam_role.cargo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",     # pegar token para acessar o ECR
          "ecr:BatchCheckLayerAvailability",    # checar os layers da imagem no ECR
          "ecr:GetDownloadUrlForLayer",   # pegar a URL d download de cada layer para usarmos a imagem
          "ecr:BatchGetImage",     # pegar a imagem de forma geral para utilizarmos
          "logs:CreateLogStream",     # criar os logs
          "logs:PutLogEvents",    # inserir eventos nos logs para monitoração da aplicação
          "logs:CreateLogGroup",
          "logs:ListTagsLogGroup",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "ecs:ExecuteCommand",        # permissão para acesso ao container
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:TerminateSession"

        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.cargoIAM}_profile"
  role = aws_iam_role.cargo.name
}