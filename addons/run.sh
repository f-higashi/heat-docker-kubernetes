#!/bin/bash
# DNS configuration
DNS_REPLICAS=${DNS_REPLICAS:-"1"}
DNS_DOMAIN=${DNS_DOMAIN:-"cluster.local"}
DNS_SERVER_IP=${DNS_SERVER_IP:-"10.0.0.10"}

WORK_DIR="/opt/kube-addons"

echo "Addon creation started"

cd ${WORK_DIR}

# Generate skydns yaml files
sed -e "s/{{ pillar\['dns_replicas'\] }}/${DNS_REPLICAS}/g; \
        s/{{ pillar\['dns_domain'\] }}/${DNS_DOMAIN}/g; \
        s/{{ pillar\['dns_server'\] }}/${DNS_SERVER_IP}/g" \
        dns/skydns-rc.yaml.in > dns/skydns-rc.yaml
sed -e "s/{{ pillar\['dns_server'\] }}/${DNS_SERVER_IP}/g" dns/skydns-svc.yaml.in > dns/skydns-svc.yaml

# create skydns addon
./kubectl create -f kube-system.yaml
./kubectl create -f dns/skydns-svc.yaml
./kubectl create -f dns/skydns-rc.yaml

# create heapster addon
if [[ "$ENABLE_CLUSTER_MONITORING" -eq "monasca" ]] && \
   [ ! -z $OPENSTACK_USER_ID ] && \
   [ ! -z $OPENSTACK_USER_PASSWORD ] && \
   [ ! -z $KEYSTONE_URL ];
then
    echo "Creating heapster instance with a sink to monasca"
    # Generate heapster yaml files
    sed -e "s/{{ pillar\['monasca-user-id'\] }}/${OPENSTACK_USER_ID}/g; \
            s/{{ pillar\['monasca-user-password'\] }}/${OPENSTACK_USER_PASSWORD}/g; \
            s/{{ pillar\['keystone-url'\] }}/${KEYSTONE_URL}/g" \
            heapster/monasca/heapster-controller.yaml.in > heapster/monasca/heapster-controller.yaml
    cat heapster/monasca/heapster-controller.yaml
    ./kubectl create -f heapster/monasca/heapster-service.yaml
    ./kubectl create -f heapster/monasca/heapster-controller.yaml
else
    echo "Creating standalone heapster instance"
    ./kubectl create -f heapster/standalone/heapster-service.yaml
    ./kubectl create -f heapster/standalone/heapster-controller.yaml
fi

# create logging addon
if [[ "$ENABLE_NODE_LOGGING" -eq "true" ]] && \
   [[ "$LOGGING_DESTINATION" -eq "monasca" ]] && \
   [ ! -z $OPENSTACK_USER_NAME ] && \
   [ ! -z $OPENSTACK_USER_PASSWORD ] && \
   [ ! -z $OPENSTACK_PROJECT_NAME ] && \
   [ ! -z $OPENSTACK_DOMAIN_NAME ] && \
   [ ! -z $MONASCA_LOG_API ] && \
   [ ! -z $KEYSTONE_URL ];
then
    echo "Starting monasca logging for each node in the cluster"
    # Generate daemonset yaml file
    sed -e "s/{{ pillar\['monasca-log-api'\] }}/${MONASCA_LOG_API}/g; \
            s/{{ pillar\['keystone-url'\] }}/${KEYSTONE_URL}/g; \
            s/{{ pillar\['openstack-project-name'\] }}/${OPENSTACK_PROJECT_NAME}/g; \
            s/{{ pillar\['openstack-user-name'\] }}/${OPENSTACK_USER_NAME}/g; \
            s/{{ pillar\['openstack-user-password'\] }}/${OPENSTACK_USER_PASSWORD}/g; \
            s/{{ pillar\['openstack-domain-name'\] }}/${OPENSTACK_DOMAIN_NAME}/g" \
            logging/monasca/logstash-monasca.yaml.in > logging/monasca/logstash-monasca.yaml
    ./kubectl create -f logging/monasca/logstash-monasca.yaml
if

# create dashboard addon
./kubectl create -f dashboard/
