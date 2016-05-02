FROM debian:jessie

WORKDIR /opt/kube-addons

RUN apt-get update && apt-get install -y wget

RUN wget -P /usr/local/bin/ https://storage.googleapis.com/kubernetes-release/release/v1.2.0/bin/linux/amd64/kubectl
RUN chmod +x /usr/local/bin/kubectl

# copy the pwd to workdir
COPY . .

ENTRYPOINT ["/opt/kube-addons/run.sh"]
