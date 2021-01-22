#!/bin/bash

PWD=$(pwd)
ENVOY_BINARY="${PWD}/envoy/bazel-bin/source/exe/envoy-static"

for ENVOY_CONF in *.yaml
do
    "${ENVOY_BINARY}" -c "${ENVOY_CONF}" &
    ENVOY_PID=$(pidof envoy)

    cd "${PWD}"/postgres || exit 1
    (PGPORT=54322 PGHOST=localhost make installcheck) || exit 1
    (PGPORT=54322 PGHOST=localhost make -C contrib installcheck) || exit 1
    cd "${PWD}" || exit 1

    kill "${ENVOY_PID}" || exit 1
    sleep 2
done
exit 0
