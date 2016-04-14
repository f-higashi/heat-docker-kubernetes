#!/bin/bash
echo "Addon creation started"
WORK_DIR="/opt/kube-addons"
cd ${WORK_DIR}

# create heapster addon
if [ "$ENABLE_CLUSTER_MONITORING" == "monasca" ]; then
    # TODO (Atanas): sed monasca configuration and start monasca heapster
    echo "Monasca should start"
else
    ./kubectl create -f heapster/standalone/
fi
