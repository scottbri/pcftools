#!/bin/bash

BINDIR="~/bin"
GITUSER="Scott Brightwell"
GITEMAIL="scott@brightwell.org"

INSTALL_BINARIES=true
SETUP_GIT=true

$INSTALL_BINARIES && (echo "Installing binaries:"; install-binaries)
$SETUP_GIT && (echo "Setting up git"; setup-git)

function setup-git {
	git config --global user.name "${GITUSER}"
	git config --global user.email "${GITEMAIL}"
}

function install-binaries {
	mkdir ${BINDIR}
	wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
	sudo apt-get install unzip
	unzip terraform_0.11.13_linux_amd64.zip
	mv terraform ${BINDIR}/
	chmod +x ${BINDIR}/terraform

	wget https://github.com/pivotal-cf/om/releases/download/0.54.0/om-linux
	mv om-linux ${BINDIR}/
	chmod +x ${BINDIR}/om-linux
	ln -s ${BINDIR}/om-linux ${BINDIR}/om

	wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	mv jq-linux64 ${BINDIR}/
	chmod +x ${BINDIR}/jq-linux64
	ln -s ${BINDIR}/jq-linux64 ${BINDIR}/jq

	wget https://github.com/cloudfoundry/bosh-cli/releases/download/v5.4.0/bosh-cli-5.4.0-linux-amd64
	mv bosh-cli-5.4.0-linux-amd64 ${BINDIR}/
	chmod +x ${BINDIR}/bosh-cli-5.4.0-linux-amd64
	ln -s ${BINDIR}/bosh-cli-5.4.0-linux-amd64 ${BINDIR}/bosh

	wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
	#echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apundry-cli.list.d/cloudfoundry-cli.list
	sudo apt-get update
	sudo apt-get install cf-cli

	wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.2.1/credhub-linux-2.2.1.tgz
	tar zxvf credhub-linux-2.2.1.tgz
	mv credhub ${BINDIR}/
	chmod +x ${BINDIR}/credhub

	sudo apt-get install build-essential ruby-dev ruby
	sudo gem install cf-uaac

	wget https://github.com/direnv/direnv/releases/download/v2.19.2/direnv.linux-amd64
	mv direnv.linux-amd64 ${BINDIR}/
	chmod +x ${BINDIR}/direnv.linux-amd64
	ln -s ${BINDIR}/direnvlinux-amd64 ${BINDIR}/direnv

	wget https://github.com/concourse/concourse/releases/download/v4.2.3/fly_linux_amd64
	mv fly_linux_amd64 ${BINDIR}/fly
	chmod +x ${BINDIR}/fly

	curl -L https://aka.ms/InstallAzureCli | bash
}

