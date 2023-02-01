#!/bin/bash
[ -d /_1s/root_srv1s/ ] || mv ./root /_1s/root_srv1s
[ -d /_1s/srvConfig/ ] || mv ./root /_1s/srvConfig
[ -d /_1s/apacheConf/ ] || mv ./root /_1s/apacheConf
[ -d /_1s/apacheDir/ ] || mv ./root /_1s/apacheDir

[ -d /_1s/backup/ ] || mkdir -p /_1s/backup
[ -d /_1s/database/ ] || mkdir -p /_1s/database
[ -d /_1s/root_pgsql1s/ ] || mv ./root /_1s/root_pgsql1s

if [[ ! -f ./.env ]]; then
  touch ./.env && \
  echo 'TZ="Europe/Moscow"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
  echo 'SHEDULE="0 0 * * *"    # Расписание в формате cron * * * * *' >> ./.env
fi
