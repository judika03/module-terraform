ELASTICSEARCH_VERSION=6.8.4
sudo apt-get update
sudo apt install openjdk-8-jdk -y
wget --quiet https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.deb
sudo dpkg -i elasticsearch-$ELASTICSEARCH_VERSION.deb
rm elasticsearch-$ELASTICSEARCH_VERSION.deb
# Configure Elasticsearch for development purposes (1 shard/no replicas, don't allow it to swap at all if it can run without swapping)
sudo sed -i "s/#index.number_of_shards: 1/index.number_of_shards: 1/" /etc/elasticsearch/elasticsearch.yml
echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/" >> /etc/default/elasticsearch
sudo sed -i "s/#index.number_of_replicas: 0/index.number_of_replicas: 0/" /etc/elasticsearch/elasticsearch.yml
#Plugin GCE
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-gce -b

# Configure elasticsearch
cat <<'EOF' >>/etc/elasticsearch/elasticsearch.yml
cluster.name: ${cluster_name}

cloud:
  gce:
    project_id: ${project_id}
    zone: [${zones}]
discovery:
  zen.hosts_provider: gce

network.host: "0.0.0.0"
discovery.zen.minimum_master_nodes: ${minimum_master_nodes}

# only data nodes should have ingest and http capabilities
node.master: ${master}
node.data: ${data}
EOF
# Setup heap size
sudo sed -i "s/^-Xms.*/-Xms${heap_size}/" /etc/elasticsearch/jvm.options
sudo sed -i "s/^-Xmx.*/-Xmx${heap_size}/" /etc/elasticsearch/jvm.options
sleep 30
# Configure to start up Elasticsearch automatically
sudo update-rc.d elasticsearch defaults 95 10
sudo -i service elasticsearch restart
until $(curl --output /dev/null --silent --head --fail http://localhost:9200); do
  printf ">>> Waiting for elasticsearch to start on localhost:9200\n"
  sleep 5
done
