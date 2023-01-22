#!/bin/bash
mydate=$(date '+%Y_%m_%d_%H_%M_%S')
/opt/pgpro/1c-15/bin/pg_dumpall -U postgres > /backup/full_dump_$mydate.sql 2> /var/log/pg_dumpall.log
find /backup/ -mindepth 1 -mtime +1100 -delete
