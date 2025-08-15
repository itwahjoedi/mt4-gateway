# Dockerfile
FROM debian:bookworm-slim

# Set environment variables
ENV WINEARCH=win64
ENV WINEDEBUG=-all
ENV DISPLAY=:0
ENV XAUTHORITY=/tmp/.Xauthority

# Install dependencies untuk Wine 64-bit
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wine winbind cabextract wget unzip xvfb xauth && \
    rm -rf /var/lib/apt/lists/*

# Setup Wine untuk 64-bit
RUN wine wineboot --init

# Copy MT4 installer from repository
COPY exe/mt4setup.exe /opt/mt4/mt4setup.exe

# Install MT4 using local installer
RUN mkdir -p /opt/mt4 && \
    cd /opt/mt4 && \
    xvfb-run wine mt4setup.exe /S && \
    rm mt4setup.exe

# Set working directory
WORKDIR /app

# Copy EA source
# COPY mql4 /root/.wine/drive_c/Program\ Files/MetaTrader\ 4/MQL4/

# Compile EA
# RUN wine "C:/Program Files/MetaTrader 4/metaeditor.exe" /compile:"C:/Program Files/MetaTrader 4/MQL4/Experts/HelloLogger.mq4"

# Copy and set entry script
COPY run_mt4.sh /app/run_mt4.sh
RUN chmod +x /app/run_mt4.sh

CMD ["/app/run_mt4.sh"]