pragma foreign_keys = on;

.mode box
.headers yes

drop table if exists venda;
drop table if exists lote_loja;
drop table if exists lote_compra;
drop table if exists lote;
drop table if exists funcionario;
drop table if exists loja;
drop table if exists produto_ingrediente;
drop table if exists produto;
drop table if exists compra;
drop table if exists ingrediente;
drop table if exists fornecedor;
drop table if exists cliente;
drop table if exists entidade;

create table entidade (
    nif varchar(9) primary key not null,
    nome text not null,
    morada text not null,
    contacto varchar(9) not null,
    -- Numbers with a fixed length (i.e., nif, nib, etc.) were stored as
    -- text, since it is not possible to enforce the constraint on numbers
    -- with leading zeroes otherwise. `numeric(9, 0)` isn't enforced in sqlite3.
    constraint nif_digitos check(length(nif) = 9),
    constraint contacto_digitos check (length(contacto) = 9)
);

create table cliente (
    nif text primary key not null,
    constraint fk_cliente_entidade foreign key (nif) references entidade(nif)
);

create table fornecedor (
    nif varchar(9) primary key not null,
    nib varchar(21) not null,
    constraint fk_fornecedor_entidade foreign key (nif) references entidade(nif),
    constraint nib_digitos check (length(nib) = 21)
);

create table ingrediente (
    id integer primary key autoincrement not null,
    nome text not null,
    alergenio integer not null,
    calorias integer not null,
    stock integer default 0 not null,
    constraint alergenio_is_boolean check (alergenio = false or alergenio = true)
);

create table compra (
    id integer primary key autoincrement not null,
    ingrediente integer not null,
    fornecedor integer not null,
    data integer not null,
    quantidade real not null,
    precoKg real not null,
    preco real not null,
    constraint fk_compra_ingrediente foreign key (ingrediente) references ingrediente(id),
    constraint fk_compra_fornecedor foreign key (fornecedor) references fornecedor(nif)
);

create table produto (
    id integer primary key autoincrement not null,
    nome text not null,
    familia text not null,
    precoAvulso real not null, 
    precoQuantidade real not null,
    limiarTrocaPreco integer not null,
    validade integer not null,
    calorias integer not null,
    constraint familia_valida check (familia in ('Pastelaria', 'Padaria', 'Confeitaria')),
    constraint quantidade_mais_barato check (precoQuantidade <= precoAvulso)
);

create table produto_ingrediente (
    produto integer not null,
    ingrediente integer not null,
    quantidade integer not null,
    primary key (produto, ingrediente),
    constraint fk_produto_ingrediente_produto foreign key (produto) references produto(id),
    constraint fk_produto_ingrediente_ingrediente foreign key (ingrediente) references ingrediente(id)
);

create table loja (
    id integer primary key autoincrement not null,
    morada text not null,
    contacto integer not null,
    nfuncionarios integer not null,
    totalSalario integer not null
);

create table funcionario (
    nif varchar(9) primary key not null,
    cargo text not null,
    salario integer not null,
    dataNascimento integer not null,
    dataInicioContrato integer not null,
    idade integer not null,
    loja integer not null,
    constraint fk_funcionario_entidade foreign key (nif) references entidade(nif),
    constraint fk_funcionario_loja foreign key (loja) references loja(id),
    constraint cargo_valido check (cargo in ('Balcão', 'Cozinha', 'Cafetaria'))
);

create table lote (
    id integer primary key autoincrement not null,
    produto integer not null,
    funcionario integer not null,
    quantidade integer not null,
    dataProducao integer not null,
    dataValidade integer not null,
    constraint fk_lote_produto foreign key (produto) references produto(id),
    constraint fk_lote_funcionario foreign key (funcionario) references funcionario(nif)
);

create table lote_compra (
    lote integer not null,
    compra integer not null,
    primary key (lote, compra),
    constraint fk_lote_compra_lote foreign key (lote) references lote(id),
    constraint fk_lote_compra_compra foreign key (compra) references compra(id)
);

create table lote_loja (
    lote integer primary key not null,
    loja integer not null,
    stock integer not null,
    constraint fk_lote_loja_lote foreign key (lote) references lote(id),
    constraint fk_lote_loja_loja foreign key (loja) references loja(id)
);

create table venda (
    id integer primary key autoincrement not null,
    lote integer not null,
    funcionario integer not null,
    cliente integer not null,
    quantidade integer not null,
    data integer not null,
    preco integer not null,
    constraint fk_venda_lote foreign key (lote) references lote(id),
    constraint fk_venda_funcionario foreign key (funcionario) references funcionario(nif),
    constraint fk_venda_cliente foreign key (cliente) references cliente(nif)
);
