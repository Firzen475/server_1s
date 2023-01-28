#!/bin/bash
mkdir -p /_1s/backup
mkdir -p /_1s/bd
mv ./root/ /_1s/

touch ./.env
echo 'TZ="Asia/Yekaterinburg"     # Europe/Moscow Asia/Yekaterinburg' >> ./.env
echo 'PASS="password"        # Пароль пользователя postgres' >> ./.env
echo 'SHEDULE="0 0 * * *"  # Расписание в формате cron * * * * *' >> ./.env
