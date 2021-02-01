#!/bin/bash

CURRENT_DIRECTORY="${PWD}"
ENVOY_BINARY="${CURRENT_DIRECTORY}/envoy/bazel-bin/source/exe/envoy-static"

for ENVOY_CONF in *.yaml
do
    echo "[$(date +'%Y-%m-%d %H:%M')] Start running Envoy+Postgres over configuration file ${ENVOY_CONF}"
    "${ENVOY_BINARY}" -c "${ENVOY_CONF}" &

    if [ $? -ne 0 ]
    then
        exit $?
    fi

    while ! pidof envoy-static ;
    do
        echo "Waiting envoy to start ..."
        sleep 1
    done
    ENVOY_PID=$(pidof envoy-static)
    sleep 5

    cd "${CURRENT_DIRECTORY}"/postgres || exit 1
    (PGPORT=54322 PGHOST=localhost PGSSLMODE=require make installcheck) || exit 1
    (PGPORT=54322 PGHOST=localhost PGSSLMODE=require mmake -C contrib installcheck) || exit 1
    cd "${CURRENT_DIRECTORY}" || exit 1

    kill "${ENVOY_PID}" || exit 1
    sleep 2
    echo "[$(date +'%Y-%m-%d %H:%M')] Finish running Envoy+Postgres over configuration file ${ENVOY_CONF}"
done
exit 0
