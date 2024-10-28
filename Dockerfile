FROM steamcmd/steamcmd:latest

RUN mkdir -p /pzserver
WORKDIR /pzserver

# Install Project Zomboid dedicated server
RUN steamcmd +login anonymous +force_install_dir /pzserver +app_update 380870 validate +quit

EXPOSE 16261-16262/udp