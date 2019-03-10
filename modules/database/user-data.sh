#!/bin/bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo apt-get -y install redis
sudo sed -i -e 's/^\(bind 127.0.0.1 ::1\)/#\1/' /etc/redis/redis.conf
sudo sed -i -e 's/# \(requirepass\) foobared/\1 ${database_pass}/' /etc/redis/redis.conf
sudo systemctl restart redis
