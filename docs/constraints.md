# Constraints

Constraints são regras utilizadas para controlar os valores armazenados
nas tabelas do banco de dados.

No Turtle, algumas Constraints podem ser definidas diretamente durante
a criação de um Field.

## Sintaxe

As Constraints são informadas após o nome da coluna.

```bash
Model:<FieldType> <tablename> <columnname> <constraint>
```

Mais de uma Constraint pode ser utilizada no mesmo Field.

```bash
Model:<FieldType> <tablename> <columnname> <constraint1> <constraint2>
```

Por exemplo:

```bash
# * Cria uma coluna TEXT que não aceita valores NULL
# * e não permite valores duplicados
Model:TextFiled customers email unique notnull && BaseModel
```

## UNIQUE

A Constraint `unique` garante que os valores armazenados em uma coluna
não sejam duplicados.

```bash
# * Cria uma coluna TEXT com valores únicos
Model:TextFiled customers email unique && BaseModel
```

Nesse exemplo, cada cliente deve possuir um valor diferente na coluna
`email`.

Uma tentativa de inserir outro registro com o mesmo valor será rejeitada
pelo SQLite.

### Exemplo

```bash
# * Primeiro registro
SqliteDatabase:insert customers email "paulo@example.com" && BaseModel

# * Segundo registro utilizando o mesmo email
# * O SQLite rejeitará o valor duplicado.
SqliteDatabase:insert customers email "paulo@example.com" && BaseModel
```

## NOT NULL

A Constraint `notnull` impede que uma coluna receba o valor `NULL`.

```bash
# * Cria uma coluna TEXT que não aceita NULL
Model:TextFiled customers name notnull && BaseModel
```

Essa Constraint é útil para campos que são obrigatórios.

### Exemplo

```bash
# * O campo name é obrigatório
Model:TextFiled customers name notnull && BaseModel
```

## UNIQUE + NOT NULL

As Constraints podem ser combinadas.

```bash
# * O email é obrigatório e não pode ser duplicado
Model:TextFiled customers email unique notnull && BaseModel
```

Nesse caso, a coluna possui duas regras:

```text
email
├── NOT NULL
└── UNIQUE
```

O valor deve existir e também deve ser único.

## PRIMARY KEY

A `PRIMARY KEY` identifica exclusivamente cada registro de uma tabela.

No Turtle, as tabelas possuem uma coluna `id` configurada como
`PRIMARY KEY` por padrão.

```text
customers
├── id          PRIMARY KEY
├── name        TEXT
└── email       TEXT
```

A chave primária pode ser utilizada para identificar um registro
específico.

```bash
# * Atualiza o registro identificado pelo ID 1
SqliteDatabase:update customers name "Paulo Santos" 1 && BaseModel

# * Remove o registro identificado pelo ID 1
SqliteDatabase:delete customers 1
```

> A definição automática da `PRIMARY KEY` faz parte do comportamento
> padrão do Model no Turtle.

## FOREIGN KEY

A `FOREIGN KEY` estabelece uma relação entre duas tabelas.

No Turtle, essa relação é criada utilizando `Model:ForeignKeyField`.

```bash
# * Cria a tabela customers
SqliteDatabase:create customers && BaseModel

# * Cria a tabela orders
SqliteDatabase:create orders && BaseModel

# * Cria uma referência entre orders e customers
Model:ForeignKeyField orders customers
```

Nesse exemplo, `orders` possui uma referência para `customers`.

A documentação detalhada sobre relacionamentos pode ser encontrada em
[Relationships](relationships.md).

## DEFAULT

`DEFAULT` define um valor padrão para uma coluna quando nenhum valor
é informado durante a inserção.

Por exemplo, uma aplicação pode utilizar `0` como valor inicial
para o estoque de um produto.

```text
products
├── id
├── name
└── stock    DEFAULT 0
```

> A utilização de `DEFAULT` depende do suporte correspondente
> implementado pelo Turtle.

## CHECK

`CHECK` permite definir uma condição que os valores da coluna ou da tabela
devem respeitar.

Por exemplo, uma aplicação pode exigir que o preço de um produto seja
maior ou igual a zero.

```text
products
├── id
├── name
└── price    CHECK price >= 0
```

> A utilização de `CHECK` depende do suporte correspondente
> implementado pelo Turtle.

## Combinando Constraints

As Constraints podem ser combinadas quando fizer sentido para o campo.

```bash
# * O nome é obrigatório
Model:TextFiled customers name notnull && BaseModel

# * O email é obrigatório e único
Model:TextFiled customers email unique notnull && BaseModel

# * O estoque é obrigatório
Model:IntegerFiled products stock notnull && BaseModel
```

## Exemplo Completo

O exemplo abaixo utiliza diferentes Constraints em um pequeno esquema.

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

# * Define um campo obrigatório
Model:TextFiled customers name notnull && BaseModel

# * Define um campo obrigatório e único
Model:TextFiled customers email unique notnull && BaseModel

# * Cria a tabela products
SqliteDatabase:create products && BaseModel

# * Define um nome obrigatório
Model:TextFiled products name notnull && BaseModel

# * Define um preço obrigatório
Model:RealFiled products price notnull && BaseModel

# * Define um estoque obrigatório
Model:IntegerFiled products stock notnull && BaseModel

# * Cria a relação entre orders e customers
SqliteDatabase:create orders && BaseModel
Model:ForeignKeyField orders customers
```

## Resumo

| Constraint    | Finalidade                             |
| ------------- | -------------------------------------- |
| `UNIQUE`      | Impede valores duplicados              |
| `NOT NULL`    | Impede valores `NULL`                  |
| `PRIMARY KEY` | Identifica exclusivamente um registro  |
| `FOREIGN KEY` | Cria uma relação entre tabelas         |
| `DEFAULT`     | Define um valor padrão                 |
| `CHECK`       | Valida valores através de uma condição |

As Constraints permitem que as regras de integridade sejam definidas
na estrutura do banco, reduzindo a necessidade de realizar todas as
validações manualmente na aplicação.
