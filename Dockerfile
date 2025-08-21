# Dockerfile

FROM debian:bullseye-slim

LABEL org.opencontainers.image.authors="Indra Wahjoedi <iw@ijoe.eu.org>"

ENV DEBIAN_FRONTEND=noninteractive

# renovate: datasource=github-releases depName=krallin/tini
ARG TINI_VERSION=0.19.0

ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV WINE_USER=wineuser
ENV WINE_UID=1000
ENV WINE_GID=1000
ENV WINEPREFIX=/home/${WINE_USER}/.wine64
ENV WINEARCH=win64
ENV DISPLAY=:0
ENV WINEDEBUG=-all
ENV XAUTHORITY=/tmp/.Xauthority

# Jelastic Compatibility
ENV WINEPRELOADER=/bin/false
ENV WINE_LARGE_ADDRESS_AWARE=
ENV WINEDLLOVERRIDES="winemenubuilder.exe=d"
ENV WINEFSYNC=0
ENV WINEESYNC=0
ENV WINELOADERNOEXEC=1

# Update sistem dan install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Tambahkan repository Wine
RUN wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" >> /etc/apt/sources.list.d/winehq.list

# Install Wine dan dependencies
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y \
        winehq-stable \
        wine64 \
        winbind \
        cabextract \
        unzip \
        p7zip \
        curl \
        xvfb \
        winbind \
        libvulkan1 \
        openssh-server \
        supervisor \
        procps \
        psmisc \
    && rm -rf /var/lib/apt/lists/*

# Download winetricks secara manual
RUN wget -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/local/bin/winetricks


# Copy dan setup fix-xvfb script
COPY fix-xvfb.sh /tmp/fix-xvfb.sh
RUN chmod +x /tmp/fix-xvfb.sh && /tmp/fix-xvfb.sh

# Buat user non-root
RUN groupadd -g ${WINE_GID} ${WINE_USER} \
    && useradd -u ${WINE_UID} -g ${WINE_GID} -m -s /bin/bash ${WINE_USER} \
    && echo "${WINE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch ke user non-root
USER ${WINE_USER}
WORKDIR /home/${WINE_USER}

# MT5
RUN curl -L -o "Pepperstone-MetaTrader-5.zip" "https://www.dropbox.com/scl/fi/3ko8xl4p9xqeuv793285j/Pepperstone-MetaTrader-5.zip?rlkey=qu18epr8d6v3daxld5y42c6dw&st=3oup3pfx&dl=1"
RUN unzip Pepperstone-MetaTrader-5.zip -d mt5

# Copy 
RUN mv mt5 /home/wineuser/.wine64/drive_c/Program\ Files/MetaTrader\ 5/

# Compile EA
# RUN wine "C:/Program Files/MetaTrader 4/metaeditor.exe" /compile:"C:/Program Files/MetaTrader 4/MQL4/Experts/HelloLogger.mq4"

# Inisialisasi Wine (tanpa GUI)
RUN wineboot --init && \
    wineserver --wait

# Copy and set entry script
COPY setup-wine.sh /app/setup-wine.sh
RUN chmod +x /app/setup-wine.sh
COPY run_mt4.sh /app/run_mt4.sh
RUN chmod +x /app/run_mt4.sh
COPY run_mt5.sh /app/run_mt5.sh
RUN chmod +x /app/run_mt5.sh

CMD /app/setup-wine.sh
#CMD ["/app/run_mt4.sh"]

ENTRYPOINT ["/tini", "--"]
CMD ["/bin/bash"]