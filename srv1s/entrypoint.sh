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
echo "Сборкаа сервера лицензирования"
apt update && apt install dkms g++ libjansson-dev -y;
cat << EOF > /etc/ld.so.conf.d/libc.conf
# libc default configuration
/usr/local/lib
EOF
ldconfig
cp -fp /tmp/sbin/aksusbd_x86_64 /usr/sbin/
cat << EOF > /etc/udev/rules.d/80-hasp.rules
# HASP rules
ACTION=="add|change|bind", SUBSYSTEM=="usb", ATTRS{idVendor}=="0529", ATTRS{idProduct}=="0001", MODE="664", ENV{HASP}="1", SYMLINK+="aks/hasp/%k", RUN+="/usr/sbin/$aksusbd_bin -c \$root/aks/hasp/\$kernel"
ACTION=="remove", ENV{HASP}=="1", RUN+="/usr/sbin/$aksusbd_bin -r \$root/aks/hasp/\$kernel"

# SENTINEL rules
ACTION=="add|change|bind", SUBSYSTEM=="usb", ATTRS{idVendor}=="0529", ATTRS{idProduct}=="0003", KERNEL!="hiddev*", MODE="666", GROUP="plugdev", ENV{SENTINELHID}="1", SYMLINK+="aks/sentinelhid/%k"
EOF

/usr/sbin/aksusbd_x86_64 -d



#echo "Старт сервера лицензирования"
#/etc/init.d/haspd start 2>/dev/null >/dev/null
#/etc/init.d/haspd start
echo "Старт сервера 1С"
chown -R usr1cv8:grp1cv8 /opt/1cv8/
chown -R usr1cv8:grp1cv8 /srvConfig/
chown -R usr1cv8:grp1cv8 /home/usr1cv8/
chown -R usr1cv8:www-data /root/usr1cv8.keytab
chmod 660 /root/usr1cv8.keytab


su -s /bin/sh  - "usr1cv8" -c "export Environment=SRV1CV8_KEYTAB=/root/usr1cv8.keytab; export SRV1CV8_KEYTAB=/root/usr1cv8.keytab; $(find /opt/1cv8/x86_64/ -name ragent) -d /srvConfig/ -port 1540 -regport 1541 -range 1560:1591 -seclev 0 -pingPeriod 1000 -pingTimeout 5000"




