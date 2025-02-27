module "prod" {
    source = "../../infra"

    nome_repositorio = "producao"
    cargoIAM = "producao"
    ambiente = "producao"
}

output "ip_alb" {
    value = module.prod.ip    # saida referente ao IP do loadbalancer
}