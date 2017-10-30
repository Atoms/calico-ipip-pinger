FROM alpine:3.6

RUN apk add --no-cache bash

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
