# Inception-of-Things

Ce projet vous guide à travers la mise en place d'une infrastructure IoT moderne, basée sur des environnements virtualisés, Kubernetes, l'automatisation des déploiements (GitOps), et l'intégration de chaînes CI/CD complètes.

## Objectifs pédagogiques
- Comprendre et manipuler un cluster Kubernetes (K3s, K3d).
- Déployer des applications conteneurisées dans différents environnements.
- Mettre en place un pipeline GitOps avec ArgoCD.
- Intégrer GitLab pour la gestion avancée du code et des déploiements.
- Automatiser toutes les étapes (infrastructure, déploiement, supervision) via des scripts reproductibles.

## Structure du projet

- **p1/** : Déploiement d'un cluster Kubernetes multi-nodes avec Vagrant & K3s.
  - Deux VMs (un serveur, un worker), scripts d'installation et de provisioning.
- **p2/** : Déploiement de plusieurs applications conteneurisées sur une VM unique.
  - Manifeste Kubernetes pour 3 apps, services et Ingress, configuration DNS locale.
- **p3/** : Orchestration avancée et CI/CD avec ArgoCD et K3d.
  - Installation de Docker, K3d, ArgoCD, déploiement d'applications automatisées via GitOps.
- **bonus/** : Déploiement d'une instance GitLab dans le cluster, gestion de la synchronisation entre ArgoCD et GitLab, automatisation des déploiements avancés avec ArgoCD.

## Prérequis

- Linux
- Vagrant & VirtualBox
- Docker
- Accès à internet pour les installations et les récupérations de packages

## Lancement rapide

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/TFHD/Inception-of-Things.git
   ```
2. Suivre les instructions spécifiques dans chaque dossier (`p1`, `p2`, `p3`, `bonus`) pour installer et lancer l'infrastructure.

## À propos des scripts

Chaque partie dispose de scripts d'installation (`install.sh`) et de provisioning adaptés à ses besoins :
- Provisioning automatisé des machines virtuelles
- Déploiement des clusters et des applications
- Configuration des DNS et de l'accès aux services

## Auteur

Projet réalisé par [sabartho](https://github.com/TFHD).

---

> Pour plus de détails sur chaque étape, consultez les README présents dans les sous-dossiers.
