#!/bin/bash

if [ -f "/root/srv1s.crt" ] && [ -f "/root/srv1s.key" ] ; then
        echo "Старт apache2"
        echo "ServerName $(cat /etc/hostname)" >> /etc/apache2/apache2.conf
        echo "Список конфигураций опубликованных баз:"
        for f in /var/www/1c/*; do
                if [[ -d "$f" && ! -L "$f" ]]; then
                        if [[ -f "$f/default.vrd" ]]; then
                                echo "$f/default.vrd"
                                chown root:www-data "$f/default.vrd"
                        fi
                fi
        done
        sed -i "s:PATH_TO_WSAP24:$(find /opt/1cv8/x86_64/ -name wsap24.so):g" /etc/apache2/sites-available/default-ssl.conf
        /etc/init.d/apache2 start 2>/dev/null >/dev/null
        a2enmod ssl 2>/dev/null >/dev/null
        a2ensite default-ssl 2>/dev/null >/dev/null
        /etc/init.d/apache2 restart 2>/dev/null >/dev/null
        echo "Статус сервера:"
        /etc/init.d/apache2 status
fi
echo "Старт сервера лицензирования"
/etc/init.d/haspd start 2>/dev/null >/dev/null
/etc/init.d/haspd start
echo "Старт сервера 1С"
chown -R usr1cv8:grp1cv8 /opt/1cv8/
chown -R usr1cv8:grp1cv8 /srvConfig/
chown -R usr1cv8:grp1cv8 /home/usr1cv8/
chown -R usr1cv8:www-data /root/usr1cv8.keytab
chmod 660 /root/usr1cv8.keytab


su -s /bin/sh  - "usr1cv8" -c "export Environment=SRV1CV8_KEYTAB=/root/usr1cv8.keytab; export SRV1CV8_KEYTAB=/root/usr1cv8.keytab; $(find /opt/1cv8/x86_64/ -name ragent) -d /srvConfig/ -port 1540 -regport 1541 -range 1560:1591 -seclev 0 -pingPeriod 1000 -pingTimeout 5000"




