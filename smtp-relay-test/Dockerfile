FROM alpine:latest

RUN apk add --no-cache --update s-nail

COPY test.sh /usr/local/bin/

EXPOSE 587

CMD ["sh", "/usr/local/bin/test.sh"]