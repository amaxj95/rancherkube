# rancherkube

>> curl -fsSL https://clis.cloud.ibm.com/install/linux | sh <br>
>> ibmcloud login --sso -a cloud.ibm.com -r us-east -g Default <br>

docker tag hello-world icr.io/rancher-csde-caci-com/hello-world:v3
docker pull rancher/rancher
sudo cp /etc/rancher/rke2/rke2.yaml ~/.kube/config

sudo chown $USER:$USER ~/.kube/config

export KUBECONFIG=~/.kube/config

kubectl get nodes

 

# gets control node server node

kubectle get nodes -o wide | grep master | awk '{print $6}'

 

gets token of server plane

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep default-token | awk '{print $1}')