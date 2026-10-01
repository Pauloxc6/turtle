#!/usr/bin/env bash

#==================================
# * Configuração do Base Model
#==================================

function BaseModel(){

    case "${database_tag,,}" in
        "sqlite") model_sqlite ; typedata="TEXT"  ;;
        "mysql") model_mysql ; typedata="varchar(255)" ; active_db="USE ${mdatabase_name};" ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

}

#==================================
# * Configuração dos Models
#==================================

function model_sqlite(){

    if ! sqlite3 "${database_file}" "${query_create}";then
        return 1
    fi

    if ! sqlite3 "${database_file}" "${query_alter}"; then
        return 1
    fi

    case "${param}" in "on") sqlite3 "${database_file}" "${query_unique}" ;; esac

    # * Limpa as variáveis utilizadas na configuração do Model
    vars=( query_create query_alter query_unique )
    for var in "${vars[@]}";do unset "${var}"; done

}

function model_mysql(){

    if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${query_create}" >/dev/null 2>&1;then
        return 1
    fi

    if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${query_alter}" >/dev/null 2>&1; then
        return 1
    fi

    case "${param}" in "on") MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${query_unique}" ;; esac

    # * Limpa as variáveis utilizadas na configuração do Model
    vars=( query_create query_alter query_unique )
    for var in "${vars[@]}";do unset "${var}"; done

}

#==================================
# * Configuração dos tipos de Model
#==================================

function Model:TextFiled(){

    tablename="$1"
    columnname="$2"
    local param1="$3"
    notnull="$4"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    if [[ "${param1}" == "notnull" || "${notnull}" == "notnull" ]];then
        notnull="NOT NULL"
    fi

    query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} ${typedata:-TEXT} ${notnull};"

    if [[ "${param1,,}" == "unique" ]]; then
        param="on"
        query_unique="${active_db} CREATE UNIQUE INDEX idx_${tablename}_${columnname} ON ${tablename}(${columnname});"
    fi

}

function Model:IntegerFiled(){

    tablename="$1"
    columnname="$2"
    local param1="$3"
    notnull="$3"

    case "${database_tag,,}" in
        "sqlite") model_sqlite ; local typedata="INTEGER"  ;;
        "mysql") model_mysql ; local typedata="INT" ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} ${typedata};"

    if [[ "${param1,,}" == "unique" ]]; then
        param="on"
        query_unique="${active_db} CREATE UNIQUE INDEX idx_${tablename}_${columnname} ON ${tablename}(${columnname});"
    fi

}

function Model:RealFiled(){

    tablename="$1"
    columnname="$2"
    local param1="$3"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    case "${database_tag,,}" in
        "sqlite") model_sqlite ; local typedata="REAL"  ;;
        "mysql") model_mysql ; local typedata="FLOAT" ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

    query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} ${typedata};"

    if [[ "${param1,,}" == "unique" ]]; then
        param="on"
        query_unique="${active_db} CREATE UNIQUE INDEX idx_${tablename}_${columnname} ON ${tablename}(${columnname});"
    fi

}

function Model:BlobFiled(){

    tablename="$1"
    columnname="$2"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} BLOB;"

}

function Model:BooleanFiled(){

    tablename="$1"
    columnname="$2"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_alter="USE ${mdatabase_name}; ALTER TABLE ${tablename} ADD COLUMN ${columnname} BOOLEAN;"

}

function Model:DatetimeFiled(){

    tablename="$1"
    columnname="$2"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "${3}" =~ ^[a-zA-Z0-9=]+$ ]]; then
        echo "[!] Nome de tabela, coluna ou formato da data inválido"
        return 1
    fi
    
    # format=24
    local formated=$( echo "$3" | awk -F'=' '{print $1}' )
    local hour=$( echo "$3" | awk -F'=' '{print $2}' )
    local timestamp=$(datetime "${hour}")

    if [[ "${formated}" != "format" ]]; then
        return 1
    fi

    query_alter="USE ${mdatabase_name}; ALTER TABLE ${tablename} ADD COLUMN ${columnname} DATETIME; INSERT INTO ${tablename} (${columnname}) VALUES ('${timestamp}');"

}

function Model:ForeignKeyField() {

    function ForeignKeyField.mysql(){

        local sql="USE ${mdatabase_name}; ALTER TABLE ${tablename} ADD FOREIGN KEY (id) REFERENCES ${tabler}(id);"

        if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${sql}"; then
            return 1
        fi
    }

    function ForeignKeyField.sqlite(){
        if ! sqlite3 "$database_file" ".schema $tablename" > "$temp"; then
            return 1
        fi

        if ! sqlite3 "$database_file" "DROP TABLE $tablename"; then
            return 1
        fi

        sed -i -e "/);/s/);/, FOREIGN KEY (id) REFERENCES ${tabler}(id));/" "$temp"

        if ! sqlite3 "$database_file" < "$temp"; then
            return 1
        fi

        if ! rm "${temp}"; then
            return 1
        fi

    }

    local tablename="$1"
    local tabler="$2"
    local file_temp="${tablename}.temp"
    local path="/tmp"
    local temp="${path}/${file_temp}"

    if [ ! -d "${path}" ]; then
        if ! touch "${temp}"; then return 1; fi 
    fi

    case "${database_tag,,}" in
        "sqlite") ForeignKeyField.sqlite ;;
        "mysql") ForeignKeyField.mysql ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

}
