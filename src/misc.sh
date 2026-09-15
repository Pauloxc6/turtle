#!/usr/bin/env bash

#=================================
# * General
#==================================

export NULL="2>/dev/null"

#=================================
# * Cores
#=================================

export RESET="\e[0m"
export RED="\e[31;1m"
export GREEN="\e[32;1m"
export YELLOW="\e[33;1m"
export BLUE="\e[34;1m"
export PURPLE="\e[35;1m"
export CYAN="\e[36;1m"
export WHITE="\e[37;1m"

#=================================
# * Version
#=================================

function __version_banner(){
    cat <<EOF
  _____     ____
 /      \  |  o | 
|        |/ ___\| 
|_________/     
|_|_| |_|_|

Turtle ORM | V: v1.0
By: @Pauloxc6
EOF

}

#=================================
# * Help
#=================================
function __help() {

    __version_banner

    cat <<HELP

Help:
    --help      | Exibe menu de Ajuda
    --version   | Exite a versão atual
    --debug     | Ativa o modo de depuração

HELP

exit 0

}

#=================================
# * Debug
#=================================

function debug(){
    # shellcheck disable=SC2329
    function cleanup(){
        set +x
        echo -e "${WHITE}[${BLUE}DEBUG${WHITE}](${CYAN}$(date +'%T / %F')${WHITE}) ${BLUE}Finalizando depuração!${RESET}"
    }

    echo -e "${WHITE}[${BLUE}DEBUG${WHITE}](${CYAN}$(date +'%T / %F')${WHITE}) ${BLUE}Inicinado depuração!${RESET}"

    echo -ne "${YELLOW}"

    set -x

    trap cleanup EXIT
}
