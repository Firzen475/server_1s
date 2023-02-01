#!/bin/bash

if [[ $($(find /opt/pgpro/ -name pg_isready) | grep "accepting connections") ]]; then
       exit 0
fi

exit 1







