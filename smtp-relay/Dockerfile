FROM alpine:latest

RUN apk add --no-cache --update postfix bash && \
    apk add --no-cache --upgrade musl musl-utils && \
    apk add --no-cache --upgrade mailx && \
    # Clean up
    (rm "/tmp/"* 2>/dev/null || true) && (rm -rf /var/cache/apk/* 2>/dev/null || true)

VOLUME [ "/var/spool/postfix", "/etc/postfix" ]

COPY entrypoint.sh /usr/local/bin/

EXPOSE 587

ENTRYPOINT ["entrypoint.sh"]

CMD ["postfix", "start-fg"]