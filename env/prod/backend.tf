terraform {
  backend "s3" {
    bucket = "terraform-state-prod-estudos"         # nome do bucket criado via console
    key    = "prod/terraform.tfstate"          # caminho + nome do arquivo
    region = "us-east-1"
  }
}