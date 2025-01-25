#!/bin/bash

#Last LTS - https://aka.ms/powershell-release?tag=lts
#Last Stable - https://aka.ms/powershell-release?tag=stable
POWERSHELL_VERSION="7.4.7"


arch=$(lscpu | grep Architecture)
if [[ $arch == *"x86_64"* ]]; then
    POWERSHELL_ARCH="x64"
elif [[ $arch == *"aarch64"* ]]; then
    POWERSHELL_ARCH="arm64"
else
    exit 1
fi

wget https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-${POWERSHELL_ARCH}.tar.gz -O powershell.tar.gz
