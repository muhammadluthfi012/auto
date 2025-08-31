#!/bin/sh
# Author: Mr-Yun1

# Warna
CYAN='\033[0;36m'
NC='\033[0m'

# Spinner karakter (string, bukan array)
spin_chars='-\|/'

# Fungsi Spinner
spinner() {
    i=0
    while kill -0 "$1" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        char=$(printf "%s" "$spin_chars" | cut -c$((i+1)))
        printf "\r${CYAN}%s ${char}${NC}" "$2"
        sleep 0.1
    done
}

# Contoh penggunaan: Full Scan simulasi
echo "Starting full scan..."
(sleep 5) &  # proses dummy (simulasi scan 5 detik)
pid=$!

spinner $pid "Scanning system"

wait $pid
printf "\r${CYAN}Scan completed!   ${NC}\n"

