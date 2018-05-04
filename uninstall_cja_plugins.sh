#!/bin/sh
CJE_OC="/var/jenkins_home/plugins"
CJE_MM="/var/jenkins_home/plugins"
OC_POD="cjoc-0"
MM_POD="cje-mm-0"

kubectl exec ${OC_POD} -- rm ${CJE_OC}/operations-center-analytics*.{jpi,jar,hpi,bak}
kubectl exec ${MM_POD} -- rm ${CJE_MM}/operations-center-analytics*.{jpi,jar,hpi,bak}
