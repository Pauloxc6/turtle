#!/usr/bin/env bash

export RESET="\e[0m"
export RED="\e[31;1m"
export GREEN="\e[32;1m"
export YELLOW="\e[33;1m"
export BLUE="\e[34;1m"
export PURPLE="\e[35;1m"
export CYAN="\e[36;1m"
export WHITE="\e[37;1m"

readonly turtle_default="${HOME}/.local/share/turtle"
readonly bin="${HOME}/.local/bin"
readonly orm="${bin}/orm"

echo -e "${GREEN}[+]${RESET} Uninstall Turtle"

# * Verifica se existe uma instalação do Turtle

echo -e "${YELLOW}[*]${RESET} Verificando instalação atual"

if [[ ! -d "${turtle_default}" && ! -L "${orm}" ]]; then
    echo -e "${RED}[!]${RESET} Nenhuma instalação do Turtle foi encontrada"
    exit 1
fi

# * Confirma a remoção da instalação
read -rp "[?] Deseja remover o Turtle? [s/N] " sn
case "${sn,,}" in
    s|sim) echo -e "${YELLOW}[*]${RESET} Iniciando desinstalação" ;;
    n|nao|não|"") echo -e "${CYAN}[*]${RESET} Desinstalação cancelada" ; exit 0 ;;
    *) echo -e "${RED}[!]${RESET} Opção inválida" ; exit 1 ;;
esac

# * Remove o link simbólico do comando orm
if [[ -e "${orm}" || -L "${orm}" ]]; then
    echo -e "${YELLOW}[*]${RESET} Removendo link simbólico: ${orm}"
    if ! rm -f "${orm}"; then
        echo -e "${RED}[!]${RESET} Falha ao remover o link simbólico"
        exit 1
    fi
fi

# * Remove os arquivos do Turtle
if [[ -d "${turtle_default}" ]]; then
    echo -e "${YELLOW}[*]${RESET} Removendo arquivos: ${turtle_default}"
    if ! rm -rf "${turtle_default}"; then
        echo -e "${RED}[!]${RESET} Falha ao remover os arquivos do Turtle"
        exit 1
    fi
fi

# * Finaliza a desinstalação
echo -e "${GREEN}[+]${RESET} Turtle desinstalado com sucesso!"
