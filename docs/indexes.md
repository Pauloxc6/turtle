# Queries

O Turtle permite executar comandos SQL diretamente através da função
`SqliteDatabase:query`.

Essa função é utilizada quando uma operação precisa de uma consulta SQL
personalizada que não é atendida pelas funções de alto nível do Turtle.

## Sintaxe

A sintaxe básica utiliza um modo de saída e uma query SQL.

```bash
SqliteDatabase:query <mode> <<SQL
<query>
SQL
```

O delimitador `SQL` pode ser substituído por outro identificador, desde
que o mesmo identificador seja utilizado para abrir e fechar o Here Document.

## SELECT

Uma consulta `SELECT` pode ser utilizada para recuperar registros
diretamente do banco de dados.

```bash
# * Seleciona todos os clientes
SqliteDatabase:query box <<SQL
SELECT
    *
FROM
    customers;
SQL
```

Também é possível selecionar apenas algumas colunas:

```bash
# * Seleciona o nome e o email dos clientes
SqliteDatabase:query box <<SQL
SELECT
    name,
    email
FROM
    customers;
SQL
```

## WHERE

A cláusula `WHERE` permite filtrar os registros retornados pela consulta.

```bash
# * Seleciona o cliente com ID 1
SqliteDatabase:query box <<SQL
SELECT
    *
FROM
    customers
WHERE
    id = 1;
SQL
```

Também podem ser utilizadas condições mais específicas:

```bash
# * Seleciona produtos com estoque maior que zero
SqliteDatabase:query box <<SQL
SELECT
    name,
    stock
FROM
    products
WHERE
    stock > 0;
SQL
```

## ORDER BY

`ORDER BY` permite ordenar os resultados de uma consulta.

```bash
# * Lista os produtos do menor para o maior preço
SqliteDatabase:query box <<SQL
SELECT
    name,
    price
FROM
    products
ORDER BY
    price ASC;
SQL
```

Para ordenar em ordem decrescente:

```bash
# * Lista os produtos do maior para o menor preço
SqliteDatabase:query box <<SQL
SELECT
    name,
    price
FROM
    products
ORDER BY
    price DESC;
SQL
```

## LIMIT

`LIMIT` permite limitar a quantidade de registros retornados.

```bash
# * Retorna apenas os cinco primeiros produtos
SqliteDatabase:query box <<SQL
SELECT
    *
FROM
    products
LIMIT 5;
SQL
```

## INSERT

Também é possível executar comandos `INSERT` diretamente através de
`SqliteDatabase:query`.

```bash
# * Insere um cliente diretamente através de SQL
SqliteDatabase:query box <<SQL
INSERT INTO customers (
    name,
    email
)
VALUES (
    'Paulo Santos',
    'paulo@example.com'
);
SQL
```

Para operações simples de inserção, também pode ser utilizada a API
`SqliteDatabase:insert`.

Consulte [CRUD](crud.md) para mais informações.

## UPDATE

Comandos `UPDATE` podem ser executados diretamente através da função
`query`.

```bash
# * Atualiza o nome do cliente com ID 1
SqliteDatabase:query box <<SQL
UPDATE
    customers
SET
    name = 'Paulo Cezar Santos'
WHERE
    id = 1;
SQL
```

## DELETE

Comandos `DELETE` também podem ser executados através de SQL.

```bash
# * Remove o cliente com ID 1
SqliteDatabase:query box <<SQL
DELETE FROM
    customers
WHERE
    id = 1;
SQL
```

Para remoções simples por ID, a API `SqliteDatabase:delete` também pode
ser utilizada.

## JOIN

Queries podem utilizar `JOIN` para consultar dados relacionados entre
diferentes tabelas.

Considere as tabelas `customers` e `orders`.

```bash
# * Consulta os pedidos junto com os dados dos clientes
SqliteDatabase:query box <<SQL
SELECT
    customers.name,
    orders.quantity,
    orders.total
FROM
    orders
JOIN
    customers
ON
    orders.customer_id = customers.id;
SQL
```

O `JOIN` permite combinar registros de diferentes tabelas através de
suas relações.

## Funções SQL

Funções disponíveis no SQLite também podem ser utilizadas normalmente.

Por exemplo, `COUNT` pode ser utilizada para contar registros:

