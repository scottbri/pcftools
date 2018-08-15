CERTDNS=$1
OUTDIR="./ssl-out"
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CERTSTRING="/C=US/ST=Anystate/L=Anycity/O=HarnessingUnicorns/CN=HarnessingUnicorns ROOT CA"

if [ ! -f "$SCRIPTDIR/ca.cnf.base" ]; then
    echo "ca.cnf.base is required and does not exist in the current directory"
    echo "Aborting"
    exit 1
fi

if [ $# -lt 1 ] ; then
	echo "Usage: $0 FQDN"
	echo ""
	echo "where:"
	echo "     FQDN:   the domain at the top level of PAS / PKS cluster"
	echo ""
	echo "Wildcard certs will be included suitable for PAS / PKS"
	exit 1
fi

PROJECT="$1"
USERNAME="$2"
FILENAME="${USERNAME}-terraform-json.key"

rm -rf $OUTDIR
mkdir $OUTDIR
touch $OUTDIR/index.txt
echo "unique_subject = no" > $OUTDIR/index.txt.attr
echo 1000 > $OUTDIR/serial

cp $SCRIPTDIR/ca.cnf.base $OUTDIR/ca.cnf
SUBJECTALTNAME="subjectAltName = DNS:${CERTDNS},DNS:*.sys.${CERTDNS},DNS:*.login.sys.${CERTDNS},DNS:*.uaa.sys.${CERTDNS},DNS:*.apps.${CERTDNS}"
echo $SUBJECTALTNAME >> $OUTDIR/ca.cnf

echo 'Done setting things up'

echo "Create Root Private Key and Root Cert"
openssl req -config $OUTDIR/ca.cnf \
	-newkey rsa:2048 -nodes -keyout $OUTDIR/root.key.pem \
	-new -x509 -days 7300 -out $OUTDIR/root.crt \
	-subj "$CERTSTRING"

#Create CSR
echo "Create Cert Key"
openssl req -new -out "$OUTDIR/$CERTDNS.key.pem" \
	-key $OUTDIR/root.key.pem \
	-reqexts SAN \
	-config $OUTDIR/ca.cnf \
	-subj "/C=US/ST=Anystate/L=Anycity/O=HarnessingUnicorns/OU=${CERTDNS}/CN=${CERTDNS}"

# Issue certificate
echo "Issue Certificate"
openssl ca -config $OUTDIR/ca.cnf -batch -notext \
	-in "$OUTDIR/$CERTDNS.key.pem" \
	-out "$OUTDIR/$CERTDNS.crt" \
	-cert $OUTDIR/root.crt \
	-keyfile $OUTDIR/root.key.pem

### Chain certificate with CA
##echo "Chain certificate with CA"
##cat "${OUTDIR}/$CERTDNS.crt" $OUTDIR/root.crt > "${OUTDIR}/$CERTDNS.bundle.crt"
