FROM alpine:3.20.2

RUN apk add --no-cache --update postfix cyrus-sasl ca-certificates bash && \
    apk add --no-cache --upgrade musl musl-utils && \
    # Clean up
    (rm "/tmp/"* 2>/dev/null || true) && (rm -rf /var/cache/apk/* 2>/dev/null || true)

VOLUME [ "/var/spool/postfix", "/etc/postfix", "/var/log/mail" ]

COPY entrypoint.sh /usr/local/bin/

EXPOSE 25

ENTRYPOINT ["entrypoint.sh"]
