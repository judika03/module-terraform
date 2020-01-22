
#!/bin/bash

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update && sudo apt-get install kibana


# Configure elasticsearch
cat <<'EOF' >>/etc/kibana/kibana.yml
server.host: "0.0.0.0"
EOF

systemctl enable kibana
systemctl start  kibana




