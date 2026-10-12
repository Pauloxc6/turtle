#!/usr/bin/env bash

#=====================================================
# * Seção Postgresql
#=====================================================

# * Cria um banco de dados caso ele não exista
function PostgresDatabase(){

    user="$2"
    pass="$3"
    postgresql_host="${6:-127.0.0.1}"

    root_user="${4:root}"
    root_pass="${5}"

    declare -a args=(
        user
        pass
        postgresql_host
    )

    for arg in "${args[@]}";do 
        if [[ -z "${arg}" ]]; then
            echo "[!] Argumento vazio. | ${arg}"
            return 1
        fi
    done

    database_tag="postgresql"
    pdatabase_name="$1"

    local query_database="CREATE DATABASE ${pdatabase_name};"
    local query_user="CREATE USER ${user} WITH PASSWORD '${pass}'; ALTER DATABASE ${pdatabase_name} OWNER TO ${user};"

    if [[ ! "$pdatabase_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome do banco de dados inválido"
        return 1
    fi

    if PGPASSWORD="${root_pass}" psql -h "${postgresql_host}" -U "${root_user}" -c "${query_database}" >/dev/null 2>&1; then
        echo "[+] Banco de dados criado com sucesso"
    else
        echo "[!] Falha ao criar o banco de dados"
        exit 1
    fi

    if PGPASSWORD="${root_pass}" psql -h "${postgresql_host}" -U "${root_user}" -c "${query_user}" >/dev/null 2>&1; then
        echo "[+] User criado com sucesso"
    else
        echo "[!] Falha ao criar o user"
        exit 1
    fi
}

# * Mostra todas as tabelas disponíveis
function PostgresDatabase:readall(){
    
    local cmd="\dt+;"

    if ! PGPASSWORD="${pass}" psql --csv -h "${postgresql_host}" -U "${user}" -d "${pdatabase_name}" -c "${cmd}" 2>/dev/null;then
        echo "[!] Não foi possivel executar a leitua de todas tabelas!"
    fi

}

# * Cria uma tabela
function PostgresDatabase:create(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da tabela!"
        return 1
    fi

    local tablename="$1"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_create="CREATE TABLE IF NOT EXISTS ${tablename} ( id SERIAL PRIMARY KEY )"

}

# * Apaga uma tabela
function PostgresDatabase:drop(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da tabela para remover!"
        return 1
    fi

    local table="$1"
    local cmd="DROP TABLE IF EXISTS ${table};"

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "${user}" -d "${pdatabase_name}" -c "${cmd}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${table} do database ${pdatabase_name}!" && return 1
    fi

}

# * Apaga um banco de dados
function PostgresDatabase:drop.database(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da banco de dados para remover!"
        return 1
    fi

    local data="$1"
    local cmd="DROP DATABASE IF EXISTS ${data};"

    if [[ ! "$data" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if ! PGPASSWORD="${root_pass}" psql -h "${postgresql_host}" -U "${root_user}" -c "${cmd}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${data} do database ${database_file}!" && return 1
    fi

}

# * Apaga um usuário
function PostgresDatabase:drop.user(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da banco de dados para remover!"
        return 1
    fi

    local userdelete="$1"
    local cmd="SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${pdatabase_name}' AND pid <> pg_backend_pid(); REASSIGN OWNED BY ${user} TO ${root_user}; ALTER DATABASE ${pdatabase_name} OWNER TO ${root_user}; DROP OWNED BY ${userdelete} CASCADE; DROP USER IF EXISTS ${userdelete};"

    if [[ ! "$userdelete" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if ! PGPASSWORD="${root_pass}" psql -h "${postgresql_host}" -U "${root_user}" -d "${pdatabase_name}" -c "${cmd}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${userdelete} do database ${database_file}!" && return 1
    fi

}

# * Apaga um index
function PostgresDatabase:delete.index(){

    local table="$1"

    if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then
        echo "[!] Argumento vazio. Adicione a tabela e colomun referente ao index!"
        return 1
    fi

    if [[ ! "${1}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "${2}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "${3}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    local index="${2}_${3}"
    local cmd2="DROP INDEX idx_${index};"

    if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "$user" -d "${pdatabase_name}" -c "${cmd2}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${index} do database ${database_file}!" && return 1
    fi

}

# * Função de checagem
function PostgresDatabase:check(){

    local check="$1"
    local check_table="$2"

    if [[ ! "$check_table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if [[ -z "${check}" || -z "${check_table}" ]]; then
        echo "[!] Argumento vazio. Adicione o parametro de checagem e a tabela"
        return 1
    fi

    case "${check}" in
        "schema")       PGPASSWORD="${pass}" psql --csv -h "${postgresql_host}" -U "${user}" "${pdatabase_name}" -c "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = '${check_table}';" ;;
        "indexs")       PGPASSWORD="${pass}" psql --csv -h "${postgresql_host}" -U "${user}" "${pdatabase_name}" -c "SELECT indexname, indexdef FROM pg_indexes WHERE tablename = '${check_table}';"   ;;
        "table-info")   PGPASSWORD="${pass}" psql --csv -h "${postgresql_host}" -U "${user}" "${pdatabase_name}" -c "SELECT pg_size_pretty(pg_total_relation_size('${check_table}'));"          ;;
    esac

}

# * Função de inserção e atualização
function PostgresDatabase:insert() {

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
    local sql="PREPARE insert_data (unknown) AS INSERT INTO ${table} (${column}) VALUES (\$1); EXECUTE insert_data(${escaped_value});"

    if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "${user}" -d "${pdatabase_name}" -c "${sql}" >/dev/null 2>&1;then
        return 1
    fi

}

function PostgresDatabase:update() {

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

    if [[ ! "$value" =~ ^[0-9A-Za-z:[:space:]-]+$ ]]; then
        echo "[!] Dados incorretos"
        return 1
    fi


    # * Escapa apóstrofos para um literal de string do SQLite
    local escaped_value="${value//\'/\'\'}"
    local sql="PREPARE insert_data (unknown) AS UPDATE $table SET $column = \$1 WHERE id = ${where}; EXECUTE insert_data('${escaped_value}')"

    if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "${user}"  -d "${pdatabase_name}" -c "${sql}" >/dev/null 2>&1;then
        return 1
    fi


}

# * Função de deletar um resgistro
function PostgresDatabase:delete() {

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

    local sql="DELETE FROM $table WHERE id = ${where};"

    if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "$user" -d "${pdatabase_name}" -c "${sql}" >/dev/null 2>&1;then
        return 1
    fi

}

# * Função de seleção de tudo
function PostgresDatabase:select(){

    local table="$1"
    local type="$2"
    local cmd="SELECT * FROM ${table};"

    if [[ -z "$table" ]]; then
        echo "[!] Argumento vazio. Adicione a tabela para seleção!"
        return 1
    fi

    case "${type,,}" in
        csv)
            if ! PGPASSWORD="${pass}" psql --csv -h "${postgresql_host}" -U "$user" -d "${pdatabase_name}" -c "${cmd}" 2>/dev/null;then return 1 ; fi        ;;
        *)
            if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "$user" -d "${pdatabase_name}" -c "${cmd}" 2>/dev/null;then return 1 ; fi ;;
    esac
}

# * Função de seleção pelo id
function PostgresDatabase:get(){

    local table="$1"
    local where="${2:-1}"
    local type="${3}"
    local cmd="SELECT * FROM ${table} WHERE id = ${where};"

    if [[ -z "$table" || -z "$where" ]]; then
        echo "[!] Argumento vazio. Adicione a tabela e coluna para seleção!"
        return 1
    fi

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  || ! "$where" =~ ^[0-9]*$ ]]; then
        echo "[!] Nome de tabela, filtro inválido"
        return 1
    fi

    case "${type,,}" in
        csv)
            if ! PGPASSWORD="${pass}" psql--csv -h "${postgresql_host}" -U "$user" -d "${pdatabase_name}" -c "${cmd}" 2>/dev/null;then return 1 ; fi ;;
        *)
            if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "$user" -d "${pdatabase_name}" -c "${cmd}";then return 1 ; fi      ;;
    esac
}   
