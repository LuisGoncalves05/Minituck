PRAGMA foreign_keys = ON;

CREATE TABLE Entidade (
    nif CHAR(9) PRIMARY KEY CHECK (LENGTH(nif) = 9),
    nome TEXT NOT NULL,
    morada TEXT,
    contacto CHAR(9) CHECK (LENGTH(contacto) = 9)
);

CREATE TABLE Cliente (
    nif CHAR(9) PRIMARY KEY,
    FOREIGN KEY (nif) REFERENCES Entidade(nif)
);

CREATE TABLE Fornecedor (
    nif CHAR(9) PRIMARY KEY,
    nib CHAR(21) CHECK (LENGTH(nib) = 21),
    FOREIGN KEY (nif) REFERENCES Entidade(nif)
);

CREATE TABLE Ingrediente (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL,
    alergenio TEXT,
    calorias INTEGER CHECK (calorias >= 0),
    stock INTEGER CHECK (stock >= 0)
);

CREATE TABLE Compra (
    id INTEGER PRIMARY KEY,
    ingrediente INTEGER NOT NULL,
    fornecedor CHAR(9) NOT NULL,
    data DATE NOT NULL,
    quantidade INTEGER CHECK (quantidade > 0),
    precoKg REAL CHECK (precoKg >= 0),
    preco REAL CHECK (preco >= 0),
    FOREIGN KEY (ingrediente) REFERENCES Ingrediente(id),
    FOREIGN KEY (fornecedor) REFERENCES Fornecedor(nif)
);

CREATE TABLE Produto (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL,
    precoAvulso REAL CHECK (precoAvulso >= 0),
    precoQuantidade REAL CHECK (precoQuantidade >= 0),
    limiarTrocaPreco INTEGER CHECK (limiarTrocaPreco >= 0),
    familia TEXT CHECK (familia IN ('Padaria', 'Pastelaria', 'Confeitaria')),
    validade DATE NOT NULL,
    calorias INTEGER CHECK (calorias >= 0),
    CHECK (precoAvulso >= precoQuantidade)
);

CREATE TABLE ProdutoIngrediente (
    produto INTEGER NOT NULL,
    ingrediente INTEGER NOT NULL,
    quantidade INTEGER CHECK (quantidade > 0),
    PRIMARY KEY (produto, ingrediente),
    FOREIGN KEY (produto) REFERENCES Produto(id),
    FOREIGN KEY (ingrediente) REFERENCES Ingrediente(id)
);

CREATE TABLE Loja (
    id INTEGER PRIMARY KEY,
    morada TEXT NOT NULL,
    contacto CHAR(9) CHECK (LENGTH(contacto) = 9),
    numFuncionarios INTEGER CHECK (numFuncionarios >= 0),
    totalSalario REAL CHECK (totalSalario >= 0)
);

CREATE TABLE Funcionario (
    nif CHAR(9) PRIMARY KEY,
    cargo TEXT NOT NULL,
    salario REAL CHECK (salario >= 0),
    dataNascimento DATE NOT NULL,
    dataInicioContrato DATE NOT NULL,
    idade INTEGER CHECK (idade >= 18),
    loja INTEGER,
    FOREIGN KEY (nif) REFERENCES Entidade(nif),
    FOREIGN KEY (loja) REFERENCES Loja(id)
);

CREATE TABLE Lote (
    id INTEGER PRIMARY KEY,
    produto INTEGER NOT NULL,
    funcionario CHAR(9) NOT NULL,
    quantidade INTEGER CHECK (quantidade > 0),
    dataProducao DATE NOT NULL,
    dataValidade DATE NOT NULL,
    FOREIGN KEY (produto) REFERENCES Produto(id),
    FOREIGN KEY (funcionario) REFERENCES Funcionario(nif)
);

CREATE TABLE LoteCompra (
    lote INTEGER NOT NULL,
    compra INTEGER NOT NULL,
    PRIMARY KEY (lote, compra),
    FOREIGN KEY (lote) REFERENCES Lote(id),
    FOREIGN KEY (compra) REFERENCES Compra(id)
);

CREATE TABLE LoteLoja (
    lote INTEGER NOT NULL,
    loja INTEGER NOT NULL,
    stock INTEGER CHECK (stock >= 0),
    PRIMARY KEY (lote, loja),
    FOREIGN KEY (lote) REFERENCES Lote(id),
    FOREIGN KEY (loja) REFERENCES Loja(id)
);

CREATE TABLE Venda (
    id INTEGER PRIMARY KEY,
    lote INTEGER NOT NULL,
    loja INTEGER NOT NULL,
    funcionario CHAR(9) NOT NULL,
    cliente CHAR(9),
    quantidade INTEGER CHECK (quantidade > 0),
    data DATE NOT NULL,
    preco REAL CHECK (preco >= 0),
    FOREIGN KEY (lote) REFERENCES Lote(id),
    FOREIGN KEY (loja) REFERENCES Loja(id),
    FOREIGN KEY (funcionario) REFERENCES Funcionario(nif),
    FOREIGN KEY (cliente) REFERENCES Cliente(nif),
    CHECK (quantidade <= (SELECT quantidade FROM Lote WHERE Lote.id = lote)),
    CHECK (data >= (SELECT dataProducao FROM Lote WHERE Lote.id = lote))
);
