#!/usr/bin/env bash

#==================================
# * Configuração do Base Model
#==================================

function BaseModel(){

    case "${database_tag,,}" in
        "sqlite") model_sqlite ; typedata="TEXT"  ;;
        "mysql") model_mysql ; typedata="varchar(255)" ; active_db="USE ${mdatabase_name};" ;;
        "postgresql") model_postgres ; typedata="varchar(255)" ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

}

#==================================
# * Configuração dos Models
#==================================

function model_sqlite(){

    if ! sqlite3 "${database_file}" "${query_create}" >/dev/null 2>&1;then
        return 1
    fi

    if ! sqlite3 "${database_file}" "${query_alter}" >/dev/null 2>&1; then
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

function model_postgres(){

    if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "${user}" -d "${pdatabase_name}" -c "${query_create}" >/dev/null 2>&1;then
        return 1
    fi

    if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "${user}" -d "${pdatabase_name}" -c "${query_alter}" >/dev/null 2>&1; then
        return 1
    fi

    case "${param}" in "on") PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "${user}" -d "${pdatabase_name}" -c "${query_unique}" >/dev/null 2>&1 ;; esac

    # * Limpa as variáveis utilizadas na configuração do Model
    vars=( query_create query_alter query_unique )
    for var in "${vars[@]}";do unset "${var}"; done

}

#==================================
# * Configuração dos tipos de Model
#==================================

function Model:TextField(){

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

function Model:IntegerField(){

    tablename="$1"
    columnname="$2"
    local param1="$3"
    notnull="$3"

    case "${database_tag,,}" in
        "sqlite") model_sqlite ; local typedata="INTEGER"  ;;
        "mysql") model_mysql ; local typedata="INT" ;;
        "postgresql") model_postgres ; local typedata="INTEGER"  ;;
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

function Model:RealField(){

    tablename="$1"
    columnname="$2"
    local param1="$3"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    case "${database_tag,,}" in
        "sqlite") model_sqlite ; local typedata="REAL" ;;
        "mysql") model_mysql ; local typedata="FLOAT" ;;
        "postgresql") model_postgres; local typedata="REAL" ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

    query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} ${typedata};"

    if [[ "${param1,,}" == "unique" ]]; then
        param="on"
        query_unique="${active_db} CREATE UNIQUE INDEX idx_${tablename}_${columnname} ON ${tablename}(${columnname});"
    fi

}

function Model:BlobField(){

    tablename="$1"
    columnname="$2"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    case "${database_tag}" in
        "postgresql") query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} BYTEA;" ;;
        *) query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} BLOB;"             ;;
    esac

}

function Model:BooleanField(){

    tablename="$1"
    columnname="$2"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} BOOLEAN;"

}

function Model:DatetimeField(){

    tablename="$1"
    columnname="$2"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela, coluna ou formato da data inválido"
        return 1
    fi

    case "${database_tag,,}" in
        "mysql") model_mysql ; local typedata="DATETIME" ;;
        "postgresql") model_postgres; local typedata="TIMESTAMP" ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

    query_alter="${active_db} ALTER TABLE ${tablename} ADD COLUMN ${columnname} ${typedata}"

}

function Model:ForeignKeyField() {

    function ForeignKeyField.postgres(){

        local sql="ALTER TABLE ${tablename} ADD FOREIGN KEY (id) REFERENCES ${tabler}(id);"

        if ! PGPASSWORD="${pass}" psql -h "${postgresql_host}" -U "${user}" -d "${pdatabase_name}"  -c "${sql}" >/dev/null 2>&1; then
            return 1
        fi
    }

    function ForeignKeyField.mysql(){

        local sql="USE ${mdatabase_name}; ALTER TABLE ${tablename} ADD FOREIGN KEY (id) REFERENCES ${tabler}(id);"

        if ! MYSQL_PWD="${pass}" mariadb -h "${mysql_host}" -u "${user}" -e "${sql}" >/dev/null 2>&1; then
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
        "postgresql") ForeignKeyField.postgres ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

}
