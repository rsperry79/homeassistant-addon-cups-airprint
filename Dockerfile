ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:8.1.4
FROM $BUILD_FROM

LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Optimize APT for faster, smaller builds
RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99no-recommends \
    && echo 'APT::Get::Clean "always";' >> /etc/apt/apt.conf.d/99auto-clean \
    && echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' >> /etc/apt/apt.conf.d/99auto-clean

RUN apt update \
    && apt upgrade -y --no-install-recommends \
    && apt install -y --no-install-recommends \
        # System packages
        sudo \
        locales \
        whois \
        bash-completion \
        procps \
        lsb-release \
        nano \
        gnupg2 \
        inotify-tools \
        # CUPS printing packages
        cups \
        cups-filters \
        cups-pdf \
        colord \
        python3-cups \
        cups-tea4cups \
        # Network
        avahi-utils \
        libnss-mdns \
        dbus \
        samba \
        samba-client \
        # Printer Drivers
        printer-driver-all-enforce \
        printer-driver-all \
        printer-driver-splix \
        printer-driver-brlaser \
        printer-driver-gutenprint \
        openprinting-ppds \
        hpijs-ppds \
        hp-ppd  \
        hplip \
        printer-driver-foo2zjs \
        printer-driver-hpcups \
        printer-driver-escpr \

    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

# Add Canon cnijfilter2 driver
RUN cd /tmp \
  && if [ "$(arch)" = 'x86_64' ]; then ARCH="amd64"; else ARCH="arm64"; fi \
  && curl https://gdlp01.c-wss.com/gds/0/0100012300/02/cnijfilter2-6.80-1-deb.tar.gz -o cnijfilter2.tar.gz \
  && tar -xvf ./cnijfilter2.tar.gz cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_${ARCH}.deb \
  && mv cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_${ARCH}.deb cnijfilter2_6.80-1.deb \
  && apt install ./cnijfilter2_6.80-1.deb

COPY rootfs /

RUN dpkg -i /drivers/mfc9970cdwlpr-1.1.1-5.i386.deb \
  && dpkg -i /drivers/mfc9970cdwlpr-1.1.1-5.i386.deb
# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

RUN chmod a+x /run.sh

HEALTHCHECK \
    CMD curl --fail http://127.0.0.1:631/ || exit 1
