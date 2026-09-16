# CRUD

CRUD é um acrônimo para as quatro operações básicas de manipulação de
dados em um banco de dados:

* **Create** — inserir registros;
* **Read** — consultar registros;
* **Update** — atualizar registros;
* **Delete** — remover registros.

No Turtle, essas operações são realizadas através das funções
`SqliteDatabase:insert`, `SqliteDatabase:select`, `SqliteDatabase:update`
e `SqliteDatabase:delete`.

## Create

A operação **Create** é utilizada para inserir novos registros em uma
tabela.

No Turtle, os registros podem ser inseridos utilizando
`SqliteDatabase:insert`.

### Sintaxe

```bash
SqliteDatabase:insert <tablename> <columnname> <value>
```

Onde:

* `<tablename>` representa a tabela;
* `<columnname>` representa a coluna;
* `<value>` representa o valor que será armazenado.

### Exemplo

```bash
# * Insere um cliente na tabela customers
SqliteDatabase:insert customers name "Paulo Santos" && BaseModel

# * Insere o email do cliente
SqliteDatabase:insert customers email "paulo@example.com" && BaseModel
```

Também é possível inserir valores em outros tipos de campos:

```bash
# * Insere um produto
SqliteDatabase:insert products name "Notebook" && BaseModel

# * Define o preço do produto
SqliteDatabase:insert products price 3500.00 && BaseModel

# * Define o estoque do produto
SqliteDatabase:insert products stock 10 && BaseModel
```

## Read

A operação **Read** é utilizada para consultar os registros armazenados
em uma tabela.

No Turtle, a consulta básica pode ser realizada utilizando
`SqliteDatabase:select`.

### Sintaxe

```bash
SqliteDatabase:select <tablename>
```

### Exemplo

```bash
# * Seleciona os registros da tabela customers
SqliteDatabase:select customers
```

Para consultar outra tabela:

```bash
# * Seleciona os registros da tabela products
SqliteDatabase:select products
```

O `select` é utilizado para a consulta básica dos registros. Para executar
consultas SQL personalizadas, utilize `SqliteDatabase:query`.

Consulte [Queries](queries.md) para mais informações.

## Update

A operação **Update** é utilizada para alterar um registro existente.

No Turtle, a atualização é realizada através de `SqliteDatabase:update`.

### Sintaxe

```bash
SqliteDatabase:update <tablename> <columnname> <value> <id>
```

O último argumento representa o ID do registro que será atualizado.

### Exemplo

```bash
# * Atualiza o nome do cliente com ID 1
SqliteDatabase:update customers name "Paulo Cezar Santos" 1 && BaseModel
```

Também é possível atualizar outros campos:

```bash
# * Atualiza o email do cliente com ID 1
SqliteDatabase:update customers email "paulo@newmail.com" 1 && BaseModel

# * Atualiza o estoque do produto com ID 1
SqliteDatabase:update products stock 20 1 && BaseModel

# * Atualiza o preço do produto com ID 1
SqliteDatabase:update products price 3299.90 1 && BaseModel
```

O ID utilizado na operação identifica o registro que será alterado.

## Delete

A operação **Delete** é utilizada para remover um registro de uma tabela.

No Turtle, a remoção é realizada através de `SqliteDatabase:delete`.

### Sintaxe

```bash
SqliteDatabase:delete <tablename> <id>
```

O segundo argumento representa o ID do registro que será removido.

### Exemplo

```bash
# * Remove o cliente com ID 1
SqliteDatabase:delete customers 1
```

Também é possível remover registros de outras tabelas:

```bash
# * Remove o produto com ID 1
SqliteDatabase:delete products 1
```

## Exemplo Completo

O exemplo abaixo demonstra o fluxo completo de CRUD utilizando uma tabela
de clientes.

```bash
#!/usr/bin/env bash

# * Importa o Turtle ORM
source "/home/$USER/.local/share/turtle/orm.sh"

# * Define o banco de dados
db="shop"

# * Inicializa o banco
SqliteDatabase "${db}"

# * Cria a tabela customers
SqliteDatabase:create customers && BaseModel

# * Define os campos
Model:TextFiled customers name notnull && BaseModel
Model:TextFiled customers email unique notnull && BaseModel

# * CREATE
# * Insere um novo cliente
SqliteDatabase:insert customers name "Paulo Santos" && BaseModel
SqliteDatabase:insert customers email "paulo@example.com" && BaseModel

# * READ
# * Consulta os clientes cadastrados
SqliteDatabase:select customers

# * UPDATE
# * Atualiza o cliente com ID 1
SqliteDatabase:update customers name "Paulo Cezar Santos" 1 && BaseModel

# * READ
# * Verifica o registro atualizado
SqliteDatabase:select customers

# * DELETE
# * Remove o cliente com ID 1
SqliteDatabase:delete customers 1

# * READ
# * Verifica os registros restantes
SqliteDatabase:select customers
```

## Fluxo CRUD

O fluxo básico de manipulação de registros pode ser representado da
seguinte maneira:

```text
CREATE
  │
  ▼
INSERT
  │
  ▼
 READ
  │
  ├──── UPDATE
  │       │
  │       ▼
  │      READ
  │
  └──── DELETE
          │
          ▼
         READ
```

As operações CRUD fornecem a interface básica para trabalhar com os
registros armazenados no banco de dados através do Turtle.
