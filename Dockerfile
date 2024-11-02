FROM steamcmd/steamcmd:latest

RUN mkdir -p /pzserver
WORKDIR /pzserver

# Install Project Zomboid dedicated server
RUN steamcmd +login anonymous +force_install_dir /pzserver +app_update 380870 validate +quit

COPY ./start-server-with-param.sh /pzserver/start-server-with-param.sh

RUN chmod +x /pzserver/start-server-with-param.sh

EXPOSE 16261/udp 16262/udp

ENTRYPOINT ["/pzserver/start-server-with-param.sh"]