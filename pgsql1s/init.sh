#!/bin/bash
[ -d /_1s/backup/ ] || mkdir -p /_1s/backup
[ -d /_1s/bd/ ] || mkdir -p /_1s/bd
[ -d /_1s/root/ ] || mv ./root/ /_1s/

if [[ ! -f ./.env ]]; then
  touch ./.env && \
  echo 'TZ="Asia/Yekaterinburg"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env && \
  echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env && \
  echo 'SHEDULE="0 0 * * *"  # Расписание в формате cron * * * * *' >> ./.env
fi



