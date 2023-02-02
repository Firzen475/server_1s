#!/bin/bash
if [[ $(pgrep hasplm) && $(pgrep usbhasp) && $(pgrep aksusbd) ]]; then
       exit 0
fi
exit 1
