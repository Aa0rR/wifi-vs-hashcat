#!/bin/bash

###########################################
#---------------) Colors (----------------#
###########################################

C=$(printf '\033')
RED="${C}[1;31m"
SED_RED="${C}[1;31m&${C}[0m"
GREEN="${C}[1;32m"
SED_GREEN="${C}[1;32m&${C}[0m"
YELLOW="${C}[1;33m"
SED_YELLOW="${C}[1;33m&${C}[0m"
SED_RED_YELLOW="${C}[1;31;103m&${C}[0m"
BLUE="${C}[1;34m"
SED_BLUE="${C}[1;34m&${C}[0m"
ITALIC_BLUE="${C}[1;34m${C}[3m"
LIGHT_MAGENTA="${C}[1;95m"
SED_LIGHT_MAGENTA="${C}[1;95m&${C}[0m"
LIGHT_CYAN="${C}[1;96m"
SED_LIGHT_CYAN="${C}[1;96m&${C}[0m"
LG="${C}[1;37m" #LightGray
SED_LG="${C}[1;37m&${C}[0m"
DG="${C}[1;90m" #DarkGray
SED_DG="${C}[1;90m&${C}[0m"
NC="${C}[0m"
UNDERLINED="${C}[5m"
ITALIC="${C}[3m"
  
###########################################


function box () {
	local s=("$@") b w
  	for l in "${s[@]}"; do
    		((w<${#l})) && { b="$l"; w="${#l}"; }
  	done
  	tput setaf 3
	echo "${GREEN}"
  	echo " -${b//?/-}-
| ${b//?/ } |"
  	for l in "${s[@]}"; do
		echo "${GREEN}"
    	printf '| %s%*s%s \n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  	done
	echo "${GREEN}"
  	echo "| ${b//?/ } |
 -${b//?/-}-"
  	tput sgr 0m
  	echo
} 
echo
echo "${RED}
              @@@  @@@  @@@ @@@ @@@@@@@@ @@@      @@@  @@@  @@@@@@
              @@!  @@!  @@! @@! @@!      @@!      @@!  @@@ !@@    
              @!!  !!@  @!@ !!@ @!!!:!   !!@      @!@  !@!  !@@!! 
               !:  !!:  !!  !!: !!:      !!:       !: .:!      !:!
                ::.:  :::   :    :       :           ::    ::.: : 
                                                                  
          @@@  @@@  @@@@@@   @@@@@@ @@@  @@@  @@@@@@@  @@@@@@  @@@@@@@
          @@!  @@@ @@!  @@@ !@@     @@!  @@@ !@@      @@!  @@@   @@!  
          @!@!@!@! @!@!@!@!  !@@!!  @!@!@!@! !@.      @!@!@!@!   @!!  
          !!:  !.! !!:  !!!     !:! !!:  !!! :!!      !!:  !.!   !!.  
           :   : :  :   : : ::.: :   :   : :  :: :: :  :   : :    :   
                                                                      

" | sed "s/^/`echo $YELLOW`/" | sed "s/\!/`echo $RED`\!`echo $YELLOW`/g" | sed "s/:/`echo $RED`:`echo $YELLOW`/g"
echo
if [ "$EUID" -ne 0 ]
  then 
  echo "${YELLOW}[${RED}!${YELLOW}] ${RED} Error: this script must be run as ${YELLOW}root" 
  echo "${YELLOW}[${RED}!${YELLOW}] ${RED} Re-run with ${YELLOW}sudo" 
  exit
fi

#Instead of save all the files in the current directory copy all the caputerd file in an external drive
now=$(date +"%Y-%m-%d-%H:%M")
EXTERNALPATH=/media/pi/USB/$now-capture


# Select automatically the realtec interface (wlan1)
echo ${NC}

systemctl stop NetworkManager.service
systemctl stop wpa_supplicant.service

# Set the adapter as monitor mode
ip link set wlan1 down
iw dev wlan1 set type monitor
ip link set wlan1 up
iw wlan1 set txpower fixed 3000

echo
box "${YELLOW}[-] ${GREEN} Let's dump of the wifi networks. Press ${YELLOW}CTRL-C${GREEN} when you have finished"

mkdir $now-capture
hcxdumptool -i wlan1 -o $EXTERNALPATH/$now.pcapng --active_beacon --tot=120 -enable_status=15

echo
box "${YELLOW}[-] ${GREEN} Let's decypt the captured pcap file"
hcxpcapngtool -o $EXTERNALPATH/$now.hc22000 -E $EXTERNALPATH/essidlist$now $EXTERNALPATH/$now.pcapng


box "${YELLOW}[-] ${GREEN} DONE!"
