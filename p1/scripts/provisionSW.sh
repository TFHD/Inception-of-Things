while [ ! -f /vagrant/node-token ];
    do sleep 2;
done

TOKEN=$(cat /vagrant/node-token)
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -s - --node-ip=192.168.56.111

sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.111/24 dev eth1 && sudo ip link set eth1 up
