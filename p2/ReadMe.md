# 🟡 Partie 2 : Déployer plusieurs applications dans Kubernetes

Dans cette partie, vous allez découvrir comment installer et exposer plusieurs applications conteneurisées sur un cluster Kubernetes local, tout en simulant un accès par nom de domaine.

---

## 🛠️ Outils principaux

- **Vagrant & VirtualBox** : Créent et hébergent la machine virtuelle qui servira de serveur.
- **K3s** : Fournit le cluster Kubernetes, facile à installer et léger.
- **Kubernetes manifests (YAML)** : Fichiers de configuration pour décrire les déploiements, services et règles de routage.

---

## 📄 1. Le fichier Vagrantfile

Ce fichier décrit la machine virtuelle à créer :
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.define "sabarthoS" do |control|
    control.vm.hostname = "sabarthoS"
    control.vm.network "private_network", ip: "192.168.56.110"
    control.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end
    control.vm.provision "shell", path: "scripts/provisionS.sh"
  end
end
```
**Explications :**
- On crée une seule VM Ubuntu avec une IP privée.
- Un script va s’exécuter à la fin de la création pour installer et configurer Kubernetes.

---

## ⚡ 2. Installation et déploiements via provisionS.sh

Ce script installe K3s et déploie les applications et leurs composants Kubernetes.

```bash
# Installation de K3s
curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110

# Déploiement des applications
kubectl apply -f /vagrant/confs/app1-deployment.yaml
kubectl apply -f /vagrant/confs/app2-deployment.yaml
kubectl apply -f /vagrant/confs/app3-deployment.yaml

# Exposition des applications via des services
kubectl apply -f /vagrant/confs/app1-service.yaml
kubectl apply -f /vagrant/confs/app2-service.yaml
kubectl apply -f /vagrant/confs/app3-service.yaml

# Configuration du routage HTTP (Ingress)
kubectl apply -f /vagrant/confs/app-ingress.yaml
```

**Explications :**
- On installe K3s pour avoir un cluster Kubernetes opérationnel.
- On déploie trois applications via des fichiers YAML (voir ci-dessous).
- Chaque application est exposée par un service interne.
- On configure un Ingress pour pouvoir accéder à chaque application par un nom de domaine local.

---

## 🏗️ 3. Exemple de manifeste de déploiement

**app1-deployment.yaml** :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-one
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-one
  template:
    metadata:
      labels:
        app: app-one
    spec:
      containers:
      - name: app-one
        image: sabartho/kubernetes-whoami
        ports:
        - containerPort: 80
        env:
          - name: APP_NAME
            value: "app1"
```
**Explications :**
- Ce fichier demande à Kubernetes de lancer un conteneur Docker nommé “app-one” avec une image précise (__sabartho/kubernetes-whoami__), et de l’exposer sur le port 80.
- l'image "sabartho/kubernetes-whoami" est une image faite par mes soins que vous pouvez retrouver sur DockerHub !
- On peut ajuster le nombre de “replicas” pour avoir plusieurs instances de l’application.

---

## 🌐 4. Exemple de service et d’Ingress

**app1-service.yaml** :
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-one
spec:
  selector:
    app: app-one
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```
**Explications :**
- Ce service fait le lien entre le réseau du cluster et les pods de l’application.
- Il permet à l’Ingress (voir ci-dessous) de rediriger le trafic vers l’application.

**app-ingress.yaml** :
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
spec:
  rules:
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-one
            port:
              number: 80
  # Autres règles pour app2.com et app3.com
```
**Explications :**
- L’Ingress permet d’accéder à chaque application par un nom de domaine spécifique.
- Par exemple, une requête vers “app1.com” sera dirigée vers le service “app-one”.

---

## 📝 5. Configuration du DNS local

Un script ajoute les noms de domaine dans `/etc/hosts` pour permettre l’accès local :
```
192.168.56.110 app1.com app2.com app3.com
```
**Explications :**
- Cela permet de tester le routage comme si chaque application était hébergée sur un vrai site web.

---

## 🎯 Résultat attendu

Vous disposez d’une machine virtuelle avec trois applications accessibles via des noms de domaine locaux, comme sur un vrai serveur cloud.

---

Vous pouvez adapter les fichiers YAML pour ajouter ou modifier des applications, et observer comment Kubernetes orchestre leur fonctionnement et leur accès réseau.
