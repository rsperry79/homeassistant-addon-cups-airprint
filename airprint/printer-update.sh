#!/usr/bin/env bash

/usr/bin/inotifywait -m -e close_write,moved_to,create /etc/cups |
    while read -r directory events filename; do
        if [ "$filename" = "printers.conf" ]; then
            rm -f /etc/avahi/services/AirPrint-*.service
            /opt/airprint/airprint-generate.py /root/airprint-generate.py --host=127.0.0.1 --port=631 --directory=/config/avahi/services/ --prefix=AirPrint-
        fi
    done
/opt/airprint/airprint-generate.py -
