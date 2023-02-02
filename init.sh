#!/bin/bash
[ -d /_1s/srvConfig/ ] || mkdir -p /_1s/srvConfig
[ -d /_1s/root_srv1s/ ] || mv ./srv1s/root_srv1s /_1s/root_srv1s
[ -d /_1s/apacheConf/ ] || mv ./srv1s/apacheConf /_1s/apacheConf
[ -d /_1s/apacheDir/ ] || mv ./srv1s/apacheDir /_1s/apacheDir

openssl req -x509 -nodes -days 4000 -newkey rsa:2048 -keyout /_1s/root_srv1s/srv1s.key -out /_1s/root_srv1s/srv1s.crt -config ./srv1s/srv1s.conf

[ -d /_1s/backup/ ] || mkdir -p /_1s/backup
[ -d /_1s/database/ ] || mkdir -p /_1s/database
[ -d /_1s/root_pgsql1s/ ] || mv ./pgsql1s/root /_1s/root_pgsql1s

if [[ ! -f ./.env ]]; then
  touch ./.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
  echo 'SHEDULE="0 0 * * *"    # Расписание в формате cron * * * * *' >> ./.env
fi
