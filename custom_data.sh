#!/bin/bash
apt-get update
apt-get -y dist-upgrade
curl -fsSL https://get.docker.com/ | bash
usermod -aG docker ubuntu
docker run --rm -d -p 80:80 nginx:alpine
