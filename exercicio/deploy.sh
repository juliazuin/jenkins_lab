!/bin/bash

cd /workspace/jenkins_lab/exercicio/ex_terraform/terraform
/workspace/jenkins_lab/exercicio/ex_terraform/terraform init
/workspace/jenkins_lab/exercicio/ex_terraform/terraform apply -auto-approve

echo "Aguardando criação de maquinas ..."
sleep 10 # 10 segundos

echo $"[ec2-dev-img-jenkins]" > ../ansible/hosts # cria arquivo
echo "$(~/workspace/jenkins_lab/exercicio/ex_terraform/terraform output | grep public_dns | awk '{print $2;exit}')" | sed -e "s/\",//g" >> /workspace/jenkins_lab/exercicio/ex_ansible/ansible/hosts # captura output faz split de espaco e replace de ",

echo "Aguardando criação de maquinas ..."
sleep 10 # 10 segundos

sudo apt install ansible

cd /workspace/jenkins_lab/exercicio/ex_ansible/ansible

echo "Executando ansible ::::: [ ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /var/lib/jenkins/.ssh/id_rsa ]"
sudo ansible-playbook -i /workspace/jenkins_lab/exercicio/ex_ansible/hosts /workspace/jenkins_lab/exercicio/ex_ansible/provisionar.yml