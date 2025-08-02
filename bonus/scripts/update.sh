GITLAB_PASSWORD=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)

echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PASS}"> ~/.netrc

sudo mv ~/.netrc /root/
sudo chmod 600 /root/.netrc

git clone http://gitlab.k3d.gitlab.com/root/test.git gitlab_repo
git clone https://github.com/TFHD/Inception-of-Things-ressources.git github_repo

mv github_repo/manifest gitlab_repo/
rm -rf github_repo/

cd gitlab_repo

git add .
git commit -m "update the repo"
git push

cd ..
