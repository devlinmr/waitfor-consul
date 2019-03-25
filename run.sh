#!/bin/bash

if [ "x${CONSUL_HTTP_ADDR}x" == "xx" ]; then
    echo "Set CONSUL_HTTP_ADDR"
    exit 0
fi

rc=`curl -k -s -o /dev/null -w "%{http_code}" ${CONSUL_HTTP_ADDR}/v1/agent/self?token=${CONSUL_HTTP_TOKEN}`
resp="false"

while [ $resp == "false" ]; do
    if [ $rc == "200" ]; then
        echo "Consul alive at ${CONSUL_HTTP_ADDR}"
        resp="true"
    elif [ $rc == "403" ]; then
        echo "Check CONSUL_HTTP_TOKEN: received 403 from ${CONSUL_HTTP_ADDR}/v1/agent/self"
        resp="true"
        exit 1
    else
        echo "Unexpected response code ${rc} from ${CONSUL_HTTP_ADDR}/v1/agent/self"
        sleep 10
        rc=`curl -k -s -o /dev/null -w "%{http_code}" ${CONSUL_HTTP_ADDR}/v1/agent/self?token=${CONSUL_HTTP_TOKEN}`
    fi
done

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

mkdir -p /pod-data/consul  /pod-data/exports

if [ "x${EXPORT_AS}x" == "xx" ]; then
  echo "Exporting /pod-data/consul/${CONSUL_KEY}."
  echo ${CONSUL_VAL} > /pod-data/consul/${CONSUL_KEY}
else
  echo "Exporting ${CONSUL_KEY} as var."
  echo "export ${EXPORT_AS}=${CONSUL_VAL}" >> /pod-data/exports/consul.sh
  chmod 750 /pod-data/exports/consul.sh
fi

echo "End"
exit 0
