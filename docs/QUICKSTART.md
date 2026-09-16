# Quickstart

Este guia explica passo a passo como definir um esquema, escrever linhas e lê-las de volta.

## Definição de Model

A biblioteca Turtle começa com um objeto `Database` e uma ou mais classe `Model`. O objeto `Database` gerencia o banco de dados, enquanto as funções `Model` são responsáveis pela definição das tabelas e seus campos.

```bash
#!/usr/bin/env bash

# * Importa o Turtle ORM
source "/home/$USER/.local/share/turtle/orm.sh"

# * Define o nome do banco de dados
# * Todas as instâncias devem ser inicializadas através de uma variável
# * no formato: var="foo", onde "foo" representa o nome do banco.
db="shop"

# * Cria ou inicializa o banco de dados SQLite
SqliteDatabase "${db}"
```

## Definição de Tabelas

As tabelas são criadas utilizando `SqliteDatabase:create`.

Após a criação, `BaseModel` processa os Models e seus respectivos Fields.

Neste exemplo, será criado um pequeno esquema para uma loja, contendo clientes, produtos e pedidos.

```bash
# * Cria a tabela de clientes
# * Sintaxe: SqliteDatabase:create <tablename> && BaseModel
SqliteDatabase:create customers && BaseModel

# * Cria a tabela de produtos
SqliteDatabase:create products && BaseModel

# * Cria a tabela de pedidos
SqliteDatabase:create orders && BaseModel
```

## Definição de Campos

Os campos são adicionados às tabelas através das funções `Model:*Filed`.

O primeiro argumento representa a tabela e o segundo representa o nome da coluna.

Os campos também podem receber propriedades adicionais, como `unique` e `notnull`.

### Campo TEXT

`Model:TextFiled` cria uma coluna do tipo `TEXT`.

```bash
# * Cria uma coluna do tipo TEXT
# * Sintaxe: Model:TextFiled <tablename> <columnname>
Model:TextFiled customers name && BaseModel

# * Cria uma coluna TEXT com restrição UNIQUE
Model:TextFiled customers email unique && BaseModel

# * Cria uma coluna TEXT com restrição NOT NULL
Model:TextFiled products name notnull && BaseModel

# * É possível utilizar múltiplas propriedades no mesmo campo
Model:TextFiled customers phone unique notnull && BaseModel
```

As propriedades podem ser combinadas conforme a necessidade:

```bash
# * UNIQUE
Model:TextFiled customers email unique

# * NOT NULL
Model:TextFiled customers name notnull

# * UNIQUE + NOT NULL
Model:TextFiled customers phone unique notnull
```

> Para mais informações sobre a definição de campos, consulte [Fields](./fields.md).

### Campo INTEGER

`Model:IntegerFiled` cria uma coluna do tipo `INTEGER`.

```bash
# * Cria uma coluna do tipo INTEGER
# * Sintaxe: Model:IntegerFiled <tablename> <columnname>
Model:IntegerFiled customers age

# * Cria uma coluna INTEGER com restrição NOT NULL
Model:IntegerFiled products stock notnull
```

### Campo REAL

`Model:RealFiled` cria uma coluna do tipo `REAL`.

```bash
# * Cria uma coluna do tipo REAL
# * Sintaxe: Model:RealFiled <tablename> <columnname>
Model:RealFiled products price notnull
```

### Campo BLOB

`Model:BlobFiled` cria uma coluna do tipo `BLOB`.

```bash
# * Cria uma coluna do tipo BLOB
# * Sintaxe: Model:BlobFiled <tablename> <columnname>
Model:BlobFiled products image
```

## Exemplo Completo de Model

A definição das tabelas pode ser combinada para representar uma estrutura mais próxima de uma aplicação real.

```bash
# * Tabela de clientes
SqliteDatabase:create customers && BaseModel

Model:TextFiled customers name notnull && BaseModel
Model:TextFiled customers email unique notnull && BaseModel
Model:TextFiled customers phone unique && BaseModel

# * Tabela de produtos
SqliteDatabase:create products && BaseModel

Model:TextFiled products name notnull && BaseModel
Model:RealFiled products price notnull && BaseModel
Model:IntegerFiled products stock notnull && BaseModel
Model:BlobFiled products image && BaseModel

# * Tabela de pedidos
SqliteDatabase:create orders && BaseModel

Model:IntegerFiled orders quantity notnull && BaseModel
Model:RealFiled orders total notnull && BaseModel
```

## Chave Estrangeira

As chaves estrangeiras são definidas através de `Model:ForeignKeyField`.

Por padrão, as colunas `id` são configuradas como `PRIMARY KEY`. `ForeignKeyField` adiciona uma coluna que estabelece uma referência entre duas tabelas.

```bash
# * Define uma chave estrangeira
# * Sintaxe: Model:ForeignKeyField <table1> <table2>

# * <table1> representa a tabela que receberá a referência.
# * <table2> representa a tabela referenciada.
Model:ForeignKeyField orders customers
```

Neste exemplo, a tabela `orders` passa a possuir uma referência para a tabela `customers`.

> Para mais informações sobre relacionamentos entre tabelas, consulte [Relationships](./relationships.md).

## Inserção de Dados

