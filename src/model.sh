#!/usr/bin/env bash

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

#==================================
# * Configuração do Base Model
#==================================

function BaseModel(){

    case "${database_tag,,}" in
        "sqlite") model_sqlite ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

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

    query_alter="ALTER TABLE ${tablename} ADD COLUMN ${columnname} TEXT ${notnull};"

    if [[ "${param1,,}" == "unique" ]]; then
        param="on"
        query_unique="CREATE UNIQUE INDEX idx_${tablename}_${columnname} ON ${tablename}(${columnname});"
    fi

}

function Model:IntegerFiled(){

    tablename="$1"
    columnname="$2"
    local param1="$3"
    notnull="$3"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_alter="ALTER TABLE ${tablename} ADD COLUMN ${columnname} INTEGER;"

    if [[ "${param1,,}" == "unique" ]]; then
        param="on"
        query_unique="CREATE UNIQUE INDEX idx_${tablename}_${columnname} ON ${tablename}(${columnname});"
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

    query_alter="ALTER TABLE ${tablename} ADD COLUMN ${columnname} REAL;"

    if [[ "${param1,,}" == "unique" ]]; then
        param="on"
        query_unique="CREATE UNIQUE INDEX idx_${tablename}_${columnname} ON ${tablename}(${columnname});"
    fi

}

function Model:BlobFiled(){

    tablename="$1"
    columnname="$2"

    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || ! "$columnname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "[!] Nome de tabela ou coluna inválido"
        return 1
    fi

    query_alter="ALTER TABLE ${tablename} ADD COLUMN ${columnname} BLOB;"

}

function Model:ForeignKeyField() {

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

        if rm "${temp}"; then
            return 1
        fi

    }

    local tablename="$1"
    local tabler="$2"
    local file_temp="${tablename}.temp"
    local path="${rootdir}/src/.temp"
    local temp="${path}/${file_temp}"

    if [ ! -d "${path}" ]; then
        if ! touch "${temp}"; then return 1; fi 
    fi

    case "${database_tag,,}" in
        "sqlite") ForeignKeyField.sqlite ;;
        *) echo "[!] Não foi possível determinar o banco de dados: ${database_tag}"
    esac

}
