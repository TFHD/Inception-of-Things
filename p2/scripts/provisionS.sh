curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token

sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.110/24 dev eth1 && sudo ip link set eth1 up

kubectl apply -f /vagrant/confs/app1-deployment.yaml
kubectl apply -f /vagrant/confs/app2-deployment.yaml
kubectl apply -f /vagrant/confs/app3-deployment.yaml
kubectl apply -f /vagrant/confs/app1-service.yaml
kubectl apply -f /vagrant/confs/app2-service.yaml
kubectl apply -f /vagrant/confs/app3-service.yaml
kubectl apply -f /vagrant/confs/app-ingress.yaml
