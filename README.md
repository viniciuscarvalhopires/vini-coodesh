# Infra Challenge 20240202 by Coodesh

>  This is a challenge by [Coodesh](https://coodesh.com/)


### Descrição
Projeto desenvolvido para o desafio da coodesh, que consiste em configurar um servidor baseado na nuvem e instalar e configurar alguns componentes básicos (segurança, rede, infra e também aplicação nginx).

Neste caso, optei por utilizar terraform pela familiaridade e também pela praticidade. 
Decidi criar do zero a vpc, subnet, internet gateway, estabelecer a tabela de roteamento entre o gateway e a vpc para permitir o acesso a internet.

Após isso, defini as regras para o security group:

- Entrada na porta 80 para o CIDR 0.0.0.0/0;
- Saída para qualquer porta.

Para fazer o deploy da aplicação NGINX, elaborei um script em Shell que instala não só o NGINX mas, ainda pensando em segurança também instala o Fail2Ban para proteger o servidor contra tentativas de ataques que conta com o seguinte filtro:

```
 ^<HOST>.*"(GET|POST).*" (400|401|403|404|444|500) .*$
```

O filtro acima captura lê os logs do NGINX e captura linhas que contenham um endereço IP (representado por <HOST>), seguido por qualquer número de caracteres, uma sequência contendo "GET" ou "POST", e então um dos códigos HTTP específicos (400, 401, 403, 404, 444, 500). Caso encontre, e o número de tentativas exceda 5 em um período de 30s, o IP que está acessando é banido por um período de tempo.

Exemplo de como está configurado:
```
[nginx]
enabled = true
port = http,https
filter = nginx
logpath = /var/log/nginx*/*access.log
action = iptables-multiport[name=404, port="http,https", protocol=tcp]
maxretry = 5
findtime = 30
bantime = 7200
```

Lembrando que o script foi inserido como user_data, o que significa que ele é executado no momento de criação da instância.

Para mais detalhes sobre a instalação das aplicações, basta acessar o script em files/setup.sh


### Pipeline

![Main workflow](https://i.imgur.com/kMUELnP.jpeg)

A primeira pipeline desenvolvida foi para que assim que tenha algum push para o repositório, os recursos definidos sejam provisionados, seguindo os principais comandos (init, plan, validate e apply).

Para facilitar a exclusão dos recursos, elaborei também um workflow para ser executado manualmente.

![Manual workflow](https://i.imgur.com/6yn80kX.jpeg)

## Nota: Para acesso a instância EC2, evitei liberar a porta SSH para a rede pública por questões de segurança, portanto, futuramente seria interessante utilizar algum serviço de VPN e refazer as configurações de segurança da VPC, ou utilizar o EC2 Instance Connect ou até mesmo uma outra instância como Bastion para acessar o servidor NGINX. 


### Tecnologias utilizadas

- AWS;
- Terraform;
- Shell script (Bash);
- Aplicações (nginx e fail2ban).


### Rodando localmente

Clone o projeto

```bash
  git clone https://github.com/viniciuscarvalhopires/vini-coodesh
```

Entre no diretório do projeto

```bash
  cd vini-coodesh
```

Exporte suas credencias da AWS para variáveis de ambiente

```bash
  export AWS_SECRET_ACCESS_KEY="<aws_secret_access_key>" 
  export AWS_ACCESS_KEY_ID="<aws-access_key_id>"
  export AWS_REGION="<aws-region>"
```

#### Lembre-se que o bucket S3 utilizado deve estar previamente criado na AWS. Certifique-se de que os valores de região, zonas de disponibilidade e o nome do bucket estejam corretos nos arquivos main.tf e provider.tf

```bash
bucket_name = "coodesh-challenge"
bucket_key = "terraform.tfstate"
aws_region = "us-east-1"
```


Utilizando o terraform, execute os seguintes comandos

```bash
  terraform init
  terraform validate
  terraform plan
```

Com as configurações validadas, basta aplicar o apply

```bash
  terraform apply -auto-approve
```

