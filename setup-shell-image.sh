#!/bin/bash

BINDIR="${HOME}/bin"
GITUSER="Scott Brightwell"
GITEMAIL="scott@brightwell.org"

INSTALL_BINARIES=true
SETUP_GIT=true
SETUP_BASH=true

function setup-git {
	git config --global user.name "${GITUSER}"
	git config --global user.email "${GITEMAIL}"
}

function setup-bash-it {
	git clone http://github.com/scottbri/bash-it
	mv bash-it ${HOME}/.bash-it
	${HOME}/.bash-it/install.sh --silent
  mv ${HOME}/.bash-it/dot.bash_profile ${HOME}/.bash_profile
  mv ${HOME}/.bash-it/dot.bash_prompt ${HOME}/.bash_prompt
  rm ${HOME}/.bashrc 
}

function install-binaries {
	wget -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
	apt-get update
	apt-get install -y unzip build-essential ruby-dev ruby python vim
  apt-get install -y cf-cli 

  
	mkdir ${BINDIR} || exit 1

  DIRENV=direnv_2.15.0-1_amd64.deb
  wget -q http://mirrors.kernel.org/ubuntu/pool/universe/d/direnv/direnv_2.15.0-1_amd64.deb
  apt install ./$DIRENV
  rm $DIRENV

  TERRAFORM=terraform_0.11.13_linux_amd64.zip
	wget -q https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
	unzip $TERRAFORM
	rm $TERRAFORM
	mv terraform ${BINDIR}/
	chmod +x ${BINDIR}/terraform

	OMLINUX=om-linux-4.3.0
	#wget -q https://github.com/pivotal-cf/om/releases/download/0.54.0/om-linux
	wget -q https://github.com/pivotal-cf/om/releases/download/4.3.0/om-linux-4.3.0
	mv $OMLINUX ${BINDIR}/
	chmod +x ${BINDIR}/$OMLINUX
	ln -s ${BINDIR}/$OMLINUX ${BINDIR}/om

	wget -q https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	mv jq-linux64 ${BINDIR}/
	chmod +x ${BINDIR}/jq-linux64
	ln -s ${BINDIR}/jq-linux64 ${BINDIR}/jq

	BOSHCLI=bosh-cli-6.1.1-linux-amd64
	#wget -q https://github.com/cloudfoundry/bosh-cli/releases/download/v5.4.0/bosh-cli-5.4.0-linux-amd64
	wget -q https://github.com/cloudfoundry/bosh-cli/releases/download/v6.1.1/bosh-cli-6.1.1-linux-amd64
	mv $BOSHCLI ${BINDIR}/
	chmod +x ${BINDIR}/$BOSHCLI
	ln -s ${BINDIR}/$BOSHCLI ${BINDIR}/bosh

	CREDHUB=credhub-linux-2.6.1.tgz
	#wget -q https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.2.1/credhub-linux-2.2.1.tgz
	wget -q https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.6.1/credhub-linux-2.6.1.tgz
	tar zxvf $CREDHUB
  rm $CREDHUB
	mv credhub ${BINDIR}/
	chmod +x ${BINDIR}/credhub

	gem install cf-uaac

	wget -q https://github.com/direnv/direnv/releases/download/v2.19.2/direnv.linux-amd64
	mv direnv.linux-amd64 ${BINDIR}/
	chmod +x ${BINDIR}/direnv.linux-amd64
	ln -s ${BINDIR}/direnvlinux-amd64 ${BINDIR}/direnv

	wget -q https://github.com/concourse/concourse/releases/download/v4.2.3/fly_linux_amd64
	mv fly_linux_amd64 ${BINDIR}/fly
	chmod +x ${BINDIR}/fly

	curl -L https://aka.ms/InstallAzureCli | bash
	
	PIVNET=pivnet-linux-amd64-0.0.74
	wget -q https://github.com/pivotal-cf/pivnet-cli/releases/download/v0.0.74/pivnet-linux-amd64-0.0.74
	mv $PIVNET ${BINDIR}/
	chmod +x ${BINDIR}/$PIVNET
	ln -s ${BINDIR}/$PIVNET ${BINDIR}/pivnet
}

$INSTALL_BINARIES && (echo "Installing binaries:"; install-binaries)
$SETUP_GIT && (echo "Setting up git"; setup-git)
$SETUP_BASH && (echo "Setting up bash-it"; setup-bash-it)
