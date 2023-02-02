#!/bin/bash
[ -d /_1s/srvConfig/ ] || mkdir -p /_1s/srvConfig
[ -d /_1s/root_srv1s/ ] || mv ./srv1s/root_srv1s /_1s/root_srv1s
[ -d /_1s/apacheConf/ ] || mv ./srv1s/apacheConf /_1s/apacheConf
[ -d /_1s/apacheDir/ ] || mv ./srv1s/apacheDir /_1s/apacheDir

openssl req -x509 -nodes -days 4000 -newkey rsa:2048 -keyout /_1s/root_srv1s/srv1s.key -out /_1s/root_srv1s/srv1s.crt -config ./srv1s.conf
