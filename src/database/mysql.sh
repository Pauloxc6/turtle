#!/usr/bin/env bash

#=====================================================
# * Seção MySQL
#=====================================================

# * Cria um banco de dados caso ele não exista
function MysqlDatabase(){

    user="$2"
    pass="$3"
    mysql_host="${6:-127.0.0.1}"

    root_user="${4:root}"
    root_pass="${5}"

    declare -a args=(
        user
        pass
        mysql_host
    )

    for arg in "${args[@]}";do 
        if [[ -z "${arg}" ]]; then
            echo "[!] Argumento vazio. | ${arg}"
            return 1
        fi
    done

    database_tag="mysql"
    mdatabase_name="$1"

    local query_database="CREATE DATABASE IF NOT EXISTS ${mdatabase_name};"
    local query_user="CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}' ; GRANT ALL PRIVILEGES ON ${mdatabase_name}.* TO '${user}'@'%'; FLUSH PRIVILEGES;"

    if [[ ! "$mdatabase_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome do banco de dados inválido"
        return 1
    fi

    if MYSQL_PWD="${root_pass}" mariadb -h "${mysql_host}" -u "${root_user}" -e "${query_database}" >/dev/null 2>&1; then
        echo "[+] Banco de dados criado com sucesso"
    else
        echo "[!] Falha ao criar o banco de dados"
        exit 1
    fi

    if MYSQL_PWD="${root_pass}" mariadb -h "${mysql_host}" -u "${root_user}" -e "${query_user}" >/dev/null 2>&1; then
        echo "[+] User criado com sucesso"
    else
        echo "[!] Falha ao criar o user"
        exit 1
    fi
}

# * Mostra todas as tabelas disponíveis
function MysqlDatabase:readall(){
    
    local cmd="use ${mdatabase_name}; SHOW TABLES;"

    if ! MYSQL_PWD="${pass}" mariadb --xml -h "${mysql_host}" -u "${user}" -e "${cmd}" 2>/dev/null | xmltojson;then
        echo "[!] Não foi possivel executar a leitua de todas tabelas!"
    fi

}

# * Cria uma tabela
function MysqlDatabase:create(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da tabela!"
        return 1
    fi

    local tablename="$1"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_create="USE ${mdatabase_name}; CREATE TABLE IF NOT EXISTS ${tablename} ( id INT PRIMARY KEY AUTO_INCREMENT );"

}

# * Apaga uma tabela
function MysqlDatabase:drop(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da tabela para remover!"
        return 1
    fi

    local table="$1"
    local cmd="USE ${mdatabase_name}; DROP TABLE IF EXISTS ${table}"

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${cmd}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${table} do database ${database_file}!" && return 1
    fi

}

# * Apaga um banco de dados
function MysqlDatabase:drop.database(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da banco de dados para remover!"
        return 1
    fi

    local data="$1"
    local cmd="DROP DATABASE IF EXISTS ${data}"

    if [[ ! "$data" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if ! MYSQL_PWD="${root_pass}" mariadb -h "${mysql_host}" -u "${root_user}" -e "${cmd}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${data} do database ${database_file}!" && return 1
    fi

}

# * Apaga um usuário
function MysqlDatabase:drop.user(){

    if [[ -z "${1}" ]]; then
        echo "[!] Argumento vazio. Adicione o nome da banco de dados para remover!"
        return 1
    fi

    local userdelete="$1"
    local cmd="DROP USER IF EXISTS '${userdelete}'@'%';"

    if [[ ! "$userdelete" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela inválido"
        return 1
    fi

    if ! MYSQL_PWD="${root_pass}" mariadb -h "${mysql_host}" -u "${root_user}" -e "${cmd}" >/dev/null 2>&1;then
        echo "[!] Não foi possivel excluir ${userdelete} do database ${database_file}!" && return 1
    fi

}

# * Apaga um index
function MysqlDatabase:delete.index(){

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
    local cmd2="USE ${mdatabase_name}; ALTER TABLE ${table} DROP INDEX idx_${index};"

    if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "$user" -e "${cmd2}";then
        echo "[!] Não foi possivel excluir ${index} do database ${database_file}!" && return 1
    fi

}

# * Função de checagem
function MysqlDatabase:check(){

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
        "schema")       MYSQL_PWD="${pass}" mariadb --xml -h "${mysql_host}" -u "${user}" "${mdatabase_name}" -e "SHOW CREATE TABLE ${check_table};" \
                        | xmltojson ;;
        "indexs")       MYSQL_PWD="${pass}" mariadb --xml -h "${mysql_host}" -u "${user}" "${mdatabase_name}" -e "SHOW INDEX FROM ${check_table};"   \
                        | xmltojson ;;
        "table-info")   MYSQL_PWD="${pass}" mariadb --xml -h "${mysql_host}" -u "${user}" "${mdatabase_name}" -e "DESCRIBE ${check_table};"          \
                        | xmltojson ;;
        "table-errors") MYSQL_PWD="${pass}" mariadb --xml -h "${mysql_host}" -u "${user}" "${mdatabase_name}" -e "CHECK TABLE ${check_table};"       \
                        | xmltojson ;;
    esac

}

# * Função de inserção e atualização
function MysqlDatabase:insert() {

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
    local sql="USE ${mdatabase_name}; SET @value = '${escaped_value}'; INSERT INTO $table ($column) VALUES (@value);"

    if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${sql}" >/dev/null 2>&1;then
        return 1
    fi


}

function MysqlDatabase:update() {

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
    local sql="USE ${mdatabase_name}; SET @value = '${escaped_value}'; UPDATE $table SET $column = @value WHERE id = ${where};"

    if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${sql}" >/dev/null 2>&1;then
        return 1
    fi


}

# * Função de deletar um resgistro
function MysqlDatabase:delete() {

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

    local sql="USE ${mdatabase_name}; DELETE FROM $table WHERE id = ${where};"

    if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "$user" -e "${sql}" 2>/dev/null;then
        return 1
    fi

}

# * Função de seleção de tudo
function MysqlDatabase:select(){

    local table="$1"
    local type="${2}"
    local cmd="USE ${mdatabase_name}; SELECT * FROM ${table};"

    if [[ -z "$table" ]]; then
        echo "[!] Argumento vazio. Adicione a tabela para seleção!"
        return 1
    fi

    case "${type,,}" in 
        json) 
            local flag="--xml"
            if ! MYSQL_PWD="${pass}" mariadb "${flag}" -h "${mysql_host}" -u "$user" -e "${cmd}" 2>/dev/null | xmltojson ; then return 1 ; fi
            ;;
        *) 
            if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "$user" -e "${cmd}" 2>/dev/null;then return 1 ; fi
    esac


}

# * Função de seleção pelo id
function MysqlDatabase:get(){

    local table="$1"
    local where="${2:-1}"
    local type="${3}"
    local cmd="USE ${mdatabase_name}; SELECT * FROM ${table} WHERE ${where};"

    if [[ -z "$table" || -z "$where" ]]; then
        echo "[!] Argumento vazio. Adicione a tabela e coluna para seleção!"
        return 1
    fi

    if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  || ! "$where" =~ ^[0-9]*$ ]]; then
        echo "[!] Nome de tabela, filtro inválido"
        return 1
    fi

    case "${type,,}" in
        json)
            local flag="--xml"
            if ! MYSQL_PWD="${pass}" mariadb "${flag}" -h "${mysql_host}" -u "$user" -e "${cmd}" 2>/dev/null | xmltojson;then return 1 ; fi  
        ;;

        *)
            if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "$user" -e "${cmd}" 2>/dev/null;then return 1 ; fi  
    esac

}
