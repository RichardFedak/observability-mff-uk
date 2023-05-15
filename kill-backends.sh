
LOG_DIR="_logs"
LOG_FILE="${LOG_DIR}/observability.log"
POSITION_FILE="${LOG_DIR}/positions.yaml"

kill_app () {
  APP_PID=$(pgrep "${APP}" || echo "" )
  if [ -z "${APP_PID}" ]
  then
    echo "${APP} is not running."
  else
    echo "Killing ${APP} running with PID ${APP_PID}."
    kill -9 "${APP_PID}"
  fi
}

kill_downstream () {
  DOWNSTREAM=$(pgrep -a observability | grep downstream || echo "")
  if [ -z "${DOWNSTREAM}" ]
  then
    echo "Downstream services are not running."
  else
    echo "Killing downstream services."
    pkill -f 'observability.*downstream'
  fi
}

APP="/mnt/c/Users/richa/Desktop/installers/loki/loki-linux-amd64"
kill_app
APP="/mnt/c/Users/richa/Desktop/installers/loki/promtail-linux-amd64"
kill_app
APP="/mnt/c/Users/richa/Desktop/installers/prometheus-2.44.0.linux-amd64/prometheus"
kill_app
APP="/mnt/c/Users/richa/Desktop/installers/jaeger-1.45.0-linux-amd64/jaeger-all-in-one"
kill_app
APP="/usr/sbin/grafana"
kill_app

kill_downstream

if [ -f "${LOG_FILE}" ]
then
  echo "Deleting old log files..."
  find "${LOG_DIR}" -name '*.log' -delete
fi

if [ -f "${POSITION_FILE}" ]
then
  echo "Deleting old position file..."
  rm "${POSITION_FILE}"
fi
