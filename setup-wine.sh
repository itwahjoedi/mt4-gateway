#!/bin/bash

# Set registry untuk disable problematic features
wine64 reg add "HKCU\\Software\\Wine\\WineMenuBuilder" /v "Disabled" /t REG_DWORD /d 1 /f
wine64 reg add "HKCU\\Software\\Wine\\Direct3D" /v "UseGLSL" /t REG_SZ /d "disabled" /f
   

echo "Wine Version: $(wine --version 2>/dev/null || echo 'Not available')"
echo "Wine Prefix: $WINEPREFIX"
echo "Wine Arch: $WINEARCH"
echo "Display: $DISPLAY"
echo "Preloader: ${WINEPRELOADER:-default}"

