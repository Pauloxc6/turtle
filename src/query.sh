#!/usr/bin/env bash

# * Função de busca personalizada

function SqliteDatabase:query(){
    
    local query=$(cat)
    local type="${1:-json}"

    if [[ -z "${query}" ]]; then
        echo "[!] Query inválido"
        return 1
    fi

    if ! sqlite3 -"${type}" "${database_file}" "${query}";then
        return 1
    fi
}

function MysqlDatabase:query(){
    
    local query=$(cat)

    if [[ -z "${query}" ]]; then
        echo "[!] Query inválido"
        return 1
    fi

    if ! MYSQL_PWD="${pass}" mysql --xml -h "${mysql_host}" -u "${user}" -e "${query}" 2>/dev/null | xmltojson;then
        return 1
    fi
}