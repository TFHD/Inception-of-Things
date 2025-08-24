# 🟢 Partie 1 : Mini-cluster Kubernetes avec Vagrant et K3s

Dans cette partie, vous allez apprendre à créer un petit cluster Kubernetes, composé de deux machines virtuelles, en automatisant l’installation et la configuration.

---

## 🛠️ Outils utilisés

- **Vagrant** : Permet de créer et configurer facilement des machines virtuelles par un simple fichier.
- **VirtualBox** : Héberge les machines virtuelles.
- **K3s** : Version compacte de Kubernetes, idéale pour les tests et l’IoT.

---

## 📄 1. Le fichier Vagrantfile

Ce fichier décrit l’infrastructure virtuelle à créer.  
Il définit ici deux VM : un “serveur” (node principal) et un “worker” (node secondaire).

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  # VM principale : sabarthoS
  config.vm.define "sabarthoS" do |control|
    control.vm.hostname = "sabarthoS"
    control.vm.network "private_network", ip: "192.168.56.110"
    control.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end
    control.vm.provision "shell", path: "scripts/provisionS.sh"
  end

  # VM secondaire : sabarthoSW
  config.vm.define "sabarthoSW" do |control|
    control.vm.hostname = "sabarthoSW"
    control.vm.network "private_network", ip: "192.168.56.111"
    control.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end
    control.vm.provision "shell", path: "scripts/provisionSW.sh"
  end
end
```

**Explications :**
- On utilise la box Ubuntu officielle.
- Chaque VM reçoit un nom, une IP privée et des ressources (mémoire, CPU).
- Un script spécifique est lancé sur chaque VM à sa création.

---

## ⚡ 2. Installation de K3s sur le serveur

Sur la VM principale, le script `provisionS.sh` installe le serveur K3s et configure le réseau.

```bash
curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token
sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.110/24 dev eth1 && sudo ip link set eth1 up
```

**Explications :**
- La première ligne installe K3s et démarre le serveur sur l’adresse IP donnée.
- Le token généré par K3s est copié, il sera utilisé par les autres nodes pour rejoindre le cluster.
- Une interface réseau “dummy” est créée pour simuler un vrai environnement réseau.

---

## 🏃‍♂️ 3. Rejoindre le cluster avec le worker

Sur la VM secondaire, le script `provisionSW.sh` attend que le token soit prêt, puis rejoint le cluster en tant que node “worker”.

```bash
while [ ! -f /vagrant/node-token ]; do sleep 2; done  # attend le token du serveur

TOKEN=$(cat /vagrant/node-token)
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -s - --node-ip=192.168.56.111
sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.111/24 dev eth1 && sudo ip link set eth1 up
```

**Explications :**
- Le script vérifie que le serveur a bien généré le token avant de continuer.
- Il rejoint le cluster en utilisant l’IP du serveur et le token d’authentification.
- Il crée également une interface réseau dummy.

---

## 🔗 4. Résultat attendu

À la fin du processus, vous disposez d’un cluster Kubernetes composé de deux machines virtuelles :  
- Un serveur (maître) qui gère le cluster.
- Un worker qui exécute les tâches du cluster.

Vous pouvez alors lancer des applications distribuées ou tester des scénarios IoT dans un environnement isolé et contrôlé.

---

## 💡 Astuce

Pour voir les nodes du cluster, connectez-vous à la VM principale et tapez :

```bash
sudo -s
kubectl get nodes -o wide
```
Vous devriez voir les deux machines listées comme nodes du cluster.

---

N’hésitez pas à explorer et modifier les scripts pour personnaliser votre infrastructure et mieux comprendre chaque étape !
