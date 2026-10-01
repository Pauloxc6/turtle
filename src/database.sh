#!/usr/bin/env bash

declare -a database_import=(
    "${rootdir}/src/database/sqlite.sh"
    "${rootdir}/src/database/mysql.sh"
)

for dblib in "${database_import[@]}";do
    if [ -d "${rootdir}" ]; then
        if [ -f "${dblib}" ]; then
            # shellcheck disable=SC1090
            source "${dblib}"
        else
            echo -e "[!] Erro ao importar ${dblib} para o programa $0!"
        fi
    fi
done
