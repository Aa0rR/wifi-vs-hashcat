#!/bin/bash


###########################################
#---------------) Colors (----------------#
###########################################
C=$(printf '\033')
RED="${C}[1;31m"
YELLOW="${C}[1;33m"

echo
if [ "$EUID" -ne 0 ]
  then 
  echo "${YELLOW}[${RED}!${YELLOW}] ${RED} Error: this script must be run as ${YELLOW}root" 
  echo "${YELLOW}[${RED}!${YELLOW}] ${RED} Re-run with ${YELLOW}sudo" 
  exit
fi
# Update the system 
apt-get update
# Intall initial packages 
apt-get install hcxdumptool git hcxtools libcurl4-openssl-dev libssl-dev zlib1g-dev libpcap-dev libssl-dev build-essential pkg-config -y

#Intall from git a specific tool
git clone https://github.com/ZerBea/hcxdumptool.git
cd hcxdumptool
make
make install
cd .. && rm -rf  hcxdumptool
