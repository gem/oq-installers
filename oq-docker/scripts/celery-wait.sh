#!/bin/bash
while :
do
    (echo > /dev/tcp/oq-cluster-rabbitmq/5672) >/dev/null 2>&1
    result=$?
    if [[ $result -eq 0 ]]; then
        break
    fi
    sleep 1
done

# Start celery
/opt/openquake/bin/celery worker --workdir /opt/openquake/lib/python3.5/site-packages/openquake/engine --purge -Ofair
