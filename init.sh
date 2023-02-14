#!/bin/bash
[ -f "./srv1s/distr/" ] || mkdir ./srv1s/distr/
if [[ ! -n "$1" ]]; then
        echo "Не задано имя контроллера домена!"
        exit 1
fi

if [[ ! -n "$2" ]]; then
        echo "Не задано имя домена!"
        exit 1
fi

echo "Настройка hasp+ ключей =)"
apt -qq update 2>/dev/null >/dev/null
if [ -f ./hasp.zip ]; then
    apt install -qq -y p7zip-full 2>/dev/null >/dev/null
    7z x ./hasp.zip -y -p"$3" -o/tmp/ 2>/dev/null >/dev/null
    mv /tmp/haspd_7.90-eter2ubuntu_amd64.deb /tmp/haspd-modules_7.90-eter2ubuntu_amd64.deb ./srv1s/distr/
    apt install -y /tmp/libusb-vhci_0.8-2_amd64.deb 2>/dev/null >/dev/null
    apt list --installed | grep libusb-vhci
    apt install -y /tmp/usb-vhci-hcd-dkms_1.15.1_amd64.deb 2>/dev/null >/dev/null
    apt list --installed | grep usb-vhci-hcd-dkms
    apt install -y /tmp/usbhasp_0.1-2_amd64.deb 2>/dev/null >/dev/null
    apt list --installed | grep usbhasp
    mkdir -p /etc/usbhaspd/keys
    mv /tmp/srv.json /tmp/users.json /etc/usbhaspd/keys
    systemctl enable usbhaspd
    systemctl start usbhaspd
    apt -qq update 2>/dev/null >/dev/null
    lsusb | grep Aladdin
fi

dc=$(echo "$1" | awk '{print tolower($0)}')
domain_up=$(echo "$2" |  awk '{print toupper($0)}')
domain_low=$(echo "$2" | awk '{print tolower($0)}')

echo "Добавление домена в имени хоста /etc/hosts"
sed -i "s/^127.0.1.1.*/127.0.1.1 srv1s.$domain_low/g" /etc/hosts
cat /etc/hosts | grep 127.0.1.1

echo "Добавление записей в файл ./srv1s/srv1s.conf для сертификата."
if grep -q "DNS.1" ./srv1s/srv1s.conf; then
        sed -i "s/^DNS.1.*/DNS.1               = srv1s/g" ./srv1s/srv1s.conf
else
        echo "2"
        echo "DNS.1               = srv1s" >> ./srv1s/srv1s.conf
fi
if grep -q "DNS.2" ./srv1s/srv1s.conf; then
        sed -i "s/^DNS.2.*/DNS.2               = srv1s.$domain_up/g" ./srv1s/srv1s.conf
else
        echo "DNS.2               = srv1s.$domain_up" >> ./srv1s/srv1s.conf
fi
if grep -q "DNS.3" ./srv1s/srv1s.conf; then
        sed -i "s/^DNS.3.*/DNS.3               = srv1s.$domain_low/g" ./srv1s/srv1s.conf
else
        echo "DNS.3               = srv1s.$domain_low" >> ./srv1s/srv1s.conf
fi
cat ./srv1s/srv1s.conf | grep DNS.1
cat ./srv1s/srv1s.conf | grep DNS.2
cat ./srv1s/srv1s.conf | grep DNS.3

echo "Создание сертификатов"
openssl req -x509 -nodes -days 4000 -newkey rsa:2048 \
-keyout ./srv1s/root_srv1s/srv1s.key -out ./srv1s/root_srv1s/srv1s.crt -config ./srv1s/srv1s.conf
ls -all ./srv1s/root_srv1s/srv1s.key
ls -all ./srv1s/root_srv1s/srv1s.crt

echo "Настройка файла krb5.conf"
sed -i "s/example.com/$domain_low/g" ./srv1s/krb5.conf
sed -i "s/EXAMPLE.COM/$domain_up/g" ./srv1s/krb5.conf
cat ./srv1s/krb5.conf | grep "$domain_low"
cat ./srv1s/krb5.conf | grep "$domain_up"

echo "Подготовка хранилища"
apt install -qq -y tree 2>/dev/null >/dev/null
[ -d /_1s/srvConfig/ ] || mkdir -p /_1s/srvConfig
[ -d /_1s/root_srv1s/ ] || mv ./srv1s/root_srv1s /_1s/root_srv1s
[ -d /_1s/apacheConf/ ] || mv ./srv1s/apacheConf /_1s/apacheConf
[ -d /_1s/apacheDir/ ] || mv ./srv1s/apacheDir /_1s/apacheDir

[ -d /_1s/backup/ ] || mkdir -p /_1s/backup
[ -d /_1s/database/ ] || mkdir -p /_1s/database
[ -d /_1s/root_pgsql1s/ ] || mv ./pgsql1s/root /_1s/root_pgsql1s
tree /_1s/

echo "Подготовка файлов переменных"
if [[ ! -f ./.env ]]; then
  touch ./.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
  echo 'SHEDULE="0 0 * * *"    # Расписание в формате cron * * * * *' >> ./.env
  cat ./.env
fi

if [[ ! -f ./srv1s/.env ]]; then
  touch ./srv1s/.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env
  cat ./srv1s/.env
fi

if [[ ! -f ./pgsql1s/.env ]]; then
  touch ./pgsql1s/.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
  echo 'SHEDULE="0 0 * * *"    # Расписание в формате cron * * * * *' >> ./.env
  cat ./pgsql1s/.env
fi
