# Models

Os Models são utilizados para representar as tabelas do banco de dados dentro
da biblioteca Turtle.

A definição de um Model começa com a criação de uma tabela através de
`SqliteDatabase:create`. Após definir ou modificar um Model, `BaseModel`
é responsável por processar as definições e aplicar as alterações no banco
de dados.

## Inicialização do Banco

Antes de criar um Model, é necessário inicializar o banco de dados.

O nome do banco é definido através de uma variável e passado para
`SqliteDatabase`.

```bash
#!/usr/bin/env bash

# * Importa o Turtle ORM
source "/home/$USER/.local/share/turtle/orm.sh"

# * Define o nome do banco de dados
db="shop"

# * Cria ou inicializa o banco de dados SQLite
SqliteDatabase "${db}"
```

## Criando um Model

Um Model pode ser criado utilizando `SqliteDatabase:create`.

### Sintaxe

```bash
SqliteDatabase:create <tablename> && BaseModel
```

O argumento `<tablename>` representa o nome da tabela que será criada
no banco de dados.

```bash
# * Cria o Model customers
SqliteDatabase:create customers && BaseModel

# * Cria o Model products
SqliteDatabase:create products && BaseModel
```

Nesse exemplo, o Turtle cria as tabelas `customers` e `products`.

## Processando um Model

`BaseModel` é utilizado para processar as definições realizadas através
das funções `Model:*`.

Por exemplo, depois de criar uma tabela, um campo pode ser adicionado
e processado através de `BaseModel`.

```bash
# * Cria a tabela customers
SqliteDatabase:create customers && BaseModel

# * Adiciona um campo ao Model
Model:TextField customers name notnull && BaseModel
```

O fluxo utilizado pelo Turtle é:

```text
SqliteDatabase:create
        ↓
     Model:*
        ↓
    BaseModel
        ↓
      SQLite
```

## Criando Múltiplos Models

É possível definir vários Models no mesmo banco de dados.

```bash
# * Cria o Model customers
SqliteDatabase:create customers && BaseModel

# * Cria o Model products
SqliteDatabase:create products && BaseModel

# * Cria o Model orders
SqliteDatabase:create orders && BaseModel
```

Cada Model representa uma tabela independente dentro do banco de dados.

## Model com Campos

Depois de criar um Model, seus campos podem ser definidos através das
funções `Model:*Field`.

```bash
# * Cria a tabela customers
SqliteDatabase:create customers && BaseModel

# * Define os campos do Model
Model:TextField customers name notnull && BaseModel
Model:TextField customers email unique notnull && BaseModel
Model:IntegerField customers age && BaseModel
```

O resultado é um Model equivalente à seguinte estrutura:

```text
customers
├── id
├── name
├── email
└── age
```

A coluna `id` é criada por padrão como `PRIMARY KEY`.

## Model e Banco de Dados

O Model não representa um banco de dados separado. Todos os Models
definidos após a inicialização de `SqliteDatabase` pertencem ao banco
de dados atualmente selecionado.

```bash
# * Inicializa o banco de dados
db="shop"
SqliteDatabase "${db}"

# * Define os Models do banco
SqliteDatabase:create customers && BaseModel
SqliteDatabase:create products && BaseModel
SqliteDatabase:create orders && BaseModel
```

Nesse caso, as três tabelas pertencem ao banco `shop`.

## Exemplo Completo

O exemplo abaixo demonstra a criação de um banco com múltiplos Models
e a definição inicial de seus campos.

```bash
#!/usr/bin/env bash

# * Importa o Turtle ORM
source "/home/$USER/.local/share/turtle/orm.sh"

# * Define o banco de dados
db="shop"

# * Inicializa o banco
SqliteDatabase "${db}"

# * Cria o Model customers
SqliteDatabase:create customers && BaseModel

# * Define os campos de customers
Model:TextField customers name notnull && BaseModel
Model:TextField customers email unique notnull && BaseModel

# * Cria o Model products
SqliteDatabase:create products && BaseModel

# * Define os campos de products
Model:TextField products name notnull && BaseModel
Model:RealField products price notnull && BaseModel
Model:IntegerField products stock notnull && BaseModel

# * Cria o Model orders
SqliteDatabase:create orders && BaseModel

# * Define os campos de orders
Model:IntegerField orders quantity notnull && BaseModel
Model:RealField orders total notnull && BaseModel
```

Após a execução, o banco possuirá três Models:

```text
shop
├── customers
├── products
└── orders
```

Cada tabela pode posteriormente receber Fields, Constraints,
Relationships e outras definições disponíveis na biblioteca.
