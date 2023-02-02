FROM ubuntu:20.04 as srv1s
ARG TZ Europe/Moscow
ENV TZ $TZ
WORKDIR /root
ADD distr /tmp
COPY entrypoint.sh /usr/local/bin/
COPY nethasp.ini /opt/1cv8/conf/
SHELL ["/bin/bash", "-c"]
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y tzdata fonts-liberation fontconfig krb5-user libkrb5-dev apache2 libapache2-mod-php libapache2-mod-auth-kerb && \
        ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
        dpkg-reconfigure -f noninteractive tzdata && \
        fc-cache –fv && \
        a2enmod auth_kerb && \
#        mkdir -p /var/www/1c/ &&
        tar -xvf /tmp/$(ls /tmp/ | grep server) --directory /tmp/ &&\
        /tmp/$(ls /tmp/ | grep setup-full) --mode unattended --disable-components client_full --enable-components server,ws,server_admin,liberica_jre,ru && \
        chmod +x /usr/local/bin/entrypoint.sh
VOLUME [ "/root", "/home/usr1cv8/.1cv8/", "/var/www/1c/", "/etc/apache2/sites-available/" ]
EXPOSE 1540 1541 1560:1591 80 443
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]









