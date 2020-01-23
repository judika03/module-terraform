#!/bin/bash

sudo apt update
sudo apt install -y default-jdk
wget http://www-us.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz
tar xzf kafka_2.12-2.2.1.tgz
sudo mv kafka_2.12-2.2.1 /usr/local/kafka

echo "
Description=Zookeeper
After=network.target
User=root
[Service]
ExecStart=/usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties
Restart=always
[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/zookeeper.service



echo "
Description=kafka
After=network.target
User=root
[Service]
ExecStart=/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/usr/local/kafka/bin/kafka-server-stop.sh 
Restart=always
[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/kafka.service


sudo systemctl start kafka.service

sudo systemctl start zookeeper.service