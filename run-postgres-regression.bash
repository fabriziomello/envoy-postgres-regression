#!/bin/bash

PWD=$(pwd)
ENVOY_BINARY="${PWD}/envoy/bazel-bin/source/exe/envoy-static"

for ENVOY_CONF in *.yaml
do
    echo "${ENVOY_BINARY} -c ${ENVOY_CONF} &"
    ENVOY_PID=$(pidof envoy)

    cd "${PWD}"/postgres || exit
    PGPORT=54322 PGHOST=localhost make installcheck
    PGPORT=54322 PGHOST=localhost make -C contrib installcheck
    cd "${PWD}" || exit

    kill "${ENVOY_PID}"
    sleep 2
done
