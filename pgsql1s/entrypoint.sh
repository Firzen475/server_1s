#!/bin/bash
chmod +x /root/run.sh
echo "TZ: ${TZ}"
echo "PASS: ${PASS}"
echo "SHEDULE: ${SHEDULE}"
if [ "$(ls -A /var/lib/pgpro/1c-15/data)" ]
then
        echo "DATABASE EXISTS!"
else
        echo "DATABASE EMPTY, INIT...!"
        /opt/pgpro/1c-15/bin/pg-setup initdb
fi
echo postgres:${PASS} | chpasswd
sed -i 's/local   all             all                                     peer/local   all   postgres   trust/g' /var/lib/pgpro/1c-15/data/pg_hba.conf
/opt/pgpro/1c-15/bin/pg-setup service start
/opt/pgpro/1c-15/bin/psql -U postgres -c "ALTER USER postgres WITH PASSWORD '${PASS}';"
cron -f



