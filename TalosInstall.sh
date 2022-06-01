TALOS=\
"10.10.110.11,_out/controlplane.yaml
 10.10.110.12,_out/controlplane.yaml
 10.10.110.13,_out/controlplane.yaml
 10.10.110.21,_out/worker.yaml
 10.10.110.22,_out/worker.yaml
 10.10.110.23,_out/worker.yaml"

while ! echo exit | nc 10.10.110.11 50000; do sleep 10; done
for word in $TALOS; do
 IFS=',' read -ra MYARRAY <<< $word
 while ! echo exit | nc ${MYARRAY[0]} 50000; do sleep 10; done
 talosctl apply-config --insecure --nodes ${MYARRAY[0]} --file ${WORKDIR}/${MYARRAY[1]}
done

export CONTROL_PLANE_IP=10.10.110.11
export TALOSCONFIG="${WORKDIR}/_out/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
while ! echo exit | nc $CONTROL_PLANE_IP 50000; do sleep 10; done
talosctl --talosconfig ${WORKDIR}/_out/talosconfig bootstrap

export CONTROL_PLANE_IP=10.10.110.10
while ! echo exit | nc $CONTROL_PLANE_IP 50000; do sleep 10; done
talosctl config endpoint $CONTROL_PLANE_IP
talosctl --talosconfig ${WORKDIR}/_out/talosconfig kubeconfig ${WORKDIR}
mkdir -p ~/.kube
vimdiff ${WORKDIR}/kubeconfig ~/.kube/config
mkdir -p ~/.talos
vimdiff ${WORKDIR}/_out ~/.kube/config
while ! echo exit | talosctl health --talosconfig ${WORKDIR}/_out/talosconfig --wait-timeout 10s ; do sleep 10; done
