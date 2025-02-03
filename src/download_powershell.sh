#!/bin/bash

#Last LTS - https://aka.ms/powershell-release?tag=lts
#Last Stable - https://aka.ms/powershell-release?tag=stable


POWERSHELL_VERSION="7.4.7"


if [ "$1" == "--alpine" ]; then
    POWERSHELL_PLATAFORM="linux-musl"
    POWERSHELL_ARCH="x64"
else
    POWERSHELL_PLATAFORM="linux"

    arch=$(lscpu | grep Architecture)
    if [[ $arch == *"x86_64"* ]]; then
        POWERSHELL_ARCH="x64"
    elif [[ $arch == *"aarch64"* ]]; then
        POWERSHELL_ARCH="arm64"
    else
        exit 1
    fi
fi

URL="https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-${POWERSHELL_PLATAFORM}-${POWERSHELL_ARCH}.tar.gz"

wget ${URL} -O powershell.tar.gz
