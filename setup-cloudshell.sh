mkdir -p bin
cd bin
curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
unzip /tmp/terraform.zip terraform
curl -L -o /tmp/cf.tgz "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github"
tar zxf /tmp/cf.tgz cf
export PATH=$PATH:~/bin
cd

