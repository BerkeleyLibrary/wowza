#!/usr/bin/env bash

# ############################################################
# Starts the Wowza Streaming Media Engine and the Wowza
# Streaming Media Engine Manager in subprocesses, and waits
# for them to exit.

# TODO: now that we're running the manager and server in the same container,
#       consider getting rid of this (or simplifying it) in favor of the
#       upstream container's /sbin/entrypoint.sh, which uses supervisord

BASENAME=$(basename ${BASH_SOURCE})
echo "${BASENAME} running"

# ########################################
# Global configuration

WOWZA_BIN="$(dirname "${BASH_SOURCE[0]}")"
WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSMGR_HOME="${WMSAPP_HOME}/manager"

# ########################################
# Documentation server (disabled by default)

if [ ! -z "${WOWZA_ENABLE_DOCUMENTATION_SERVER}" ]; then
  "${WOWZA_BIN}"/enable-documentation-server.sh
fi

# ########################################
# Start server and manager in background

# shellcheck source=start-server.sh
"${WOWZA_BIN}"/start-server.sh &
SERVER_PID=$!

"${WMSMGR_HOME}"/bin/startmgr.sh &
MANAGER_PID=$!

# ########################################
# Make sure child processes exit cleanly

ensure_clean_exit() {
  trap - SIGINT SIGTERM # clear the trap
  echo "Killing process $$ and all subprocesses"
  kill -- -$$
}

sigint_received() {
  echo "SIGINT received"
  ensure_clean_exit
}

sigterm_received() {
  echo "SIGTERM received"
  ensure_clean_exit
}

trap sigint_received SIGINT
trap sigterm_received SIGTERM

# ########################################
# Wait for manager or server to exit

wait -n
EXIT_STATUS=$?

# Whichever exited, kill the other one
if ! kill -0 $SERVER_PID 2> /dev/null; then
  echo "Wowza Streaming Engine (PID ${SERVER_PID}) exited with ${EXIT_STATUS}"
  echo "Stopping Wowza Streaming Engine Manager (PID ${MANAGER_PID})"
  kill -- -$MANAGER_PID 2> /dev/null
elif ! kill -0 $MANAGER_PID 2> /dev/null; then
  echo "Wowza Streaming Engine Manager (PID ${MANAGER_PID}) exited with ${EXIT_STATUS}"
  echo "Stopping Wowza Streaming Engine (PID ${SERVER_PID})"
  kill -- -$SERVER_PID 2> /dev/null
fi

echo "Exiting with status ${EXIT_STATUS}"
exit $EXIT_STATUS
