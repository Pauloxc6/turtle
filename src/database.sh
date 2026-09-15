#!/usr/bin/env bash

#=====================================================
# * Seção SQLite
#=====================================================

# * Cria um banco de dados caso ele não exista

function SqliteDatabase(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome do banco de dados"
        return 1
    fi

    database_tag="sqlite"
    local database_name="$1"

    if [[ ! "$database_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome do banco de dados inválido"
        return 1
    fi

    database_file="${database_name}.db"

    if [[ ! -f "${database_file}" ]]; then
        if sqlite3 "${database_file}" .ver >/dev/null 2>&1; then
            echo "[+] Arquivo criado com sucesso"
            sqlite3 "${database_file}" "PRAGMA foreign_keys = ON;"
        else
            echo "[!] Falha ao criar o arquivo"
            exit 1
        fi
    fi

}

# * Mostra todas as tabelas disponíveis
function SqliteDatabase:readall(){
    local cmd=".tables"
    local type="${1:-json}"

    if sqlite3 "${database_file}" "${cmd}" >/dev/null 2>&1;then
        declare -a tables=( $(sqlite3 "${database_file}" "${cmd}" 2>/dev/null) )
        for tab in "${tables[@]}"; do echo "${tab}"; done
    else
        echo "[!] Não foi possivel executar a leitua de todas tabelas!"
    fi

}

function SqliteDatabase:readall.box(){

    local cmd="SELECT name FROM sqlite_schema WHERE type ='table' AND name NOT LIKE 'sqlite_%';"

    if ! sqlite3 -cmd ".headers on" -cmd ".mode box" "${database_file}" "${cmd}" 2>/dev/null;then
        echo "[!] Não foi possivel executar a leitua de todas tabelas!"
        return 1
    fi

}

# * Cria uma tabela

function SqliteDatabase:create(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da tabela!"
        return 1
    fi

    local tablename="$1"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_create="CREATE TABLE IF NOT EXISTS ${tablename} ( id INTEGER PRIMARY KEY AUTOINCREMENT );"

}

# * Apaga uma tabela

function SqliteDatabase:drop(){


    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da tabela para remover!"
        return 1
    fi

    local table="$1"
    local cmd="DROP TABLE IF EXISTS ${table}"

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if ! sqlite3 "${database_file}" "${cmd}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${table} do database ${database_file}!" && return 1
    fi

}

# * Remove um índice
function SqliteDatabase:delete.index(){

    if [[ -z "${1}" || -z "${2}" ]]; then
        echo "[!] Argumento vazio. Adicione a tabela e colomun referente ao index!"
        return 1
    fi

    if [[ ! "${1}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "${2}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    local index="${1}_${2}"
    local cmd2="DROP INDEX IF EXISTS idx_${index};"

    if ! sqlite3 "${database_file}" "${cmd2}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${index} do database ${database_file}!" && return 1
    fi

}

# * Função de checagem

function SqliteDatabase:check(){

    local check="$1"
    local check_table="$2"
    local type="${3:-json}"

    if [[ ! "$check_table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if [[ -z "${check}" || -z "${check_table}" ]]; then
        echo "[!] Argumento vazio. Adicione o parametro de checagem e a tabela"
        return 1
    fi

    case "${check}" in
        "indexs") sqlite3 "${database_file}" "PRAGMA index_list(${check_table});" ;;
        "schema") sqlite3 "${database_file}" ".schema ${check_table};" ;;
        "table-info") sqlite3 -"${type}" "${database_file}" "PRAGMA table_info(${check_table});"
    esac

}

# * Função de inserção

function SqliteDatabase:insert() {

    local table="$1"
    local column="$2"
    local value="$3"

    if [[ -z "$table" || -z "$column" || -z "$value" ]]; then
        echo "[!] Argumento vazio. Adicione os dados correspodentes para inserção!"
        return 1
    fi

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$column" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    if [[ ! "$value" =~ ^[0-9A-Za-z[:space:]]+$ ]]; then
        echo "[!] Dados incorretos"
        return 1
    fi


    # * Escapa apóstrofos para um literal de string do SQLite
    local escaped_value="${value//\'/\'\'}"
    local sql="INSERT INTO \"$table\" (\"$column\") VALUES (@value);"

    if ! sqlite3 -cmd ".parameter set @value '$escaped_value'" "$database_file" "${sql}";then
        return 1
    fi


}

function SqliteDatabase:update() {

    local table="$1"
    local column="$2"
    local value="$3"
    local where="$4"

    if [[ -z "$table" || -z "$column" || -z "$value" || -z "$where" ]]; then
        echo "[!] Argumento vazio. Adicione os dados correspodentes para inserção!"
        return 1
    fi

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ||
        ! "$column" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || 
        ! "$where" =~ ^[0-9]*$ ]]; then

        echo "[!] Nome de tabela, coluna, filtro inválido"
        return 1
    fi

    if [[ ! "$value" =~ ^[0-9A-Za-z[:space:]]+$ ]]; then
        echo "[!] Dados incorretos"
        return 1
    fi


    # * Escapa apóstrofos para um literal de string do SQLite
    local escaped_value="${value//\'/\'\'}"
    local sql="UPDATE \"$table\" SET (\"$column\") = @value WHERE id = ${where};"

    if ! sqlite3 -cmd ".parameter set @value '$escaped_value'" "$database_file" "${sql}";then
        return 1
    fi


}

function SqliteDatabase:delete() {

    local table="$1"
    local where="$2"

    if [[ -z "$table" || -z "$where" ]]; then
        echo "[!] Argumento vazio. Adicione os dados correspodentes para delete!"
        return 1
    fi

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  || ! "$where" =~ ^[0-9]*$ ]]; then
        echo "[!] Nome de tabela, filtro inválido"
        return 1
    fi

    local sql="DELETE FROM \"$table\" WHERE id = ${where};"

    if ! sqlite3 "$database_file" "${sql}";then
        return 1
    fi

}

function SqliteDatabase:select(){

    local table="$1"
    local cmd="SELECT * FROM ${table};"
    local type="${2:-json}"

    if [[ -z "$table" ]]; then
        echo "[!] Argumento vazio. Adicione a tabela para seleção!"
        return 1
    fi

    if ! sqlite3 -cmd ".headers on" -cmd ".mode ${type}" "${database_file}" "${cmd}";then
        return 1
    fi

}
