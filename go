BINDIR=/home/scott/bin
PIVNET=pivnet-linux-amd64-0.0.74
  wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v0.0.74/pivnet-linux-amd64-0.0.74
        mv $PIVNET ${BINDIR}/
        chmod +x ${BINDIR}/$PIVNET
        ln -s ${BINDIR}/$PIVNET ${BINDIR}/pivnet
