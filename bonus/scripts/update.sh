GITLAB_PASSWORD=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)

echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PASSWORD}"> ~/.netrc

sudo chmod 600 ~/.netrc

git clone http://gitlab.k3d.gitlab.com/root/test.git gitlab_repo
git clone https://github.com/TFHD/Inception-of-Things-ressources.git github_repo

mv github_repo/manifest gitlab_repo/
rm -rf github_repo/

cd gitlab_repo

git config --global user.email "root@root.com"
git config --global user.name "root"

git add .
git commit -m "update the repo"
git push

cd ..

argocd app create wil-playground2 \
  --repo http://gitlab-webservice-default.gitlab.svc:8181/root/test.git \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated
