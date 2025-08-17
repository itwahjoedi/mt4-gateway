#!/bin/bash

# Script instalasi Wine untuk MetaTrader 5 (64-bit) mode headless
# Tested on Ubuntu 20.04/22.04 LTS
# Pastikan dijalankan sebagai user biasa (bukan root)

# Nonaktifkan prompt GUI dan interaksi selama instalasi
export DEBIAN_FRONTEND=noninteractive
export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEDEBUG=-all
export WINEARCH=win64
export WINEPREFIX="$HOME/.mt5-wine"

# Enable 32-bit architecture
sudo dpkg --add-architecture i386

# Tambah repository WineHQ
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# Dapatkan versi Ubuntu
UBUNTU_VERSION=$(lsb_release -sc)

# Tambah sources list (support multi-version)
sudo wget -qNP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_VERSION}/winehq-${UBUNTU_VERSION}.sources"

# Update dan instal dependensi
sudo apt -qq update
sudo apt -y install --install-recommends winehq-staging winetricks

# Instal libraries pendukung
sudo apt -y install \
libgnutls30:i386 \
libldap-2.4-2:i386 \
libgpg-error0:i386 \
libxml2:i386 \
libasound2-plugins:i386 \
libsdl2-2.0-0:i386 \
libfreetype6:i386 \
libdbus-1-3:i386 \
libsqlite3-0:i386

# Buat Wine prefix
wineboot -u -f 2>&1 | grep -v "wine:"

# Download winetricks config
wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks

# Instal komponen pendukung secara headless
./winetricks -q --force \
corefonts \
d3dcompiler_47 \
directplay \
dxvk \
gdiplus \
msxml3 \
msxml6 \
vcrun2019 \
dotnet48 \
win10 > /dev/null 2>&1

# Konfigurasi tambahan untuk headless
wine reg add 'HKEY_CURRENT_USER\Control Panel\Desktop' /v LogPixels /t REG_DWORD /d 120 /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d10core /t REG_SZ /d disabled /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /t REG_SZ /d disabled /f

# Bersihkan cache
rm -f winetricks
wine wineboot -e

# Selesai
echo -e "\n\e[32mInstalasi selesai!\e[0m"
echo "Wine prefix: $HOME/.mt5-wine"
echo -e "\nUntuk menjalankan MT5:"
echo "1. Download installer: wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
echo "2. Install: wine mt5setup.exe"
echo "3. Jalankan: wine '$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe'"

# 