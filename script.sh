#!/bin/bash
echo ${tstamp} >> /home/ubuntu/creation_date.txt
sudo apt update -y
sudo apt install nginx -y
sudo service nginx start
