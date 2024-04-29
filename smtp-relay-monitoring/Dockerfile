FROM unikum/postfix_exporter:latest

RUN apt-get update --yes
RUN apt-get upgrade --yes

VOLUME [ "/var/log/mail", "/var/spool/postfix" ]

COPY entrypoint.sh /usr/local/bin/

EXPOSE 9154

ENTRYPOINT [ "entrypoint.sh" ]
