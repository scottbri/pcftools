#!/bin/bash

BINDIR="${HOME}/bin"
TEMPDIR="${HOME}/temp-pcftools-installer"
GITUSER="Scott Brightwell"
GITEMAIL="scott@brightwell.org"

INSTALL_BINARIES=true
SETUP_GIT=true


function setup-git {
	git config --global user.name "${GITUSER}"
	git config --global user.email "${GITEMAIL}"
}

function setup-bash-it {
	git clone http://github.com/scottbri/bash-it
	mv bash-it ${HOME}/.bash-it
	${HOME}/.bash-it/install.sh --silent
	sed -i.bak 's/BASH_IT_THEME=.*/BASH_IT_THEME=scott/' ${HOME}/.bashrc
}

function install-binaries {
	mkdir ${BINDIR} || exit 1
  mkdir ${TEMPDIR} && cd ${TEMPDIR}

	wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
	sudo apt-get install unzip
	unzip terraform_0.11.13_linux_amd64.zip
	mv terraform ${BINDIR}/
	chmod +x ${BINDIR}/terraform

	BINARY=om-linux-5.0.0
	wget https://github.com/pivotal-cf/om/releases/download/5.0.0/${BINARY}
	mv $BINARY ${BINDIR}/
	chmod +x ${BINDIR}/${BINARY}
	ln -s ${BINDIR}/${BINARY} ${BINDIR}/om

	wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	mv jq-linux64 ${BINDIR}/
	chmod +x ${BINDIR}/jq-linux64
	ln -s ${BINDIR}/jq-linux64 ${BINDIR}/jq

	BINARY=bosh-cli-6.2.1-linux-amd64
	#wget https://github.com/cloudfoundry/bosh-cli/releases/download/v5.4.0/bosh-cli-5.4.0-linux-amd64
	#wget https://github.com/cloudfoundry/bosh-cli/releases/download/v6.1.1/bosh-cli-6.1.1-linux-amd64
	wget https://github.com/cloudfoundry/bosh-cli/releases/download/v6.2.1/${BINARY}
	mv $BINARY ${BINDIR}/
	chmod +x ${BINDIR}/${BINARY}
	ln -s ${BINDIR}/${BINARY} ${BINDIR}/bosh

	wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
	#echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apundry-cli.list.d/cloudfoundry-cli.list
	sudo apt-get update
	sudo apt-get install cf-cli

	BINARY=credhub-linux-2.6.1.tgz
	#wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.2.1/credhub-linux-2.2.1.tgz
	wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.6.1/credhub-linux-2.6.1.tgz
	tar zxvf $BINARY
	mv credhub ${BINDIR}/
	chmod +x ${BINDIR}/credhub

	sudo apt-get install build-essential ruby-dev ruby
	sudo gem install cf-uaac

	wget https://github.com/direnv/direnv/releases/download/v2.19.2/direnv.linux-amd64
	mv direnv.linux-amd64 ${BINDIR}/
	chmod +x ${BINDIR}/direnv.linux-amd64
	ln -s ${BINDIR}/direnvlinux-amd64 ${BINDIR}/direnv

	#wget https://github.com/concourse/concourse/releases/download/v4.2.3/fly_linux_amd64
	wget https://github.com/concourse/concourse/releases/download/v6.1.0/fly-6.1.0-linux-amd64.tgz
	mv fly_linux_amd64 ${BINDIR}/fly
	chmod +x ${BINDIR}/fly

	curl -L https://aka.ms/InstallAzureCli | bash
	
	BINARY=pivnet-linux-amd64-1.0.3
	#wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v0.0.74/pivnet-linux-amd64-0.0.74
	wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v1.0.3/pivnet-linux-amd64-1.0.3
	mv $BINARY ${BINDIR}/
	chmod +x ${BINDIR}/${BINARY}
	rm ${BINDIR}/${BINARY} ln -s ${BINDIR}/${BINARY} ${BINDIR}/pivnet

	BINARY=duffle-linux-amd64
	wget https://github.com/cnabio/duffle/releases/download/0.3.5-beta.1/duffle-linux-amd64
	mv $BINARY ${BINDIR}/
	chmod +x ${BINDIR}/${BINARY}
	rm ${BINDIR}/${BINARY} ln -s ${BINDIR}/${BINARY} ${BINDIR}/duffle

  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`${BINDIR}kubectl

}

$INSTALL_BINARIES && (echo "Installing binaries:"; install-binaries)
$SETUP_GIT && (echo "Setting up git"; setup-git)
$SETUP_BASH && (echo "Setting up bash-it"; setup-bash-it)
