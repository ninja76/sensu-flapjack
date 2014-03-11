#!/bin/sh
## Install Sensu
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" >/etc/apt/sources.list.d/sensu.list
apt-get update
apt-get -y install sensu

cp /tmp/sensu/client/config.json /etc/sensu
cp /tmp/sensu/client/client.json /etc/sensu/conf.d
cp /tmp/sensu/plugins /etc/sensu/plugins

# Config client.json
sed -i -e "s/<hostname>/`hostname`/g" /etc/sensu/conf.d/client.json
ip=`ip addr show eth0 | grep -Eo '([0-9]*\.){3}[0-9]*' | tail -n 1`;sed -e "s/<address>/$ip/" /etc/sensu/conf.d/client.json

## Set Sensu to run on startup
update-rc.d sensu-client defaults

##Start Sensu
sudo /etc/init.d/sensu-client start    
