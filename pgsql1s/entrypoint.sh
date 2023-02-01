#!/bin/bash
chown postgres:postgres /database/
if [ "$(ls -A /database/)" ]
then
        echo "DATABASE EXISTS!"
else
        echo "DATABASE EMPTY, INIT...!"
        gosu postgres /opt/pgpro/1c-15/bin/initdb --locale=ru_RU.UTF-8 -D "/database/"
        sed -i 's/local   all             all                                     peer/local   all   postgres   trust/g' /database/pg_hba.conf
        echo "host    all         all         172.16.238.0/24    md5" >> /database/pg_hba.conf
fi

echo postgres:${PASS} | chpasswd
gosu postgres /opt/pgpro/1c-15/bin/pg_ctl -D "/database/" --log "/database/strat.log" -o "-c listen_addresses='*'" -w start
/opt/pgpro/1c-15/bin/psql -U postgres -c "ALTER USER postgres WITH PASSWORD '${PASS}';"
echo "//////////////////"
chmod +x /root/run.sh
chmod +x /root/healthcheck.sh
echo "PASS: ${PASS}"
crontab -l
cron -f







