#!/bin/bash

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
kubectl port-forward svc/gitlab-webservice-default 80:8181 -n gitlab 2>&1 >/dev/null &

#kubectl port-forward svc/wil-playground -n dev 8888:8888

