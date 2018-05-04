#!/bin/sh
CJE_OC="/var/jenkins_home/plugins"
CJE_MM="/var/jenkins_home/plugins"
OC_POD="cjoc-0"
MM_POD="cje-mm-0"

kubectl exec ${OC_POD} -- rm ${CJE_OC}/cjm*.{jpi,jar,hpi,bak,disabled}
kubectl exec ${MM_POD} -- rm ${CJE_MM}/cjm*.{jpi,jar,hpi,bak,disabled}
