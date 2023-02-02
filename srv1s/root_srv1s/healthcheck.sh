#!/bin/bash
if [[ $(pgrep apache2) && $(pgrep ragent) && $(pgrep rmngr) ]]; then
       exit 0
fi
exit 1








