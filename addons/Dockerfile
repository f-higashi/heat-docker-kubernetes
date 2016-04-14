FROM debian:jessie

WORKDIR /opt/kube-addons

# copy kubectl binary
COPY kubectl kubectl

# copy addon yaml definitions
COPY heapster/ heapster/
COPY dns/ dns/
COPY dashboard/ dashboard/

# start script
COPY run.sh run.sh
ENTRYPOINT ["/opt/kube-addons/run.sh"]
