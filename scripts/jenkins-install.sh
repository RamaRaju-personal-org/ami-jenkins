#!/bin/bash
sudo apt install openjdk-11-jdk -y 

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add - 
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5BA31D57EF5975CA

sudo apt update && sudo apt install jenkins -y

sudo systemctl start jenkins

sleep 5 

sudo systemctl enable jenkins
