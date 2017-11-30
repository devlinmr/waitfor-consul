FROM alpine:3.6
MAINTAINER 	Martin Devlin <martin.devlin@pearson.com>

RUN apk add --update curl bash jq && rm -rf /var/cache/apk/*

COPY /run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

CMD ["/usr/bin/run.sh"]
