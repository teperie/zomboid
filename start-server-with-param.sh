#!/bin/bash
exec /pzserver/start-server.sh -servername "${SERVER_NAME}" -adminusername "${ADMIN_USERNAME}" -adminpassword "${ADMIN_PASSWORD}" "${OPTS}"
