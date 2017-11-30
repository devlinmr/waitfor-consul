#!/bin/bash

# comma-delimited list of host:port,host:port
if [ "x${CONSUL_HTTP_ADDR}x" == "xx" ]; then
    echo "Set CONSUL_HTTP_ADDR"
    exit 0
fi

rc=`curl -k -s -o /dev/null -w "%{http_code}" ${CONSUL_HTTP_ADDR}/v1/agent/self?token=${CONSUL_HTTP_TOKEN}`

if [ $rc == "200" ]; then
    echo "Consul alive at ${CONSUL_HTTP_ADDR}"
elif [ $rc == "403" ]; then
    echo "Check CONSUL_HTTP_TOKEN: received 403 from ${CONSUL_HTTP_ADDR}/v1/agent/self"
    exit 1
else
    echo "Unexpected response code ${rc} from ${CONSUL_HTTP_ADDR}/v1/agent/self"
fi

if [ "x${CONSUL_KEY}x" == "xx" ]; then
    echo "No CONSUL_KEY specified, Exiting."
    exit 0
fi

echo "Checking $CONSUL_HTTP_ADDR/v1/kv/${CONSUL_KEY}..."

while [ `curl -k -s -o /dev/null -w "%{http_code}" $CONSUL_HTTP_ADDR/v1/kv/${CONSUL_KEY}?token=${CONSUL_HTTP_TOKEN}` != "200" ]; do
    rc=`curl -k -s -o /dev/null -w "%{http_code}" $CONSUL_HTTP_ADDR/v1/kv/${CONSUL_KEY}?token=${CONSUL_HTTP_TOKEN}`
    echo "Waiting on $CONSUL_HTTP_ADDR/v1/kv/${CONSUL_KEY}... $rc"
    sleep 5
done

if [ "${EXPORT_KEY}" != "true" ]; then
    echo "${CONSUL_KEY} found. Exiting."
    exit 0
fi

CONSUL_VAL=`curl -k -s $CONSUL_HTTP_ADDR/v1/kv/${CONSUL_KEY}?token=${CONSUL_HTTP_TOKEN} | jq -r .[].Value | base64 -d`

echo "Exporting /pod-data/consul/${CONSUL_KEY}."

mkdir -p `dirname /pod-data/consul/${CONSUL_KEY}`

echo ${CONSUL_VAL} > /pod-data/consul/${CONSUL_KEY}

echo "End"
exit 0