Os registros são inseridos utilizando `SqliteDatabase:insert`.

O primeiro argumento representa a tabela, o segundo representa a coluna e o terceiro representa o valor que será armazenado.

```bash
# * Insere um cliente
# * Sintaxe: SqliteDatabase:insert <tablename> <columnname> <value>
SqliteDatabase:insert customers name "Paulo Santos" && BaseModel

# * Insere o email do cliente
SqliteDatabase:insert customers email "paulo@example.com" && BaseModel

# * Insere um produto
SqliteDatabase:insert products name "Notebook" && BaseModel

# * Define o preço do produto
SqliteDatabase:insert products price 3500.00 && BaseModel

# * Define o estoque do produto
SqliteDatabase:insert products stock 10 && BaseModel
```

## Atualização de Dados

Os registros existentes podem ser atualizados utilizando `SqliteDatabase:update`.

O último argumento representa o ID do registro que será atualizado.

```bash
# * Atualiza o nome do cliente com ID 1
# * Sintaxe: SqliteDatabase:update <tablename> <columnname> <value> <id>
SqliteDatabase:update customers name "Paulo Cezar Santos" 1 && BaseModel

# * Atualiza o estoque do produto com ID 1
SqliteDatabase:update products stock 20 1 && BaseModel
```

## Seleção de Dados

Os registros de uma tabela podem ser consultados utilizando `SqliteDatabase:select`.

```bash
# * Seleciona todos os registros da tabela customers
# * Sintaxe: SqliteDatabase:select <tablename>
SqliteDatabase:select customers
```

Por exemplo, para consultar os produtos cadastrados:

```bash
# * Seleciona todos os registros da tabela products
SqliteDatabase:select products
```

> Para mais informações sobre operações de Create, Read, Update e Delete, consulte [CRUD](./crud.md).

## Consultas SQL

Consultas SQL personalizadas podem ser executadas utilizando `SqliteDatabase:query`.

A query pode ser passada diretamente para a função através de um Here Document.

```bash
# * Executa uma query SQL
# * A query pode ser passada através de um Here Document.
SqliteDatabase:query box <<SQL

SELECT

    *

FROM

    customers;

SQL
```

Também é possível utilizar consultas com condições:

```bash
SqliteDatabase:query box <<SQL

SELECT

    name,

    email

FROM

    customers

WHERE

    id = 1;

SQL
```

> Para mais informações sobre consultas SQL, consulte [Queries](./queries.md).

## Remoção de Registros

Um registro pode ser removido utilizando `SqliteDatabase:delete`.

O segundo argumento representa o ID do registro que será removido.

```bash
# * Remove o cliente com ID 1
# * Sintaxe: SqliteDatabase:delete <tablename> <id>
SqliteDatabase:delete customers 1
```

> Para mais informações sobre operações de Create, Read, Update e Delete, consulte [CRUD](./crud.md).

## Leitura do Banco de Dados

`SqliteDatabase:readall` exibe todas as tabelas existentes no banco de dados.

```bash
# * Exibe todas as tabelas existentes no banco de dados
SqliteDatabase:readall
```

> Para mais informações sobre a estrutura do banco de dados, consulte [Schema](./schema.md).

## Índices

Os índices associados a uma tabela podem ser consultados através de `SqliteDatabase:check indexs`.

```bash
# * Verifica os índices da tabela customers
# * Sintaxe: SqliteDatabase:check indexs <tablename>
SqliteDatabase:check indexs customers
```

> Para mais informações sobre índices, consulte [Indexes](./indexes.md).

## Schema

O schema de uma tabela pode ser exibido utilizando `SqliteDatabase:check schema`.

```bash
# * Exibe o schema da tabela customers
# * Sintaxe: SqliteDatabase:check schema <tablename>
SqliteDatabase:check schema customers

# * Exibe o schema da tabela products
SqliteDatabase:check schema products

# * Exibe o schema da tabela orders
SqliteDatabase:check schema orders
```

## Informações das Colunas

As informações estruturais das colunas podem ser consultadas através de `SqliteDatabase:check table-info`.

```bash
# * Exibe as informações das colunas da tabela customers
# * Sintaxe: SqliteDatabase:check table-info <tablename>
SqliteDatabase:check table-info customers

# * Exibe as informações das colunas da tabela products
SqliteDatabase:check table-info products

# * Exibe as informações das colunas da tabela orders
SqliteDatabase:check table-info orders
```

> Para mais informações sobre schema e inspeção das tabelas, consulte [Schema](./schema.md).

## Remoção de Tabelas

Uma tabela pode ser removida utilizando `SqliteDatabase:drop`.

```bash
# * Remove a tabela orders
# * Sintaxe: SqliteDatabase:drop <tablename>
SqliteDatabase:drop "orders"

# * Remove a tabela products
SqliteDatabase:drop "products"
SqliteDatabase:drop "customers"
```

## Remoção de Índices

Um índice associado a uma coluna pode ser removido utilizando `SqliteDatabase:delete.index`.

```bash
# * Remove o índice associado à coluna email
# * Sintaxe: SqliteDatabase:delete.index <tablename> <columnname>
SqliteDatabase:delete.index customers email
```

> Para mais informações sobre gerenciamento de índices, consulte [Indexes](./indexes.md).
