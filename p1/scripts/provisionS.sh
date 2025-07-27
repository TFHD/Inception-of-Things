curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token