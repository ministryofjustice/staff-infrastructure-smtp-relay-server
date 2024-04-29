FROM alpine:3.19.1

RUN apk add --no-cache --update s-nail

COPY test.sh /usr/local/bin/

CMD ["sh", "/usr/local/bin/test.sh"]