```bash
# * Conta a quantidade de clientes cadastrados
SqliteDatabase:query box <<SQL
SELECT
    COUNT(*) AS total
FROM
    customers;
SQL
```

Outra possibilidade é utilizar `SUM`:

```bash
# * Calcula o valor total dos pedidos
SqliteDatabase:query box <<SQL
SELECT
    SUM(total) AS total_orders
FROM
    orders;
SQL
```

## Here Document

O uso de Here Document é especialmente útil para consultas maiores,
pois permite escrever o SQL em múltiplas linhas.

```bash
SqliteDatabase:query box <<SQL
SELECT
    customers.name,
    customers.email,
    orders.quantity,
    orders.total
FROM
    customers
JOIN
    orders
ON
    customers.id = orders.customer_id
WHERE
    orders.total > 100
ORDER BY
    orders.total DESC;
SQL
```

O delimitador utilizado para o Here Document não precisa ser
necessariamente `SQL`.

Por exemplo:

```bash
SqliteDatabase:query box <<QUERY
SELECT
    *
FROM
    products;
QUERY
```

O importante é que o delimitador inicial e final sejam iguais.

## Modos de Saída

O primeiro argumento de `SqliteDatabase:query` representa o modo utilizado
para exibir o resultado da consulta.

```bash
SqliteDatabase:query <mode> <<SQL
...
SQL
```

Por exemplo:

```bash
# * Executa a query utilizando o modo box
SqliteDatabase:query box <<SQL
SELECT
    *
FROM
    customers;
SQL
```

O modo `box` apresenta os resultados em formato tabular.

> Os modos disponíveis dependem da implementação atual do Turtle.

## Query com Variáveis do Bash

Como a query é passada através de um Here Document, variáveis do Bash
podem ser expandidas quando o delimitador não é protegido por aspas.

```bash
# * Define o ID que será consultado
id=1

# * A variável $id será expandida pelo Bash
SqliteDatabase:query box <<SQL
SELECT
    *
FROM
    customers
WHERE
    id = $id;
SQL
```

Isso permite combinar valores definidos pelo script com consultas SQL.

Entretanto, valores fornecidos externamente devem ser tratados com
cuidado antes de serem inseridos diretamente em uma query SQL.

## Consultando o Schema

`SqliteDatabase:query` também pode ser utilizado para consultar as
estruturas internas do SQLite.

```bash
# * Lista as tabelas existentes no banco
SqliteDatabase:query box <<SQL
SELECT
    name
FROM
    sqlite_schema
WHERE
    type = 'table'
AND
    name NOT LIKE 'sqlite_%';
SQL
```

Também é possível consultar o schema de uma tabela específica:

```bash
# * Exibe a definição da tabela customers
SqliteDatabase:query box <<SQL
SELECT
    sql
FROM
    sqlite_schema
WHERE
    type = 'table'
AND
    name = 'customers';
SQL
```

## Exemplo Completo

O exemplo abaixo demonstra diferentes operações utilizando
`SqliteDatabase:query`.

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

# * Insere registros utilizando SQL
SqliteDatabase:query box <<SQL
INSERT INTO customers (
    name,
    email
)
VALUES
    ('Paulo Santos', 'paulo@example.com'),
    ('Maria Silva', 'maria@example.com');
SQL

# * Consulta os registros
SqliteDatabase:query box <<SQL
SELECT
    *
FROM
    customers;
SQL

# * Filtra os registros
SqliteDatabase:query box <<SQL
SELECT
    name,
    email
FROM
    customers
WHERE
    id = 1;
SQL

# * Atualiza um registro
SqliteDatabase:query box <<SQL
UPDATE
    customers
SET
    name = 'Paulo Cezar Santos'
WHERE
    id = 1;
SQL

# * Consulta novamente os registros
SqliteDatabase:query box <<SQL
SELECT
    *
FROM
    customers;
SQL
```

## Quando Utilizar Query

O Turtle fornece funções específicas para operações comuns:

```text
SqliteDatabase:insert
SqliteDatabase:select
SqliteDatabase:update
SqliteDatabase:delete
```

Quando a operação necessária exige uma consulta SQL personalizada, pode
ser utilizado:

```text
SqliteDatabase:query
```

Dessa forma, a API de alto nível do Turtle pode ser utilizada para as
operações comuns, enquanto `SqliteDatabase:query` permite acessar
diretamente os recursos do SQLite quando necessário.
