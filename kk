ARGUMENTS="$@"

echo "${ARGUMENTS}"  | grep "\-n" 2>&1 > /dev/null;  USERSPECIFIEDNAMESPACE=$?
if [ ${USERSPECIFIEDNAMESPACE} == 0 ] ; then
  kubectl ${ARGUMENTS}
elif [ "x${NAMESPACE}x" != "xx" ] ; then
  echo "### NAMESPACE SET:  kubectl -n ${NAMESPACE} ${ARGUMENTS}"
  kubectl -n ${NAMESPACE} ${ARGUMENTS}
else
  kubectl ${ARGUMENTS}
fi

## Old version using subdirectory names
## works pretty well
#CURRENTDIR=${PWD##*/}
#NAMESPACES="$(kubectl get namespaces | awk '{print $1}')"
#echo "$NAMESPACES" | grep "$CURRENTDIR" 2>&1 > /dev/null;  DIRISNAMESPACE=$?
#echo "$ARGUMENTS"  | grep "\-n" 2>&1 > /dev/null;  USERSPECIFIEDNAMESPACE=$?
#
#if [ $USERSPECIFIEDNAMESPACE == 0 ] ; then
#  kubectl $ARGUMENTS
#elif [ $DIRISNAMESPACE == 0 ] ; then
#  echo "### NAMESPACE SET:  kubectl -n $CURRENTDIR $ARGUMENTS"
#  kubectl -n $CURRENTDIR $ARGUMENTS
#else
#  kubectl $ARGUMENTS
#fi
