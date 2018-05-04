#!/bin/sh
ES_URL="http://elasticsearch:9200"
KB_URL="http://kibana:5601"
NAMESPACE=" --namespace=cje "

setDefaultIndex(){
  local index_pattern=${1:-?}
  local time_field=${2:-?}
  # Create index pattern and get the created id
  # curl -f to fail on error
  local id=$(kubectl exec -it cjoc-0 -- curl -Ssf -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
    "${KB_URL}/api/saved_objects/index-pattern" \
    -d"{\"attributes\":{\"title\":\"$index_pattern\",\"timeFieldName\":\"$time_field\"}}" | jq -r .id)
  # Create the default index
  kubectl ${NAMESPACE} exec -it cjoc-0 -- curl -XPOST -Ss -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
    "${KB_URL}/api/kibana/settings/defaultIndex" \
    -d"{\"value\":\"$id\"}"
  
#  kubectl exec -it cjoc-0 -- curl -XPUT ${ES_URL}/.kibana/config/4.1.1 -d "{\"defaultIndex\" : \"${index}\"}"
}

createIndexPattern(){
  local index=${1:-?}
  local timeFieldName=${2:-?}
  kubectl ${NAMESPACE} exec -it cjoc-0 -- curl -Ss -XPUT ${ES_URL}/.kibana/index-pattern/${index} -d "{\"title\" : \"${index}\",  \"timeFieldName\": \"${timeFieldName}\"}"  
}

createIndexPattern "items" ""
createIndexPattern "builds-*" "@timestamp"
createIndexPattern "nodes-*" "@timestamp"
createIndexPattern "metrics-*" "@timestamp"

