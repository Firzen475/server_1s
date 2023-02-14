#!/bin/bash

if [[ ! -n "$1" ]]; then
        echo "Не задано имя контроллера домена!"
        exit 1
fi

if [[ ! -n "$2" ]]; then
        echo "Не задано имя домена!"
        exit 1
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

echo "Подготовка хранилища"
apt install -qq -y tree > /dev/null
[ -d /_1s/srvConfig/ ] || mkdir -p /_1s/srvConfig
[ -d /_1s/root_srv1s/ ] || mv ./srv1s/root_srv1s /_1s/root_srv1s
[ -d /_1s/apacheConf/ ] || mv ./srv1s/apacheConf /_1s/apacheConf
[ -d /_1s/apacheDir/ ] || mv ./srv1s/apacheDir /_1s/apacheDir

[ -d /_1s/backup/ ] || mkdir -p /_1s/backup
[ -d /_1s/database/ ] || mkdir -p /_1s/database
[ -d /_1s/root_pgsql1s/ ] || mv ./pgsql1s/root /_1s/root_pgsql1s
tree /_1s/

if [[ ! -f ./.env ]]; then
  touch ./.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
  echo 'SHEDULE="0 0 * * *"    # Расписание в формате cron * * * * *' >> ./.env
fi

if [[ ! -f ./srv1s/.env ]]; then
  touch ./srv1s/.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
fi

if [[ ! -f ./pgsql1s/.env ]]; then
  touch ./.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
  echo 'SHEDULE="0 0 * * *"    # Расписание в формате cron * * * * *' >> ./.env
fi
