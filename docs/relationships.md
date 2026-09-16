# Relationships

Relationships são utilizadas para estabelecer relações entre diferentes
tabelas do banco de dados.

No Turtle, as relações entre tabelas são definidas através de
`Model:ForeignKeyField`.

Uma Foreign Key permite que uma tabela faça referência a um registro
existente em outra tabela.

## Foreign Key

Uma Foreign Key estabelece uma referência entre duas tabelas.

### Sintaxe

```bash id="2o8w0n"
Model:ForeignKeyField <table1> <table2>
```

Onde:

* `<table1>` representa a tabela que receberá a referência;
* `<table2>` representa a tabela referenciada.

### Exemplo

Considere duas tabelas:

```text id="v1q2ab"
customers
├── id
├── name
└── email

orders
├── id
└── ...
```

Podemos criar uma relação entre `orders` e `customers`:

```bash id="c4r8vx"
# * Cria a tabela customers
SqliteDatabase:create customers && BaseModel

# * Cria a tabela orders
SqliteDatabase:create orders && BaseModel

# * Cria uma Foreign Key entre orders e customers
Model:ForeignKeyField orders customers
```

Nesse caso, `orders` recebe uma referência para `customers`.

## Tabela Referenciada

A tabela utilizada como referência deve possuir uma chave primária.

No Turtle, a coluna `id` é configurada como `PRIMARY KEY` por padrão.

```text id="j8c4m1"
customers
└── id    PRIMARY KEY
```

A Foreign Key utiliza essa estrutura para estabelecer a relação.

## Exemplo com Clientes e Pedidos

Um cenário comum é relacionar pedidos aos clientes que os realizaram.

```bash id="m5y2rn"
# * Inicializa o banco
db="shop"
SqliteDatabase "${db}"

# * Cria a tabela customers
SqliteDatabase:create customers && BaseModel

# * Define os campos de customers
Model:TextFiled customers name notnull && BaseModel
Model:TextFiled customers email unique notnull && BaseModel

# * Cria a tabela orders
SqliteDatabase:create orders && BaseModel

# * Define os campos de orders
Model:IntegerFiled orders quantity notnull && BaseModel
Model:RealFiled orders total notnull && BaseModel

# * Cria a relação entre orders e customers
Model:ForeignKeyField orders customers
```

A estrutura pode ser representada conceitualmente como:

```text id="g6j1mz"
customers
│
│ id
│
▼
orders
```

Ou, de forma mais detalhada:

```text id="p2s7cw"
customers
┌───────────────┐
│ id PRIMARY KEY│
│ name          │
│ email         │
└───────┬───────┘
        │
        │ Foreign Key
        │
        ▼
┌────────────────┐
│ orders         │
│ id             │
│ quantity       │
│ total          │
└────────────────┘
```

## Criando a Relação

A relação deve ser criada depois que as tabelas envolvidas existirem.

```bash id="9f4qwe"
# * Cria a tabela principal
SqliteDatabase:create customers && BaseModel

# * Cria a tabela relacionada
SqliteDatabase:create orders && BaseModel

# * Cria a Foreign Key
Model:ForeignKeyField orders customers
```

O primeiro argumento é a tabela que receberá a referência.

```bash id="a8m3kd"
Model:ForeignKeyField orders customers
#                     ^      ^
#                     |      |
#                  origem  referência
```

Portanto:

```text id="0k2w4f"
orders → customers
```

A tabela `orders` depende da tabela `customers` para a referência.

## Múltiplas Foreign Keys

Uma tabela pode possuir referências para mais de uma tabela.

Por exemplo, um registro de pedido pode estar relacionado a um cliente
e a um produto.

```bash id="u7n1px"
# * Cria as tabelas
SqliteDatabase:create customers && BaseModel
SqliteDatabase:create products && BaseModel
SqliteDatabase:create orders && BaseModel

# * Define as relações
Model:ForeignKeyField orders customers
Model:ForeignKeyField orders products
```

A estrutura pode ser representada como:

```text id="e3r6jt"
customers ──┐
            │
            ▼
          orders
            ▲
            │
products ───┘
```

Nesse cenário, `orders` possui referências para as tabelas
`customers` e `products`.

## Consultando o Schema

Depois de criar uma relação, o schema pode ser utilizado para verificar
a estrutura da tabela.

```bash id="w5k2ra"
# * Exibe o schema da tabela orders
SqliteDatabase:check schema orders
```

Também é possível consultar as informações das colunas:

```bash id="x9c4mv"
# * Exibe as informações das colunas de orders
SqliteDatabase:check table-info orders
```

## Exemplo Completo

O exemplo abaixo cria um pequeno sistema de pedidos utilizando
três tabelas relacionadas.

```bash id="r7p3bn"
#!/usr/bin/env bash

# * Importa o Turtle ORM
source "/home/$USER/.local/share/turtle/orm.sh"

# * Define o banco de dados
db="shop"

# * Inicializa o banco
SqliteDatabase "${db}"

# * Cria a tabela customers
SqliteDatabase:create customers && BaseModel

# * Define os campos de customers
Model:TextFiled customers name notnull && BaseModel
Model:TextFiled customers email unique notnull && BaseModel

# * Cria a tabela products
SqliteDatabase:create products && BaseModel

# * Define os campos de products
Model:TextFiled products name notnull && BaseModel
Model:RealFiled products price notnull && BaseModel
Model:IntegerFiled products stock notnull && BaseModel

# * Cria a tabela orders
SqliteDatabase:create orders && BaseModel

# * Define os campos de orders
Model:IntegerFiled orders quantity notnull && BaseModel
Model:RealFiled orders total notnull && BaseModel

# * Relaciona orders com customers
Model:ForeignKeyField orders customers

# * Relaciona orders com products
Model:ForeignKeyField orders products
```

A estrutura final pode ser representada da seguinte maneira:

```text id="b2m8vq"
customers
    │
    │ Foreign Key
    ▼
 orders
    ▲
    │ Foreign Key
    │
products
```

As Foreign Keys permitem que o banco mantenha referências entre os
Models, formando a estrutura relacional da aplicação.
