#!/bin/bash
mydate=$(date '+%Y_%m_%d_%H_%M_%S')
/opt/pgpro/1c-15/bin/pg_dumpall -U postgres -c | gzip > /backup/full_dump_$mydate.gz 2> /var/log/LOG_pgsql.log
find /backup/ -mindepth 1 -mtime +1100 -delete
