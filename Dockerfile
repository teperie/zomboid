FROM steamcmd/steamcmd:ubuntu-22

# Apply the latest security updates and remove package metadata from the image.
RUN apt-get update \
	&& apt-get dist-upgrade -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /pzserver
WORKDIR /pzserver

# Install Project Zomboid dedicated server
RUN steamcmd +force_install_dir /pzserver +login anonymous +app_update 380870 validate +quit

COPY ./start-server-with-param.sh /pzserver/start-server-with-param.sh

RUN chmod +x /pzserver/start-server-with-param.sh

EXPOSE 16261/udp 16262/udp

ENTRYPOINT ["bash", "/pzserver/start-server-with-param.sh"]