#!/bin/bash

# Zig Color

# Pink-Purple Gradient Colors
PINK='\033[38;5;205m'
PINK2='\033[38;5;204m'
PINK3='\033[38;5;207m'
PURPLE='\033[38;5;141m'
PURPLE2='\033[38;5;135m'
PURPLE3='\033[38;5;129m'
DARK_PURPLE='\033[38;5;93m'

# Color Base
WHITE='\033[1;37m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to create gradient effect
gradient_text() {
    local text="$1"
    local colors=("$PINK" "$PINK2" "$PINK3" "$PURPLE" "$PURPLE2" "$PURPLE3" "$DARK_PURPLE")
    local length=${#text}
    local color_step=$(( length / ${#colors} ))
    local output=""
    
    for (( i=0; i<${#text}; i++ )); do
        local color_idx=$(( i / color_step ))
        [[ $color_idx -ge ${#colors} ]] && color_idx=$(( ${#colors} - 1 ))
        output+="${colors[$color_idx]}${text:$i:1}"
    done
    
    echo -e "${output}${NC}"
}


# Battery Health Function
battery_health() {
    BAT_PATH="/sys/class/power_supply/BAT0"
    if [ -d "$BAT_PATH" ]; then
        design=$(cat "$BAT_PATH/charge_full_design" 2>/dev/null || cat "$BAT_PATH/energy_full_design")
        full=$(cat "$BAT_PATH/charge_full" 2>/dev/null || cat "$BAT_PATH/energy_full")
        if [ -n "$design" ] && [ -n "$full" ]; then
            health=$(( 100 * full / design ))
            echo -e "${GREEN}$health% (Full: $full / Design: $design)"
        else
            echo -e "${YELLOW}Tidak dapat membaca kapasitas."
        fi
    else
        echo -e "${RED}Baterai tidak ditemukan."
    fi
}

# Get system information
OS=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
PKG_MANAGER=""
RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/Mem:/ {print $3}')
CPU=$(grep 'model name' /proc/cpuinfo | head -n1 | cut -d':' -f2 | sed 's/^[ \t]*//')
GPU=$(lspci | grep -i 'vga\|3d\|2d' | cut -d':' -f3 | xargs | head -n1)
SHELL=$(basename "$SHELL")
BATTERY_HEALTH=$(battery_health)

# Screen resolution detection
if [ -x "$(command -v xrandr)" ]; then
    RESOLUTION=$(xrandr | grep '*' | awk '{print $1}')
elif [ -x "$(command -v swaymsg)" ]; then
    RESOLUTION=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .current_mode.width + "x" + .current_mode.height')
else
    RESOLUTION="Unknown"
fi

# IP Detection
IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
if [ -z "$IP" ]; then
    IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi
if [ -z "$IP" ]; then
    IP="Not connected"
fi

# Storage Information
get_storage() {
    local mount_point=$1
    df -h $mount_point 2>/dev/null | awk 'NR==2 {print $3"/"$2" ("$5")"}'
}

ROOT_STORAGE=$(get_storage /)
HOME_STORAGE=$(get_storage /home)
EXTEND_STORAGE=$(get_storage /home/Extend)

# Detect package manager
if [ -x "$(command -v apt)" ]; then
    PKG_MANAGER="apt ($(apt list --installed 2>/dev/null | wc -l) packages)"
elif [ -x "$(command -v pacman)" ]; then
    PKG_MANAGER="pacman ($(pacman -Q | wc -l) packages)"
elif [ -x "$(command -v dnf)" ]; then
    PKG_MANAGER="dnf ($(dnf list installed | wc -l) packages)"
elif [ -x "$(command -v yum)" ]; then
    PKG_MANAGER="yum ($(yum list installed | wc -l) packages)"
elif [ -x "$(command -v zypper)" ]; then
    PKG_MANAGER="zypper ($(zypper se -i | wc -l) packages)"
else
    PKG_MANAGER="Unknown"
fi

# Clear Screen Before Display
clear


echo -e "${PINK2} ............................................   ${PINK}╭────────────────────────────────────────────╮"
echo -e " .......... .:@@= ...........................   │     $(gradient_text "✧･ﾟ: *✧･ﾟ:* SYSTEM INFO *:･ﾟ✧*:･ﾟ✧")     │"
echo -e " ........ :%% . %%%%% ......... %%%% ........   ╰────────────────────────────────────────────╯${NC}"
echo -e " ....... %= ..... %%%%.........%%% ..........     ${PURPLE}[+] OS : $OS"
echo -e " ...... % ........ %%%........%%% ...........     ${PURPLE}[+] Hostname : $HOSTNAME"
echo -e " ..... %% ........ %%%.......%%% ............     ${PURPLE}[+] Packages : $PKG_MANAGER"
echo -e " ..... %% ........ %%%.......%% .............     ${PURPLE2}[+] Kernel : $KERNEL"
echo -e " ...... %%%  @ .. %%%.......%%% .............     ${PURPLE2}[+] Shell : $SHELL"
echo -e " ................ %%%......%%% ..............     ${PURPLE2}[+] Resolution : $RESOLUTION"
echo -e " ............... %%%.......%%= ..............     ${PURPLE3}[+] Ram : $RAM_USED/$RAM_TOTAL"
echo -e " ............... %%%......%%% ...............     ${PURPLE3}[+] CPU : $CPU"
echo -e " ............... %%%....%@%% ................     ${PURPLE3}[+] GPU : $GPU"
echo -e " ................ %#%%%#.%%@ ................     ${PINK2}[+] IP : $IP"
echo -e " ...................... %%% .................     ${PINK3}[+] Root-Storage : ${ROOT_STORAGE:-Not available}"
echo -e " ..................... %%% ..................     ${PINK3}[+] Home-Storage : ${HOME_STORAGE:-Not available}"
echo -e " ......... +%%%: .... %%% ...................     ${PINK3}[+] Extend-Storage : ${EXTEND_STORAGE:-Not available}"
echo -e " ......... %%% ..... %%% ....................     ${PINK3}[!] I USE VOID BTW!🐧🤫"
echo -e " ......... %%% ... +%% ......................     ${PINK2}[!] I AM User SanYun OS❄️ "
echo -e " ............ %%%%% .........................     ${RUST_LIGHT_GRAY}[!] Battery Health🔋 : $BATTERY_HEALTH ${PINK2}"
echo -e " ............................................   ╰────────────────────────────────────────────╯${NC}"

