# Schema

O **schema** representa a estrutura definida dentro do banco de dados SQLite.

Por meio do Turtle, é possível consultar a estrutura das tabelas, suas colunas, tipos e outras informações utilizando os comandos de inspeção do banco.

## Consultar o Schema

Para consultar o schema de uma tabela:

```bash
SqliteDatabase:check schema <tablename>
```

### Sintaxe

```bash
SqliteDatabase:check schema <tablename>
```

Onde:

* `<tablename>` é o nome da tabela que será consultada.

### Exemplo

```bash
# * Consulta o schema da tabela users
SqliteDatabase:check schema users
```

O resultado corresponde à definição SQL utilizada pelo SQLite para representar a tabela.

---

## Informações da Tabela

Além do schema SQL, o Turtle permite consultar informações estruturais de uma tabela utilizando:

```bash
SqliteDatabase:check table-info <tablename>
```

### Sintaxe

```bash
SqliteDatabase:check table-info <tablename>
```

### Exemplo

```bash
# * Consulta as informações das colunas de users
SqliteDatabase:check table-info users
```

Esse comando é útil para visualizar informações relacionadas às colunas da tabela, como seus nomes e tipos.

---

## Consultar Todos os Objetos

Para visualizar os objetos existentes no banco de dados:

```bash
SqliteDatabase:readall
```

### Exemplo

```bash
# * Exibe os objetos registrados no banco
SqliteDatabase:readall
```

Esse comando pode ser utilizado para inspecionar a estrutura geral do banco antes de analisar uma tabela específica.

---

## Schema do SQLite

O SQLite mantém as informações estruturais do banco no catálogo interno chamado `sqlite_schema`.

Também é possível consultar essas informações utilizando `SqliteDatabase:query`:

```bash
SqliteDatabase:query box <<SQL
SELECT
    name,
    type,
    sql
FROM
    sqlite_schema
WHERE
    name NOT LIKE 'sqlite_%';
SQL
```

Nesse caso, a consulta retorna informações sobre os objetos do banco, como:

* `name` — nome do objeto;
* `type` — tipo do objeto;
* `sql` — definição SQL do objeto.

---

## Schema de uma Tabela

Considere uma tabela `users`:

```text
users
├── id
├── username
└── email
```

Podemos consultar sua definição:

```bash
# * Consulta a definição da tabela
SqliteDatabase:check schema users
```

E consultar as informações das colunas:

```bash
# * Consulta informações estruturais
SqliteDatabase:check table-info users
```

Esses dois comandos possuem objetivos diferentes:

```text
check schema
      │
      └── Mostra a definição SQL da tabela


check table-info
      │
      └── Mostra informações estruturais das colunas
```

---

## Exemplo Completo

```bash
#!/usr/bin/env bash

# * Importa o Turtle ORM
source "/home/$USER/.local/share/turtle/orm.sh"

# * Define o banco de dados
db="shop"

# * Inicializa o banco
SqliteDatabase "${db}"

# * Cria a tabela
SqliteDatabase:create users && BaseModel

# * Adiciona os campos
Model:TextFiled users username unique
Model:TextFiled users email notnull
Model:IntegerFiled users age

# * Consulta o schema da tabela
SqliteDatabase:check schema users

# * Consulta informações das colunas
SqliteDatabase:check table-info users

# * Consulta os objetos existentes no banco
SqliteDatabase:readall
```

## Resumo

| Comando                                       | Função                                          |
| --------------------------------------------- | ----------------------------------------------- |
| `SqliteDatabase:check schema <tablename>`     | Consulta a definição SQL da tabela              |
| `SqliteDatabase:check table-info <tablename>` | Consulta informações estruturais da tabela      |
| `SqliteDatabase:readall`                      | Consulta os objetos existentes no banco         |
| `SqliteDatabase:query`                        | Permite consultar diretamente o `sqlite_schema` |

O schema é especialmente útil durante o desenvolvimento do ORM para verificar se a estrutura gerada pelo Turtle corresponde aos Models e Fields definidos pelo usuário.
