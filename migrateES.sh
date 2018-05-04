#!/bin/sh

ES_URL="http://192.168.1.100:9200"
ES_URL_NEW="http://192.168.1.101:9200"
#AUTH=', "username": "user", "password": "pass"'

for i in $(curl -s -XGET "${ES_URL_NEW}/_all" |jq keys[]|grep -v kibana-4-cloudbees)
do
  INDEX_NAME=$(echo ${i}|tr -d '"')
  echo "Create index ${INDEX_NAME}"
  curl -Ss -XPUT "${ES_URL_NEW}/${INDEX_NAME}?pretty" -d'{ "settings" : {  "index.mapping.total_fields.limit" : 5000 }}' > create-${INDEX_NAME}.json
  
  cat > data.json <<EOF
  {
    "source": {
      "remote": {
        "host": "${ES_URL}" 
        ${AUTH}
      },
      "index": "${INDEX_NAME}",
      "size": 100
    },
    "dest": {
      "index": "${INDEX_NAME}"
    }
  }
EOF

  echo "Migrate data from ${ES_URL} to ${ES_URL_NEW} on index ${INDEX_NAME}"
  curl -Ss "$ES_URL_NEW/_reindex?pretty&wait_for_completion=false" -H 'Content-Type: application/json' -d"@data.json" > reindex-${INDEX_NAME}.json

done

 curl -Ss "$ES_URL_NEW/_tasks?pretty"