#!/usr/bin/env bashio


# bashio::log.info "Preparing directories"
# ps /etc/cups
# if [ ! -d /config/cups ]; then cp -v -R /etc/cups /config; fi
# ln -v -s /config/cu
bashio::log.info "Starting CUPS server as CMD from docker"

cupsd -f
