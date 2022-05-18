TALOS_VERSION=1.0.4
KUBECTL_VERSION=1.24.0
export CONTROL_PLANE_IP=10.10.110.10

while getopts v:h flag
do
  case "${flag}" in
    v) VERSION="v${OPTARG}"; SAVING="true";;
    h) echo "-v version"
  esac  
done

export ORIGN_PWD=`pwd`
export WORKDIR=$(mktemp -d -t "WORKDIR${VERSION}_XXXXX")
echo "WORKDIR= ${WORKDIR}"
cp ${WORKDIR}
curl https://github.com/siderolabs/talos/releases/download/v${TALOS_VERSION}/talosctl-linux-amd64 -L -o talosctl
sudo install -o root -g root -m 0755 talosctl /usr/local/bin/talosctl
curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "94d686bb6772f6fb59e3a32beff908ab406b79acdfb2427abdc4ac3ce1bb98d7 kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo usermod -a -G docker ansible
docker run -d -p 5000:5000     -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io     --restart always     --name registry-docker.io registry:2
docker run -d -p 5001:5000     -e REGISTRY_PROXY_REMOTEURL=https://k8s.gcr.io     --restart always     --name registry-k8s.gcr.io registry:2
docker run -d -p 5002:5000     -e REGISTRY_PROXY_REMOTEURL=https://quay.io     --restart always     --name registry-quay.io registry:2.5
docker run -d -p 5003:5000     -e REGISTRY_PROXY_REMOTEURL=https://gcr.io     --restart always     --name registry-gcr.io registry:2
docker run -d -p 5004:5000     -e REGISTRY_PROXY_REMOTEURL=https://ghcr.io     --restart always \
docker run -d -p 5000:5000     -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io     --restart always     --name registry-docker.io registry:2
docker run -d -p 5001:5000     -e REGISTRY_PROXY_REMOTEURL=https://k8s.gcr.io     --restart always     --name registry-k8s.gcr.io registry:2
docker run -d -p 5002:5000     -e REGISTRY_PROXY_REMOTEURL=https://quay.io     --restart always     --name registry-quay.io registry:2.5
docker run -d -p 5003:5000     -e REGISTRY_PROXY_REMOTEURL=https://gcr.io     --restart always     --name registry-gcr.io registry:2
docker run -d -p 5004:5000     -e REGISTRY_PROXY_REMOTEURL=https://ghcr.io     --restart always     --name registry-ghcr.io registry:2
curl http://localhost:5000/v2/
mkdir -p ${WORKDIR}/_out
cat $ORIGN_PWD/control-plane-patch.yaml|sed "s:CONTROL_PLANE_IP:${CONTROL_PLANE_IP}:g" >> ${WORKDIR}/control-plane-patch.yaml
cp $ORIGN_PWD/config-patch.yaml  ${WORKDIR}/config-patch.yaml
talosctl gen config talos-vbox-cluster https://${CONTROL_PLANE_IP}:6443 --output-dir ${WORKDIR}/_out   --config-patch-control-plane @${WORKDIR}/control-plane-patch.yaml  --config-patch @${WORKDIR}/config-patch.yaml

bash -x ${ORIGN_PWD}/create_vm.sh

bash -x ${ORIGN_PWD}/TalosInstall.sh

bash -x ${ORIGN_PWD}/K8sInstall.sh
