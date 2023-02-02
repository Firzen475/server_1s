FROM ubuntu:20.04 as pgsql1s

ARG TZ Europe/Moscow
ENV TZ $TZ
ENV SHEDULE "0 0 * * *"
ARG PASS pass
ENV PASS $PASS
WORKDIR /root
SHELL ["/bin/bash", "-c"]
COPY entrypoint.sh /usr/local/bin/
RUN apt update && apt install -y wget cron tzdata gosu && \
        ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
        dpkg-reconfigure -f noninteractive tzdata && \
        echo "${SHEDULE} chmod +x /root/run.sh && /bin/bash /root/run.sh" >> /mycron | crontab -u root /mycron && crontab -l && \
        wget https://repo.postgrespro.ru/1c-15/keys/pgpro-repo-add.sh && \
        /bin/sh pgpro-repo-add.sh && \
        apt-get install -y postgrespro-1c-15-contrib && \
        mkdir -p /backup && \
        chmod +x /usr/local/bin/entrypoint.sh
#        /opt/pgpro/1c-15/bin/pg-setup initdb && \
#        mkdir -p /backup && mkdir -p /var/lib/pgpro/1c-15/data

VOLUME [ "/backup", "/database", "/root" ]
EXPOSE 5432
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]








