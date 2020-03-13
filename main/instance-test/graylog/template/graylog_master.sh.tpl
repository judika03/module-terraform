
#!/bin/bash

sudo rm /etc/graylog/server/node-id
sudo touch /etc/graylog/server/node-id
PASSWORD=$(pwgen -s -1 8)
sudo echo $PASSWORD >> /etc/graylog/server/node-id
sudo sed -i 's/is_master.*/is_master=true/g' /etc/graylog/server/server.conf
mongo --host ${ipaddress} --eval "rs.initiate()"