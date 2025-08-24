# 🔵 Bonus : Déploiement de GitLab et intégration DevOps avancée

Dans cette extension, vous allez installer GitLab dans Kubernetes et automatiser la synchronisation et le déploiement entre GitHub, GitLab et ArgoCD.  
Objectif : simuler une chaîne DevOps complète, multi-registry et entièrement automatisée.

---

## 🛠️ Outils principaux

- **Helm** : Un gestionnaire de paquets pour Kubernetes, qui simplifie l’installation d’applications complexes.
- **GitLab** : Plateforme de gestion de code, CI/CD et collaboration.
- **ArgoCD** : Outil de déploiement continu, déjà vu dans la partie précédente.

---

## 📄 1. Installation de Helm (scripts/install.sh)

Helm est installé via un script très simple :

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```
**Explications :**
- Cette commande télécharge et installe Helm, qui sera utilisé pour installer GitLab dans Kubernetes.

---

## ⚡ 2. Déploiement de GitLab dans Kubernetes (scripts/start.sh)

### a) Préparer le DNS local

On ajoute le nom de domaine de GitLab à `/etc/hosts` pour pouvoir y accéder localement.

```bash
echo "127.0.0.1 gitlab.k3d.gitlab.com" | sudo tee -a /etc/hosts
```
**Explications :**  
Permet d’accéder à GitLab via le nom `gitlab.k3d.gitlab.com` sur votre machine.

---

### b) Installation de GitLab via Helm

```bash
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s
```
**Explications :**
- On crée le namespace `gitlab` pour isoler l’installation.
- On ajoute le dépôt officiel GitLab pour Helm.
- On utilise une configuration minimale adaptée à un environnement de test.

---

### c) Récupération du mot de passe et accès

```bash
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath="{.data.password}" | base64 -d > gitlab_password.txt
kubectl port-forward svc/gitlab-webservice-default 80:8181 -n gitlab &
```
**Explications :**
- On extrait le mot de passe root de GitLab, généré à l’installation.
- On rend l’interface GitLab accessible en local via le port 80.

---

## 🔄 3. Synchronisation et déploiement automatisé (scripts/update.sh)

### a) Configuration de l’accès GitLab avec `.netrc`

```bash
echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PASSWORD}" > ~/.netrc
```
**Explications :**
- Ce fichier permet d’automatiser les accès et opérations Git (push/pull) sur GitLab.

---

### b) Synchronisation des manifestes entre GitHub et GitLab

```bash
git clone https://github.com/TFHD/Inception-of-Things-ressources.git github_repo
git clone http://gitlab.k3d.gitlab.com/root/test.git gitlab_repo
mv github_repo/manifest gitlab_repo/
rm -rf github_repo/
cd gitlab_repo
git add .
git commit -m "update the repo"
git push
```
**Explications :**
- On clone le dépôt GitHub et le dépôt GitLab.
- On transfère les manifestes Kubernetes du dépôt GitHub vers le dépôt GitLab.
- On commit et push les modifications sur GitLab.

---

### c) Déploiement automatisé avec ArgoCD (toujours dans le script)

```bash
argocd app create wil-playground2 \
  --repo http://gitlab-webservice-default.gitlab.svc:8181/root/test.git \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated
```
**Explications :**
- On configure ArgoCD pour surveiller le repo GitLab et déployer automatiquement les manifestes dès qu’ils changent.

---

## 🎯 Résultat attendu

- **GitLab** est opérationnel dans le cluster Kubernetes et accessible localement.
- Les manifestes Kubernetes sont synchronisés entre GitHub et GitLab.
- ArgoCD déploie automatiquement les applications dès qu’un changement est détecté sur GitLab.

---

Ce workflow vous permet de simuler une chaîne DevOps complète : édition de code, synchronisation entre plateformes, et déploiement automatisé dans Kubernetes.
