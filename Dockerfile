FROM ubuntu:20.04

ARG USERNAME=meeton 
ENV USERNAME=$USERNAME 
ARG PASSWORD=meeton
ENV PASSWORD=$PASSWORD 
ARG TURN_PORT=3478
ENV TURN_PORT=$TURN_PORT 
ARG TURN_PORT_START=10000
ENV TURN_PORT_START=$TURN_PORT_START 
ARG TURN_PORT_END=20000
ENV TURN_PORT_END=$TURN_PORT_END 
ARG TURN_SERVER_NAME=coturn
ENV TURN_SERVER_NAME=$TURN_SERVER_NAME 
ARG TURN_REALM=meeton.com
ENV TURN_REALM=$TURN_REALM 
ARG EXTERNAL_IP=127.0.0.1
ENV EXTERNAL_IP=$EXTERNAL_IP 

RUN apt update && apt upgrade -y && apt install -y coturn sqlite3 libsqlite3-dev sudo vim dos2unix && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -ms /bin/bash $USERNAME 
RUN echo $USERNAME:$PASSWORD | chpasswd
RUN usermod -aG sudo $USERNAME

RUN echo TURNSERVER_ENABLED=1 >> /etc/default/coturn
RUN mv /etc/turnserver.conf /etc/turnserver.conf.backup

RUN echo realm=$TURN_REALM >> /etc/turnserver.conf
RUN echo server-name=$TURN_SERVER_NAME >> /etc/turnserver.conf
RUN echo fingerprint >> /etc/turnserver.conf
RUN echo listening-ip=0.0.0.0 >> /etc/turnserver.conf
RUN echo external-ip=$EXTERNAL_IP >> /etc/turnserver.conf
RUN echo listening-port=$TURN_PORT >> /etc/turnserver.conf
RUN echo min-port=$TURN_PORT_START >> /etc/turnserver.conf
RUN echo max-port=$TURN_PORT_END >> /etc/turnserver.conf
RUN echo log-file=/var/log/turnserver.log >> /etc/turnserver.conf
RUN echo verbose >> /etc/turnserver.conf
RUN echo user=$USERNAME:$PASSWORD >> /etc/turnserver.conf
RUN echo lt-cred-mech >> /etc/turnserver.conf
RUN echo userdb=/var/lib/turn/turndb >> /etc/turnserver.conf

RUN mkdir -p /var/lib/turn && chgrp -R $USERNAME /var/lib && chmod -R g+rw /var/lib && chgrp -R $USERNAME /run && chmod -R g+rw /run

COPY start_coturn.sh /home/$USERNAME/
RUN chown $USERNAME /home/$USERNAME/start_coturn.sh
RUN dos2unix /home/$USERNAME/start_coturn.sh && chmod +x /home/$USERNAME/start_coturn.sh

EXPOSE 3478 3478/udp

USER $USERNAME
WORKDIR /home/$USERNAME



