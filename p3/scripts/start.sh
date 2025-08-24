#!/bin/bash

echo -e "\n\e[32;1mCreation du cluster\e[0m\n"
k3d cluster create iot

echo -e "\n\e[32;1mCreation des namespaces\e[0m\n"
kubectl create namespace argocd
kubectl create namespace dev

echo -e "\n\e[32;1mApplication de Argo dans son namespace\e[0m\n"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "\e[33mAttente de la disponibilité d'argocd-server...\e[0m"
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd

while ! kubectl -n argocd get secret argocd-initial-admin-secret &> /dev/null; do
  echo -e "\e[31mEn attente de la création du secret initial admin...\e[0m"
  sleep 3
done

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > ./password.txt
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo -e "\e[33mPort-forward vers l'API ArgoCD...\e[0m"
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
PF_PID=$!

while ! nc -z localhost 8080; do   
  sleep 1
done

echo -e "\e[31mSetup de l'application\e[0m"
ARGOCD_HOST=localhost:8080
ARGOCD_USER=admin

argocd login $ARGOCD_HOST --username $ARGOCD_USER --password $ARGOCD_PASS --insecure

sleep 1
argocd repo add https://github.com/TFHD/Inception-of-Things-ressources-sabartho
sleep 1
argocd app create wil-playground \
  --repo https://github.com/TFHD/Inception-of-Things-ressources-sabartho \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated

kubectl port-forward svc/wil-playground -n dev 8888:8888 2>&1 >/dev/null &
