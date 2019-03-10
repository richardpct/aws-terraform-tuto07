#!/bin/bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo apt-get -y install golang
sudo go get github.com/richardpct/go-example-tuto04
sudo /root/go/bin/go-example-tuto04 -redishost ${database_host} -redispass ${database_pass} -env ${environment}
