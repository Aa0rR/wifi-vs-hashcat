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
  	tput sgr 0
} 

if [ "$EUID" -ne 0 ]
  then echo "${YELLOW}[${RED}!${YELLOW}] ${RED} Error: this script must be run as ${YELLOW}root" 
  exit
fi

echo
box "${YELLOW}[-] ${GREEN}Hi, welcome to the wifi crack tool"

echo "Select the interface"



