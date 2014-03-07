#!/bin/sh
## Install RabbitMQ
apt-get -y install erlang-nox
echo "deb http://www.rabbitmq.com/debian/ testing main" >/etc/apt/sources.list.d/rabbitmq.list

curl -L -o ~/rabbitmq-signing-key-public.asc http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add ~/rabbitmq-signing-key-public.asc

apt-get update
apt-get -y --allow-unauthenticated --force-yes install rabbitmq-server

git clone git://github.com/joemiller/joemiller.me-intro-to-sensu.git
cd joemiller.me-intro-to-sensu/
./ssl_certs.sh clean
./ssl_certs.sh generate

mkdir /etc/rabbitmq/ssl
cp server_key.pem /etc/rabbitmq/ssl/
cp server_cert.pem /etc/rabbitmq/ssl/
cp testca/cacert.pem /etc/rabbitmq/ssl/

cp /tmp/sensu/rabbitmq.config /etc/rabbitmq/
#sleep 2
#rabbitmq-plugins enable rabbitmq_management

update-rc.d rabbitmq-server defaults
/etc/init.d/rabbitmq-server restart

# Create Vhost and user for Sensu
rabbitmqctl add_vhost /sensu
rabbitmqctl add_user sensu mypass
rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"

##
## End RabbitMQ Install

## install Redis
apt-get -y install redis-server
/etc/init.d/redis-server start

## Install Sensu
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" >/etc/apt/sources.list.d/sensu.list
apt-get update
apt-get -y install sensu

rm -f /etc/sensu/config.json.example
cp /tmp/sensu/config.json /etc/sensu
cp /tmp/sensu/client.json /etc/sensu/conf.d

## Set Sensu to run on startup
update-rc.d sensu-server defaults
update-rc.d sensu-api defaults
update-rc.d sensu-client defaults
update-rc.d sensu-dashboard defaults

## copy SSL created for RabbitMQ
mkdir /etc/sensu/ssl
cp /tmp/sensu/joemiller.me-intro-to-sensu/client_key.pem /tmp/sensu/joemiller.me-intro-to-sensu/client_cert.pem  /etc/sensu/ssl/

##Start Sensu
sudo /etc/init.d/sensu-server start
sudo /etc/init.d/sensu-api start
sudo /etc/init.d/sensu-client start    
sudo /etc/init.d/sensu-dashboard start    
