# 🟠 Partie 3 : Orchestration avancée et automatisation des déploiements avec ArgoCD et K3d

Dans cette partie, vous allez découvrir comment automatiser le déploiement d'applications dans Kubernetes grâce à des outils modernes comme ArgoCD et K3d.  
L'objectif est de mettre en place une chaîne GitOps : dès qu'une modification est poussée sur le dépôt Git, elle est automatiquement déployée sur le cluster.

---

## 🛠️ Outils principaux

- **Docker** : Permet d’exécuter des conteneurs, c’est-à-dire des environnements isolés pour les applications.
- **K3d** : Crée un cluster Kubernetes (K3s) dans des conteneurs Docker, idéal pour les tests locaux.
- **Kubectl** : Outil en ligne de commande pour interagir avec Kubernetes.
- **ArgoCD** : Outil de déploiement continu pour Kubernetes (GitOps), qui synchronise l’état du cluster avec le contenu d’un dépôt Git.

---

## 📄 1. Installation des outils (scripts/install.sh)

Le script installe tous les outils nécessaires.  
Chaque commande s’occupe d’un outil précis.

```bash
# Installation de Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Installation de k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Installation de kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Installation de ArgoCD
VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64"
chmod +x argocd
sudo mv argocd /usr/local/bin/
```

**Explications :**
- On prépare la machine pour exécuter des conteneurs (Docker).
- On installe k3d, qui permettra de créer le cluster Kubernetes dans Docker.
- On installe kubectl, l’outil principal pour piloter Kubernetes.
- On installe ArgoCD, qui gérera les déploiements automatisés.

---

## ⚡ 2. Création du cluster et déploiement automatisé (scripts/start.sh)

Le script crée le cluster, met en place ArgoCD et déploie l’application à partir du dépôt Git.

### Étape par étape

#### a) Création du cluster Kubernetes

```bash
k3d cluster create iot
```
- Crée un cluster nommé `iot` qui tournera dans des conteneurs Docker.

#### b) Création des namespaces

```bash
kubectl create namespace argocd
kubectl create namespace dev
```
- `argocd` : pour héberger ArgoCD (gestionnaire de déploiement).
- `dev` : pour héberger l’application à déployer.

#### c) Installation d’ArgoCD

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
- Déploie ArgoCD dans le cluster, dans le namespace dédié.

#### d) Connexion à ArgoCD et récupération du mot de passe

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
argocd login localhost:8080 --username admin --password <mot_de_passe> --insecure
```
- On récupère le mot de passe généré automatiquement pour l’admin.
- On connecte l’outil ArgoCD à l’instance locale.

#### e) Ajout du dépôt Git et déploiement automatisé

```bash
argocd repo add https://github.com/TFHD/Inception-of-Things-ressources-sabartho
argocd app create wil-playground \
  --repo https://github.com/TFHD/Inception-of-Things-ressources-sabartho \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated
```
- On indique à ArgoCD d’utiliser le dépôt Git comme source des manifestes Kubernetes.
- Toute modification sur le dépôt sera automatiquement déployée dans le cluster.

---

## 📝 3. Accès et suivi

Pour accéder à l’interface graphique d’ArgoCD et suivre les déploiements, il suffit de faire un port-forward (rediriger le port du conteneur vers votre machine locale) :

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Vous pouvez ensuite ouvrir [http://localhost:8080](http://localhost:8080) dans votre navigateur.

---

## 🎯 Résultat attendu

- Un cluster Kubernetes local, prêt à accueillir des applications.
- Des déploiements automatisés : chaque changement sur le dépôt Git est appliqué sur le cluster sans intervention manuelle.
- Un accès simple à l’interface ArgoCD pour monitorer et piloter vos applications.

---

En modifiant les fichiers du dépôt Git, vous pouvez voir ArgoCD détecter, synchroniser et déployer automatiquement vos applications dans le cluster.
