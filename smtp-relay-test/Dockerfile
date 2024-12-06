FROM alpine:3.21.0

RUN apk add --no-cache --update s-nail

COPY test.sh /usr/local/bin/

CMD ["sh", "/usr/local/bin/test.sh"]
