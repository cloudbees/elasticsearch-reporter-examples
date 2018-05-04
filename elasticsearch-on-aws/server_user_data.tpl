#!/bin/bash

echo "Virtual machine index is : {VM_INDEX}" >/tmp/boot-messages

# Add PPA(s) and update to prepare for installing stuff
# First the keys for Azul OpenJDK 8
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9
apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main'
# Then keys for Elastic.co products
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-key update
apt-get update

# Install some generally needed packages
apt-get install -y apt-transport-https ca-certificates

# Install Azul Zulu 8
apt-get install --allow-unauthenticated -y zulu-8

# Install Elasticsearch
apt-get install -y elasticsearch=5.6.6
yes | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2

# Now configure and start the Elasticsearch service
sysctl -w vm.max_map_count=262144
cat <<%%EOF%% >/etc/elasticsearch/elasticsearch.yml
cluster.name: "cloudbees-cluster"
network.host: 0.0.0.0

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 1
discovery.zen.ping.unicast.hosts: ${DISCOVERY}
%%EOF%%

# Restart ES with the new config
systemctl enable elasticsearch
systemctl restart elasticsearch

echo 'export PS1="\[\033[01;32m\]\h\[\033[01;34m\] \W\$(__git_ps1) \$\[\033[00m\] "' >> /home/ubuntu/.bashrc
