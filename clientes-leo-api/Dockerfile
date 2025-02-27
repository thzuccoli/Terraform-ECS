FROM python:3                 
# imagem base da aplicação em python

ENV PYTHONDONTWRITEBYTECODE=1
# ação de melhorar a performance do python

ENV PYTHONUNBUFFERED=1
# jogar todas as saidas do python para o console (evitar travamento)

WORKDIR /home/ubuntu/tcc/
# diretorio de trabalho

COPY . /home/ubuntu/tcc/
# ação copiar todo o conteudo da pasta clientes-leo-api para o workdir

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*
# Instalar dependências necessárias para o agente (como curl e bash)

RUN curl -Lo /usr/local/bin/ecs-execute-command-agent https://amazon-ecs-execute-command-agent.s3.amazonaws.com/latest/ecs-execute-command-agent-linux-x86_64 \
    && chmod +x /usr/local/bin/ecs-execute-command-agent   
# Baixar e instalar o agente ExecuteCommand

RUN pip install -r requirements.txt
# instalação das dependencias conforme info denttro arquivo

RUN sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['*'\]/" setup/settings.py
# substituição da linha para permitir que acessamos de qualquer lugar (final da linha informa o caminho + arquivo a ser alterado)
# [] para não ser considerado caracterer especial, precisamos inserir a barra invertida

RUN python manage.py migrate
# configurando o banco de dados

RUN python manage.py loaddata clientes.json
# carregar os dados do banco

CMD ["/bin/sh", "-c", "/usr/local/bin/ecs-execute-command-agent & exec python app.py"]
# Adicionar o comando para executar o agente ExecuteCommand em segundo plano ao iniciar o contêiner

ENTRYPOINT python manage.py runserver 0.0.0.0:8000
# ação de iniciar o servidor atraves do comando do python no docker

EXPOSE 8000
# expondo o container na porta 8000