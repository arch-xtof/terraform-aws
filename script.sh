#!/bin/bash
echo ${tstamp} >> /home/ubuntu/creation_date.txt
sudo hostname ${hostname}-${n}
sudo apt update -y
sudo apt install net-tools -y