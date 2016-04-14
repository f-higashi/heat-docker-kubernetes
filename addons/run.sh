#!/bin/bash
DNS_REPLICAS=${DNS_REPLICAS:-"1"}
DNS_DOMAIN=${DNS_DOMAIN:-"cluster.local"}
DNS_SERVER_IP=${DNS_SERVER_IP:-"10.0.0.10"}
WORK_DIR="/opt/kube-addons"

echo "Addon creation started"

cd ${WORK_DIR}

# Generate skydns yaml files
sed -e "s/{{ pillar\['dns_replicas'\] }}/${DNS_REPLICAS}/g;s/{{ pillar\['dns_domain'\] }}/${DNS_DOMAIN}/g;s/{{ pillar\['dns_server'\] }}/${DNS_SERVER_IP}/g" dns/skydns-rc.yaml.in > dns/skydns-rc.yaml
sed -e "s/{{ pillar\['dns_server'\] }}/${DNS_SERVER_IP}/g" dns/skydns-svc.yaml.in > dns/skydns-svc.yaml

# create skydns addon
./kubectl create -f kube-system.yaml
./kubectl create -f dns/skydns-svc.yaml
./kubectl create -f dns/skydns-rc.yaml

# create heapster addon
if [ "$ENABLE_CLUSTER_MONITORING" == "monasca" ]; then
    # TODO (Atanas): sed monasca configuration and start monasca heapster
    echo "Monasca should start"
else
    ./kubectl create -f heapster/standalone/
fi

# create dashboard addon
./kubectl create -f dashboard/
