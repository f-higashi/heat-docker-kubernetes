# heat-docker-kubernetes

Steps:

1. Deploy a Kubernetes cluster on DevStack using Heat


## Directory layout

Clone  <https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/devstack-vagrant.git>

* `~/your_workspace/devstack-vagrant/`

## Setup DevStack

Provision DevStack.

```
cd ~/your_workspace/devstack-vagrant/
DEVSTACK_MEM=10024 DEVSTACK_CPUS=6 vagrant up --provider libvirt
```

Download custom image from Google drive: <https://drive.google.com/file/d/0B6KOuPCy8tK1aDRCaE16N1hkcUU/view>
Uncompress it and upload to vgrant host

```
unxz centos7-docker.qcow2.xz
scp -i devstack/.vagrant/machines/devstack/libvirt/private_key centos7-docker.qcow2 vagrant@192.168.123.100:/tmp/centos7-docker.qcow2
```
Upload custom Centos image to OpenStack.

```
cd ~/your_workspace/devstack-vagrant/
vagrant ssh

sudo su - stack
. devstack/openrc admin admin

glance image-create --name centos7 --disk-format qcow2 --container-format bare --file /tmp/centos7-docker.qcow2 --is-public True
```

Create and register a keypair.

```
ssh-keygen -f ~/.ssh/id_rsa -P ''
nova keypair-add keypair1 --pub-key ~/.ssh/id_rsa.pub
```

## Deploy Kubernetes cluster

```
admin_tenant_id=$(openstack project show admin -f value -c id)

image_id=$(openstack image show centos7 -f value -c id)
dns_server=10.0.238.34 # Change it to match your environment

git clone http://estscm1.intern.est.fujitsu.com/wlm/heat-docker-kubernetes.git
cd heat-docker-kubernetes

heat stack-create \
     -P external_network=public \
     -P ssh_key_name=keypair1 \
     -P server_image=${image_id} \
     -P master_flavor=m1.small \
     -P minion_flavor=m1.small \
     -P number_of_minions=1 \
     -P max_number_of_minions=1 \
     -P dns_nameserver=$dns_server \
     --timeout 60 \
     --template-file kubecluster.yaml \
     kubernetes_stack
```

## Verification

From your client computer:

```
$ kubectl -s http://MASTER_IP:8080 get nodes
NAME       STATUS    AGE
10.0.0.3   Ready     52m
10.0.0.4   Ready     50m

```



