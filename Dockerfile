FROM ubuntu:14.04
RUN apt-get update && apt-get -y upgrade && apt-get -y install curl
WORKDIR /opt
RUN curl -k -L -O https://www.factorio.com/get-download/0.12.28/headless/linux64
RUN tar xvfz linux64
ADD docker-entrypoint.sh /opt/factorio/
RUN chmod +x /opt/factorio/docker-entrypoint.sh
WORKDIR /opt/factorio
ENTRYPOINT ["/opt/factorio/docker-entrypoint.sh"]
VOLUME /opt/factorio/saves
