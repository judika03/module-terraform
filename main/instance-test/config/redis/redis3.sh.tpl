
set -e

echo 511 > /proc/sys/net/core/somaxconn
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1

export DEBIAN_FRONTEND=noninteractive

apt -y update && apt install -y make gcc libc6-dev tcl
cd /tmp
wget http://download.redis.io/redis-stable.tar.gz && tar xvzf redis-stable.tar.gz && cd redis-stable
make install

sudo mkdir /opt/redis
cd /opt/redis
# set up servers
rm -f appendonly.aof
rm -f dump.rdb
for i in $(seq 7001 1 7002)
do
    rm -rf $i
    mkdir $i
    touch $i/redis.conf
    echo "port $i
protected-mode no
cluster-enabled yes
cluster-config-file nodes-$i.conf
pidfile /var/run/redis-$i.pid
cluster-node-timeout 5000
cluster-require-full-coverage no
appendonly yes" >> $i/redis.conf

echo "
Description=Redis In-Memory Data Store
After=network.target
[Service]
ExecStart=/usr/local/bin/redis-server /opt/redis/$i/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always
[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/redis-$i.service

sudo systemctl start redis-$i.service
sudo systemctl enable redis-$i.service
sleep 40
done

idmaster="$(redis-cli -p 7001 cluster nodes | grep myself | cut -d" " -f1)"
echo $idmaster
redis-cli --cluster add-node ${redis1}:7002 ${redis3}:7001 --cluster-slave --cluster-master-id $idmaster


exit 0

