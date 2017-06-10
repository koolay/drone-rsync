FROM alpine:3.4
MAINTAINER Michael de Wit <michael@drillster.com>

RUN apk add --no-cache ca-certificates bash openssh-client rsync
COPY upload.sh /usr/local/
RUN chmod +x /usr/local/bin/upload.sh

CMD ["/usr/local/upload.sh"]
