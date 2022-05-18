
# rook install
cd ${WORKDIR}
git clone --single-branch --branch master https://github.com/rook/rook.git
cd ${WORKDIR}/rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
kubectl create -f toolbox.yaml
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
kubectl create -f csi/rbd/storageclass.yaml
kubectl create -f csi/cephfs/storageclass.yaml
#helm install (Debian)
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
#Add helm repositories
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo add smallstep https://smallstep.github.io/helm-charts/
helm repo add jetstack https://charts.jetstack.io
helm repo update

cd ${ORIGN_PWD}
helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace
helm upgrade --install --create-namespace --namespace metallb --repo https://metallb.github.io/metallb metallb metallb -f metallb.yaml
helm upgrade --install --create-namespace --namespace ingress-nginx --repo https://kubernetes.github.io/ingress-nginx ingress-nginx ingress-nginx -f ${ORIGN_PWD}/nginx.yaml

kubectl -n rook-ceph rollout status deploy/rook-ceph-tools
kubectl -n metallb rollout status deployment.apps/metallb-controller

# Wait rook is healthy
while ! echo exit | (kubectl -n rook-ceph get cephcluster| grep HEALTH_OK); do sleep 10; done
helm upgrade -i step-certificates smallstep/step-certificates -f ${ORIGN_PWD}/ca-values.yaml --create-namespace --namespace ca --set inject.secrets.ca_password=$(cat ${ORIGN_PWD}/ca-password.txt) --set inject.secrets.provisioner_password=$(cat ${ORIGN_PWD}/ca-password.txt) --set service.targetPort=9000 --set ca.db.storageClass=rook-ceph-block
kubectl -n ca rollout status statefulset step-certificates

# add root.crt in cert-manager
kubectl get -n ca configmaps/step-certificates-certs -o jsonpath="{.data['root_ca\.crt']}" > ${WORKDIR}/root.crt
echo >> ${WORKDIR}/root.crt
kubectl get -n ca configmaps/step-certificates-certs -o jsonpath="{.data['intermediate_ca\.crt']}" > ${WORKDIR}/intermediate.crt
echo >> ${WORKDIR}/intermediate.crt
cat ${WORKDIR}/intermediate.crt ${WORKDIR}/root.crt > ${WORKDIR}/ca-certificates.crt
kubectl create ns cert-manager
kubectl -n cert-manager create configmap step-certificates --from-file ${WORKDIR}/ca-certificates.crt
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager -f ${ORIGN_PWD}/cert-manager.yaml
kubectl -n cert-manager rollout status deployment.apps/cert-manager
kubectl -n cert-manager apply -f cert-manager-conf.yaml
