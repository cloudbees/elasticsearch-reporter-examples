#!/bin/sh
ES_URL="http://elasticsearch:9200"
for i in $(kubectl exec cjoc-0 -- curl -Ss -XGET "${ES_URL}/_all?pretty"|jq -r keys[])
do
  kubectl exec cjoc-0 -- curl -Ss -XDELETE "${ES_URL}/${i}?pretty"
done

for i in $(kubectl exec cjoc-0 -- curl -Ss -XGET "${ES_URL}/_template?pretty"|jq -r keys[])
do
  kubectl exec cjoc-0 -- curl -Ss -XDELETE "${ES_URL}/_template/${i}?pretty"
done