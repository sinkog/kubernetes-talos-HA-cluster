PROXMOX_ACCESS="root@10.10.99.26"
TALOS_NAME='TalosDevops'
ROOT_STORAGE="scsi0 ssd-vm:64"
CEPH_STORAGE="scsi1 local-zfs:128"
TALOS_ISO="iso:iso/talos-amd64.iso"
TALOS=\
"771,${TALOS_NAME}Master01,08:00:27:A4:A4:A1,8192,2048,1,c
 772,${TALOS_NAME}Master02,08:00:27:A4:A4:A2,8192,2048,1,c
 773,${TALOS_NAME}Master03,08:00:27:A4:A4:A3,8192,2048,1,c
 781,${TALOS_NAME}Worker01,08:00:27:A4:A4:B1,12288,2048,2,w
 782,${TALOS_NAME}Worker02,08:00:27:A4:A4:B2,12288,2048,2,w
 783,${TALOS_NAME}Worker03,08:00:27:A4:A4:B3,12288,2048,2,w"

 SSH_COMMAND="echo 'start'"

for word in $TALOS; do
 IFS=',' read -ra MYARRAY <<< $word
 SSH_COMMAND="${SSH_COMMAND}; qm stop ${MYARRAY[0]}; qm destroy ${MYARRAY[0]}"
done
 
for word in $TALOS; do
 IFS=',' read -ra MYARRAY <<< $word
 echo "Creating Talos virtual machine ${MYARRAY[0]}"
 SSH_COMMAND="${SSH_COMMAND}; qm create  ${MYARRAY[0]} \
  --name ${MYARRAY[1]} \
  --onboot 1 \
  --startup order=${MYARRAY[5]},up=180 \
  --net0 virtio,bridge=vmbr1,tag=110,macaddr=${MYARRAY[2]} \
  --cdrom ${TALOS_ISO} \
  --scsihw virtio-scsi-pci \
  --${ROOT_STORAGE} \
  --bootdisk virtio0 \
  --ostype l26 \
  --memory ${MYARRAY[3]} \
  --balloon ${MYARRAY[4]} \
  --onboot yes \
  --start true \
  --sockets 4 \
  --cores 4 "
 if [ "${MYARRAY[6]}" == "w" ]; then
  SSH_COMMAND="${SSH_COMMAND} \
  --${CEPH_STORAGE} "
 fi
done

ssh ${PROXMOX_ACCESS} ${SSH_COMMAND}

echo "Finished..."
