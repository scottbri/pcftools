OM_TARGET=${OM_TARGET:="https://pcf.us.gcp.bekind.io"} 
OM_USER=${OM_USER:="admin"}
OM_PASSWORD=${OM_PASSWORD:="SETMEINYOURENVIRONMENTNOTHERE"}
ARGUMENTS="$@"

om --target=${OM_TARGET} -k --username=${OM_USER} --password=${OM_PASSWORD} ${ARGUMENTS}
