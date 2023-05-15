#!/bin/sh -eu

LOKI_HOME="/mnt/c/Users/richa/Desktop/installers/loki"
PROMETHEUS_HOME="/mnt/c/Users/richa/Desktop/installers/prometheus-2.44.0.linux-amd64"
JAEGER_HOME="/mnt/c/Users/richa/Desktop/installers/jaeger-1.45.0-linux-amd64"
GRAFANA_HOME="/usr"
PWD=$(pwd)

./kill-backends.sh

echo "Starting Loki in the background..."
"${LOKI_HOME}/loki-linux-amd64" -config.file "${PWD}/_config/loki/loki-local-config.yaml" > /dev/null 2>&1 &

echo "Starting Promtail in the background..."
"${LOKI_HOME}/promtail-linux-amd64" -config.file "${PWD}/_config/loki/promtail-local-config.yaml" > /dev/null 2>&1 &

echo "Starting Prometheus in the background..."
"${PROMETHEUS_HOME}/prometheus" --config.file "${PWD}/_config/prometheus/prometheus.yml" --storage.tsdb.path="_tmp/prometheus/data/" > /dev/null 2>&1 &

echo "Starting Jaeger in the background..."
"${JAEGER_HOME}/jaeger-all-in-one" --collector.zipkin.host-port=:9411 > /dev/null 2>&1 &

echo "Starting Grafana in the background..."
"${GRAFANA_HOME}/sbin/grafana" -homepath "${GRAFANA_HOME}" > /dev/null 2>&1 &

echo "Starting downstream services in the background..."
./observability -p 5050 -n downstream-1 -d "http://localhost:6060" &
./observability -p 6060 -n downstream-2 &
