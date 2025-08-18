# Dockerfile

FROM debian:bullseye-slim

LABEL org.opencontainers.image.authors="Indra Wahjoedi <iw@ijoe.eu.org>"

ENV DEBIAN_FRONTEND=noninteractive

# renovate: datasource=github-releases depName=krallin/tini
ARG TINI_VERSION=0.19.0

ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Set environment variables
ENV WINEARCH=win64
ENV WINEPREFIX=~/.wine64
ENV WINEDEBUG=-all
ENV DISPLAY=:0
ENV XAUTHORITY=/tmp/.Xauthority

# Install dependencies untuk Wine 64-bit
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl gnupg ca-certificates

# 2. Tambahkan repositori WineHQ
RUN curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /usr/share/keyrings/winehq.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/winehq.gpg] https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/winehq.list

# 3. Install Wine (64-bit only)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        winehq-staging && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



#RUN dpkg --add-architecture i386 && \
#  apt-get update -y && \
#  apt-get install -y --no-install-recommends \
#    ca-certificates \
#    curl \
#    libvulkan1 \
#    unzip \
#    xauth \
#    xvfb \
#    wget \
#   winbind \
#   cabextract && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/*


# Setup Wine untuk 64-bit
#RUN wine wineboot --init

# Copy MT4 installer from repository
#COPY exe/mt4setup.exe /opt/mt4/mt4setup.exe

# Install MT4 using local installer
#RUN mkdir -p /opt/mt4 && \
#    cd /opt/mt4 && \
#    xvfb-run wine mt4setup.exe /S && \
#    rm mt4setup.exe

# Set working directory
#WORKDIR /app

# Copy EA source
# COPY mql4 /root/.wine/drive_c/Program\ Files/MetaTrader\ 4/MQL4/

# Compile EA
# RUN wine "C:/Program Files/MetaTrader 4/metaeditor.exe" /compile:"C:/Program Files/MetaTrader 4/MQL4/Experts/HelloLogger.mq4"

# Copy and set entry script
#COPY run_mt4.sh /app/run_mt4.sh
#RUN chmod +x /app/run_mt4.sh

#CMD ["/app/run_mt4.sh"]


#ARG WINE_FLAVOUR=staging

#RUN \
#	/tmp/fix-xvfb.sh \
#	&& sed -i '/^Enabled:/ s/no/yes/' /etc/apt/sources.list.d/* \
#	&& apt-get update -y \
#	&& apt-get install -y --no-install-recommends \
#		winehq-${WINE_FLAVOUR} \
#	&& apt-get clean \
#	&& rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/tini", "--"]
CMD ["/bin/bash"]