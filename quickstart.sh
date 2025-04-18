#!/bin/bash

# See <https://github.com/DNSCrypt/dnscrypt-proxy/releases/latest> for more info
DNSCRYPT_PLATFORM="linux"
DNSCRYPT_ARCH="x86_64"

# Remove old zapret directory if exists
if [ -d "./zapret" ]; then rm -Rf ./zapret; fi

# REMAKE быстрый фикс для 50 discord
# Скачивание zapret версии v70.5
version="v70.5"
download_url=$(curl -s "https://api.github.com/repos/bol-van/zapret/releases/tags/$version" | grep -oP '"browser_download_url": "\K.*?\.tar\.gz(?=")' | grep -v "openwrt")

if [ -z "$download_url" ]; then
    echo "Error: Не удалось найти .tar.gz архив для версии $version"
    echo "Проверьте, что версия $version существует на странице релизов: https://github.com/bol-van/zapret/releases"
    exit 1
fi

filename=$(basename "$download_url")
echo "Скачивается $download_url"
wget "$download_url"

if ! tar -xvzf "$filename"; then
    tar xvzf "$filename"
fi

# REMAKE быстрый фикс 50 discord

# Extract it
rm "$filename"
mv "./${filename%.*.*}" ./zapret

# Check
if [ ! -d "./zapret" ]; then
    echo "Error downloading or extracting zapret binaries"
    exit 1
fi

# Remove old dnscrypt-proxy directory if exists
if [ -d "./dnscrypt-proxy" ]; then rm -Rf ./dnscrypt-proxy; fi

# Download dnscrypt-proxy
download_url=$(curl -s https://api.github.com/repos/DNSCrypt/dnscrypt-proxy/releases/latest | grep -oP '"browser_download_url": "\K.*?\.tar\.gz(?=")' | grep -oE ".*dnscrypt-proxy-${DNSCRYPT_PLATFORM}_${DNSCRYPT_ARCH}-.*\.tar\.gz")
if [ -z "$download_url" ]; then
    echo "Error: Unable to find .tar.gz asset in the latest release of dnscrypt-proxy for ${DNSCRYPT_PLATFORM} ${DNSCRYPT_ARCH}"
    exit 1
fi
filename=$(basename "$download_url")
echo "Downloading $download_url"
wget "$download_url"
if ! tar -xvzf "$filename"; then
    tar xvzf "$filename"
fi

# Extract it
rm "$filename"
mv "./${DNSCRYPT_PLATFORM}-${DNSCRYPT_ARCH}" ./dnscrypt-proxy

# Check
if [ ! -d "./dnscrypt-proxy" ]; then
    echo "Error downloading or extracting dnscrypt-proxy binaries"
    exit 1
fi

# Start build script
./start.sh
