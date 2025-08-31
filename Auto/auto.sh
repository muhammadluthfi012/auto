#!/bin/bash
# Created By Mr-Yun1

#>> First Main Config
#Variabel
Fetch="$HOME/User/Project/Auto/script/fetch.sh"
Timeshisft="$HOME/User/Project/Auto/script/timeshift.sh"
Full="$HOME/User/Project/Auto/script/full_scan.sh"
#Pacman
MainP="$HOME/User/Project/Auto/script/Pacman/main.sh"
#Apt
MainA="$HOME/User/Project/Auto/script/Apt/main.sh"
#Void
MainX="$HOME/User/Project/Auto/script/XBPS/main.sh"


#|| Main Config Color ||
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' #No Color

#|| Main Header ||
header() {
  clear
  echo -e "${GREEN}"
  echo " ================== < +<+>+ > ==================="
  echo " |  Auto Update >> { Apt } { Pacman } { xbps } |"
  echo " ================== < +<+>+ > =================="
  echo -e "${NC}"
}

#Looping Function
ask_repeat() {
  read -p " Do You Want Repeat Again [y/N]? " repeat_choice
  repeat_choice=${repeat_choice:-N}

  if [[ "${repeat_choice,,}" =~ ^(y|yes)$ ]]; then
    return 0
  else
    if [ -f "$Fetch" ]; then
      $Fetch
    else
      echo -e "${RED} Not Found File Fetch!!!...(fetch.sh: ?)${NC}"
    fi
    return 1
  fi
}

#|| Detect Distro ||
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/void-release ]; then
        DISTRO="void"
    else
        DISTRO="unknown"
    fi
    
    case $DISTRO in
        "ubuntu" | "linuxmint" | "pop" | "elementary" | "neon" | "zorin")
            DISTRO="debian" # Pakai apt
            ;;
        "manjaro" | "endeavouros" | "garuda")
            DISTRO="arch" # Pakai pacman
            ;;
    esac
    
    echo -e "${YELLOW}Detected distro: $DISTRO${NC}"
}

#|| Main Menu ||
main_menu() {
  while true; do
    header
    echo -e "${CYAN} =<+>= Main Menu =<+>="
    echo -e " 1. APT Package(Debian)"
    echo -e " 2. Pacman Package(Arch)"
    echo -e " 3. XBPS Package(Void)"
    echo -e " 4. Timeshift"
    echo -e " 5. Full Scan"
    echo -e " 6. Exit (Press Enter or 6 to EXIT)"

    read -p " Choice option [1-6] (default 6): " menu_choice

    if [[ -z "$menu_choice" || "$menu_choice" == "6" ]]; then
      clear
      echo -e "\n${GREEN} Exiting.....${NC}"
      if [ -f $Fetch ]; then
        $Fetch
      else
        echo -e "${RED} Not Found File Fetch!!!...(fetch.sh: ?)${NC}"
      fi
      exit 0
    fi

    case $menu_choice in
      1)
        $MainA
        ;;
      2)
        $MainP
        ;;
      3)
        $MainX
        ;;
      4)
        $Timeshift
        ;;
      5)
        $Full
        ;;
      *)
        echo -e "\n${RED} Invalid Choice! Please select between 1-7${NC}"
        sleep 1
        continue
        ;;
    esac
    
    read -p " Press Enter to return to Main Menu..."
  done
}


#\
#>> End Main Config
#/

#|| Start Function ||
detect_distro
main_menu
