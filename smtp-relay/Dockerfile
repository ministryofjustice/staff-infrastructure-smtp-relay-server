FROM alpine:3.14.0

RUN apk add --no-cache --update postfix cyrus-sasl cyrus-sasl-crammd5 cyrus-sasl-digestmd5 cyrus-sasl-login cyrus-sasl-ntlm bash && \
    apk add --no-cache --upgrade musl musl-utils && \
    # Clean up
    (rm "/tmp/"* 2>/dev/null || true) && (rm -rf /var/cache/apk/* 2>/dev/null || true)

RUN mkdir -p /etc/sasl2
COPY smtpd.conf /etc/sasl2/

RUN echo "Password" | saslpasswd2 -p -c -u "postfix.devl.justice.gov.uk" "testuser"
RUN chmod a+r /etc/sasl2/sasldb2

VOLUME [ "/var/spool/postfix", "/etc/postfix", "/var/log/mail" ]

COPY entrypoint.sh /usr/local/bin/


EXPOSE 25

ENTRYPOINT ["entrypoint.sh"]
