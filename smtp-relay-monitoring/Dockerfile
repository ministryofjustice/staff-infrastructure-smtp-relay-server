FROM ghcr.io/hsn723/postfix_exporter:0.5.2

VOLUME [ "/var/log/mail", "/var/spool/postfix" ]

COPY entrypoint.sh /usr/local/bin/

EXPOSE 9154

ENTRYPOINT [ "entrypoint.sh" ]
