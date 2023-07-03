FROM alpine:3.18.2

RUN apk add --no-cache --update s-nail

COPY test.sh /usr/local/bin/

CMD ["sh", "/usr/local/bin/test.sh"]