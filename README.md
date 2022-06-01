# kubernetes-talos-HA-cluster
init:
install and user step

wget https://dl.step.sm/gh-release/cli/gh-release-header/v0.19.0/step-cli_0.19.0_amd64.deb
sudo dpkg -i step-cli_*.deb
rm step-cli_*.deb
step ca init --helm > ca-values.yaml

1. What deployment type would you like to configure?
 Standalone
2. What would you like to name your new PKI?
 LocalDomain
3. What DNS names or IP addresses would you like to add to your new CA?
 step-certificates.ca.svc.cluster.local
4. What IP and port will your new CA bind to (it should match service.targetPort)?
 :9000
5. What would you like to name the CA's first provisioner?
 LocalDomain

Insert ito ca-values.yaml
      authority:
          provisioners:
            - type: ACME
              name: acme
            - {"type":"JWK","name":"....

 echo "step password" | base64 > ca-password.txt
 chmod 400 ca-password.txt



resource:
proxmox server in 10.10.99.26 address
    vmbr1 bridge
    110 vlan (routing and dhcp)


run:
bash -x make.sh
