#!/bin/bash

echo -e "\n\e[32;1mCreation du cluster\e[0m\n"
k3d cluster create iot

echo -e "\n\e[32;1mCreation des namespaces\e[0m\n"
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

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
argocd repo add https://github.com/TFHD/Inception-of-Things-ressources
sleep 1
argocd app create wil-playground \
  --repo https://github.com/TFHD/Inception-of-Things-ressources \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated

HOST_ENTRY="127.0.0.1 gitlab.k3d.gitlab.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo "exist $HOSTS_FILE"
else
    echo "adding $HOSTS_FILE"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

#kubectl delete secret gitlab-minio-secret -n gitlab --ignore-not-found

#echo -e "\n\e[32;1mCréation du secret MinIO pour GitLab\e[0m\n"
#kubectl create secret generic gitlab-minio-secret -n gitlab \
#  --from-literal=connection='{"provider":"AWS","aws_access_key_id":"minio","aws_secret_access_key":"minio123","region":"us-east-1","host":"minio","endpoint":"https://minio.gitlab.svc.cluster.local:9000"}' \
#  --from-literal=accesskey=minio \
#  --from-literal=secretkey=minio123

echo -e "\n\e[32;1mInstallation de GitLab via Helm dans le namespace gitlab\e[0m\n"
helm repo add gitlab https://charts.gitlab.io/
helm repo update

sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

echo -e "\n\e[33mAttente que les pods GitLab soient prêts\e[0m"
sudo kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath="{.data.password}" | base64 -d > gitlab_password.txt

#kubectl port-forward svc/wil-playground -n dev 8888:8888

