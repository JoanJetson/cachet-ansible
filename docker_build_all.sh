#!/bin/bash
# Author: Joan Bohlman
# Peace Amoung Worlds
# Note: because systemd is wonky, you may need to launch postgres, memcached, httpd, and cachet_monitor using systemctl

if [ "$1" == "clear" ] ; then

    read -p "Do you really want to remove all docker images and containers? [Y/n]: " CONFIRM
    
    if [ "$CONFIRM" == "Y" ] ; then
        docker stop $(docker ps -a -q) ; docker rm $(docker ps -a -q) ; docker rmi $(docker images -a -q)
    else
        echo "Doing nothing and exiting..."
        exit 0
    fi
else
    if [ ! -d docker/files/docker-systemctl-replacement ] ; then
        cd docker/files
        git clone https://github.com/gdraheim/docker-systemctl-replacement.git
        cd ../..
    fi

    echo "Building Cachet Docker Image"
    docker build --rm -f docker/cachet/Dockerfile -t local/cachet .
    echo "Running Cachet Docker Container"
    docker run --name cachet -e container=docker -d -p 8080:80 local/cachet /bin/bash -c "systemctl default" --link
    echo "Building Cachet-Monitor Docker Image"
    docker build --rm -f docker/cachet-monitor/Dockerfile -t local/cachet-monitor .
    echo "Running Cachet-Monitor Docker Image"
    docker run --name cachet-monitor -e container=docker -d -p 8081:80 local/cachet-monitor /bin/bash -c "systemctl default" --link
fi
