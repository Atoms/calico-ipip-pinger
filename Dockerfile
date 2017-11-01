FROM alpine:3.6

RUN apk add --no-cache bash curl

# Get etcdctl
ENV ETCD_VER=v3.2.4
RUN \
  cd /tmp && \
  curl -L https://storage.googleapis.com/etcd/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz | \
  tar xz -C /usr/local/bin --strip-components=1

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
