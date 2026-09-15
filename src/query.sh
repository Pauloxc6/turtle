#!/usr/bin/env bash

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