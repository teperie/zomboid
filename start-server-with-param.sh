#!/bin/bash

steamcmd \
    +force_install_dir /pzserver \
    +login anonymous \
    +app_update 380870 \
    +quit

exec /pzserver/start-server.sh \
    -servername "${SERVER_NAME}" \
    -adminusername "${ADMIN_USERNAME}" \
    -adminpassword "${ADMIN_PASSWORD}" \
    ${OPTS}