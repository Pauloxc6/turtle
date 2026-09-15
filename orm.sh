#!/usr/bin/env bash

#================================
# * Imports
#================================

# shellcheck disable=SC2155
readonly rootdir="$(cd -- "$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

declare -a libs=(
    "${rootdir}/src/misc.sh"
    "${rootdir}/src/database.sh"
    "${rootdir}/src/model.sh"
    "${rootdir}/src/query.sh"
)

for lib in "${libs[@]}";do
    if [ -d "${rootdir}" ]; then
        if [ -f "${lib}" ]; then
            # shellcheck disable=SC1090
            source "${lib}"
        else
            echo -e "[!] Erro ao importar ${lib} para o programa $0!"
        fi
    fi
done

#================================
# * Variáveis
#================================

export LANG=C
export LC_ALL=C

#================================
# * Funções
#================================

#=================================
# * Verificações
#=================================

#=================================
# * Parser
#=================================

while [[ $# -gt 0 ]]; do

    case "$1" in
        --help) __help ;;
        --version) __version_banner ;;
        --debug) debug ;;
        *) echo -e "[!] Comando $1 não encontrado na lista!${RESET}"; exit 1 ;;
    esac
    shift
done

#==================================
# * Main
#==================================
