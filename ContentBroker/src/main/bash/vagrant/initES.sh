cd /ci/DNSCore/ContentBroker/src/main/


#export indexName="portal_ci_test"
if (( "$#" != 1 )) 
then
    echo "Provide the target Index-Name as argument"
exit 1
fi

export indexName="$1"
export indexHost="http://localhost:9200"
#export indexName="portal_ci_test"

echo "Delete: "
curl -XDELETE "$indexHost/$indexName"
sleep 1
echo
echo "Create: "
curl -XPUT "$indexHost/$indexName"
sleep 1
echo
echo "close: "
curl -XPOST "$indexHost/$indexName/_close"
sleep 1
echo
echo "settings: "
curl -XPUT "$indexHost/$indexName/_settings" -d "@conf/es_settings.json"
sleep 1
echo
echo "mapping: "
timeout 7 curl -XPUT "$indexHost/$indexName/ore:Aggregation/_mapping" -d "@conf/es_mapping.json"
sleep 1
echo
echo "reopen: "
curl -XPOST "$indexHost/$indexName/_open"