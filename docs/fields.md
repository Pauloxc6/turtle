# Fields

Os Fields são responsáveis por definir as colunas de um Model.

Cada Field possui um tipo de dado e um nome. Algumas definições também podem
receber propriedades adicionais, como `unique` e `notnull`.

## Sintaxe

A definição de um Field segue o seguinte formato:

```bash
Model:<FieldType> <tablename> <columnname> [options]
```

Onde:

* `<FieldType>` representa o tipo do campo;
* `<tablename>` representa a tabela onde o campo será criado;
* `<columnname>` representa o nome da coluna;
* `[options]` representa propriedades opcionais do campo.

Após definir um field, `BaseModel` processa a alteração.

```bash
Model:TextField customers name && BaseModel
```

## TEXT

`Model:TextField` cria uma coluna do tipo `TEXT`.

### Sintaxe

```bash
Model:TextField <tablename> <columnname> [options]
```

### Exemplo

```bash
# * Cria uma coluna TEXT na tabela customers
Model:TextField customers name && BaseModel

# * Cria uma coluna TEXT para armazenar o email
Model:TextField customers email && BaseModel
```

## INTEGER

`Model:IntegerField` cria uma coluna do tipo `INTEGER`.

### Sintaxe

```bash
Model:IntegerField <tablename> <columnname> [options]
```

### Exemplo

```bash
# * Cria uma coluna INTEGER para armazenar a idade
Model:IntegerField customers age && BaseModel

# * Cria uma coluna INTEGER para armazenar o estoque
Model:IntegerField products stock && BaseModel
```

## REAL

`Model:RealField` cria uma coluna do tipo `REAL`.

### Sintaxe

```bash
Model:RealField <tablename> <columnname> [options]
```

### Exemplo

```bash
# * Cria uma coluna REAL para armazenar o preço
Model:RealField products price && BaseModel

# * Cria uma coluna REAL para armazenar o peso
Model:RealField products weight && BaseModel
```

## BLOB

`Model:BlobField` cria uma coluna do tipo `BLOB`.

### Sintaxe

```bash
Model:BlobField <tablename> <columnname> [options]
```

### Exemplo

```bash
# * Cria uma coluna BLOB para armazenar dados binários
Model:BlobField products image && BaseModel
```

## Propriedades

Os Fields podem receber propriedades adicionais para modificar as
restrições da coluna.

As propriedades são informadas após o nome da coluna.

```bash
Model:TextField <tablename> <columnname> <option>
```

## UNIQUE

A propriedade `unique` define que os valores da coluna devem ser únicos.

```bash
# * Cria uma coluna TEXT com valores únicos
Model:TextField customers email unique && BaseModel
```

Nesse exemplo, dois registros não podem possuir o mesmo valor na coluna
`email`.

## NOT NULL

A propriedade `notnull` define que a coluna não pode receber valores
`NULL`.

```bash
# * Cria uma coluna TEXT que não aceita NULL
Model:TextField customers name notnull && BaseModel
```

## UNIQUE + NOT NULL

As propriedades podem ser combinadas no mesmo Field.

```bash
# * Cria uma coluna TEXT que não aceita NULL
# * e também exige valores únicos
Model:TextField customers email unique notnull && BaseModel
```

Nesse caso, o valor da coluna deve ser preenchido e não pode ser repetido.

## Propriedades em Outros Tipos

As propriedades podem ser utilizadas nos diferentes tipos de Fields
suportados pelo Turtle.

```bash
# * TEXT
Model:TextField customers email unique notnull && BaseModel

# * INTEGER
Model:IntegerField products stock notnull && BaseModel

# * REAL
Model:RealField products price notnull && BaseModel

# * BLOB
Model:BlobField products image && BaseModel
```

## Exemplo Completo

O exemplo abaixo utiliza diferentes tipos de Fields para definir
as tabelas de uma pequena aplicação.

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

# * Define os campos de customers
Model:TextField customers name notnull && BaseModel
Model:TextField customers email unique notnull && BaseModel
Model:IntegerField customers age && BaseModel

# * Cria a tabela products
SqliteDatabase:create products && BaseModel

# * Define os campos de products
Model:TextField products name notnull && BaseModel
Model:RealField products price notnull && BaseModel
Model:IntegerField products stock notnull && BaseModel
Model:BlobField products image && BaseModel
```

Após o processamento, as tabelas terão a seguinte estrutura conceitual:

```text
customers
├── id
├── name       TEXT NOT NULL
├── email      TEXT UNIQUE NOT NULL
└── age        INTEGER

products
├── id
├── name       TEXT NOT NULL
├── price      REAL NOT NULL
├── stock      INTEGER NOT NULL
└── image      BLOB
```

## Resumo

| Função               | SQLite    | Descrição        |
| -------------------- | --------- | ---------------- |
| `Model:TextField`    | `TEXT`    | Texto            |
| `Model:IntegerField` | `INTEGER` | Números inteiros |
| `Model:RealField`    | `REAL`    | Números reais    |
| `Model:BlobField`    | `BLOB`    | Dados binários   |

As propriedades atualmente utilizadas pelos Fields são:

| Propriedade | SQLite     | Descrição                 |
| ----------- | ---------- | ------------------------- |
| `unique`    | `UNIQUE`   | Impede valores duplicados |
| `notnull`   | `NOT NULL` | Impede valores `NULL`     |

Mais propriedades podem ser adicionadas ao Turtle conforme a implementação
da biblioteca evoluir.
