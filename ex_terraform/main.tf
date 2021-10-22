provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "deploy_jenkins" {
  ami                         = "ami-09e67e426f25ce0d7"
  instance_type               = "t2.medium"
  key_name                    = "chave_development_julia"
  count                       = 1
  subnet_id                   = "subnet-0734ecf92f4be11fa"
  associate_public_ip_address = true
  root_block_device {
    encrypted  = true
    kms_key_id = "arn:aws:kms:us-east-1:534566538491:key/90847cc8-47e8-4a75-8a69-2dae39f0cc0d" #key managment service (aws) -> awsmanaged keys -> aws/ebs -> copy arn
    # volume_size = 8
  }
  tags = {
    Name = "Julia-deploy-jenkins-${count.index}"
  }
  vpc_security_group_ids = [aws_security_group.acessos_jenkins_deploy.id]
}


resource "aws_security_group" "acessos_jenkins_deploy" {
  name        = "Julia-acessos_jenkins"
  description = "acessos inbound traffic"
  vpc_id      = "vpc-063fc945cde94d3ab"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
    {
      cidr_blocks      = []
      description      = "Libera acesso jenkins"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 65535
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "allow_ssh_jenkins"
  }
}




output "jenkins" {
  value = [
    for key, item in aws_instance.deploy_jenkins :
    "${key + 1} - ${item.private_ip} - ssh -i ~/.ssh/id_rsa ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

# d82f8d3dd1f243e5b4c1cbd280424c0a jenkins adm password