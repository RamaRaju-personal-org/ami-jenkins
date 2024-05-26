#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz -O go.tar.gz
sudo tar -xzvf go.tar.gz -C /usr/local
echo export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH >> ~/.profile
source ~/.profile
go version
