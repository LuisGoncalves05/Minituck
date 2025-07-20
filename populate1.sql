pragma foreign_keys = on;

insert into loja (morada, contacto, nfuncionarios, totalSalario) values
    ('R. Fonte Taurina, 42', 212327955, 0, 0);

insert into entidade (nif, nome, morada, contacto) values
    (486153456, 'Moinho', 'R. das Flores, 10', 256894620),
    (195486735, 'Tasquinha - Rest. Unipessoal', 'R. Miguel Bombarda, 50', 268425623),
    (753456826, 'Galinhas & CA LDA', 'R. Cortinha, 650', 230156485),
    (254851346, 'João Silva', 'R. Inclinada, 1600, 5º esq', 966723654),
    (264983561, 'GygaMercado SA', 'Av. Virtudes, 90', 256761350),
    (257956123, 'Maria Cotovia', 'R. Forças Armadas, 49', 924165777),
    (259486157, 'Luís Quarto', 'R. Riamar, 113', 912654263);

insert into cliente values
    (254851346),
    (195486735),
    (264983561);

insert into fornecedor (nif, nib) values
    (486153456, '005985784089957294657'),
    (753456826, '005998770603788830435'),
    (264983561, '000766532426590721086');

insert into funcionario (nif, loja, cargo, salario, dataNascimento, dataInicioContrato, idade) values
    (259486157, 1, 'Balcão', 1100.0, strftime('%F', '2001-11-05'), strftime('%F', '2022-12-04'), strftime('%Y', '0000-01-01', timediff('now', '2001-11-05'))),
    (257956123, 1, 'Cozinha', 1400.0, strftime('%F', '1992-03-29'), strftime('%F', '2018-11-15'), strftime('%Y', '0000-01-01', timediff('now', '1992-03-29')));
    --datas em ISO-8601

update loja
set nfuncionarios = nfuncionarios + count(*)
from funcionario
where funcionario.loja = loja.id;

update loja 
set totalSalario = totalSalario + funcionario.salario 
from funcionario 
where funcionario.loja = loja.id;
 
insert into ingrediente (nome, alergenio, calorias) values
    ('Farinha de Pão de Água', 1, 3640),
    ('Farinha de Trigo', 1, 3640),
    ('Margarina', 0, 5300),
    ('Gema', 1, 3220),
    ('Ovo', 1, 1550),
    ('Frango', 0, 2390),
    ('Leite', 0, 420),
    ('Chocolate', 0, 5350),
    ('Açúcar', 0, 3870),
    ('Sal', 0, 0),
    ('Fermento', 0, 530);

insert into produto (nome, familia, precoAvulso, precoQuantidade, limiarTrocaPreco, validade, calorias) values 
    ('Pão de Lenha', 'Padaria', 2.40, 1.40, 10, '365 days', 0),
    ('Pastel de Nata', 'Pastelaria', 0.80, 0.40, 80, '365 days', 0),
    ('Empada de Frango', 'Pastelaria', 0.90, 0.75, 80, '182 days', 0),
    ('Bolo de Chocolate', 'Confeitaria', 15.00, 15.00, 1, '365 days', 0);

insert into produto_ingrediente (produto, ingrediente, quantidade) values
    -- Pão de Lenha
    (1, 1, 0.75), 
    (1, 3, 0.03),
    (1, 10, 0.01),
    (1, 11, 0.01),
    -- Pastel de Nata
    (2, 2, 0.04),
    (2, 3, 0.015),
    (2, 4, 0.015),
    (2, 9, 0.03),
    (2, 10, 0.0005),
    -- Empada de Frango
    (3, 2, 0.035),
    (3, 3, 0.015),
    (3, 6, 0.04),
    (3, 10, 0.001),
    -- Bolo de Chocolate
    (4, 2, 1.25),
    (4, 7, 0.15),
    (4, 8, 0.15),
    (4, 9, 0.2);

update produto
set calorias = (
    select(sum(ingrediente.calorias * produto_ingrediente.quantidade))
    from produto_ingrediente, ingrediente
    where produto_ingrediente.ingrediente = ingrediente.id and produto_ingrediente.produto = produto.id);

-- compra de ingredientes
insert into compra (ingrediente, fornecedor, data, quantidade, precoKg, preco) values
    (2, 486153456, strftime('%F', '2024-11-09'), 200.0, 0.45, 0),
    (3, 264983561, strftime('%F', '2024-11-09'), 50.0, 2.50, 0),
    (4, 753456826, strftime('%F', '2024-11-02'), 50.0, 9.00, 0),
    (6, 264983561, strftime('%F', '2024-11-02'), 80.0, 0.5, 0),
    (9, 264983561, strftime('%F', '2024-10-26'), 100.0, 0.15, 0),
    (10, 264983561, strftime('%F', '2024-10-26'), 20.0, 1.0, 0);
    
update compra
set preco = (quantidade * precoKg);

update ingrediente
set stock = stock + compra.quantidade
from compra where ingrediente.id = compra.ingrediente;

--fabrico de produtos
insert into lote (produto, funcionario, quantidade, dataProducao, dataValidade) values 
    (3, 257956123, 1600, strftime('%F', '2024-11-11'), strftime('%F', 'now')),
    (2, 257956123, 1600, strftime('%F', '2024-11-12'), strftime('%F', 'now'));

update lote
set dataValidade = strftime('%F', dataProducao, produto.validade)
from produto
where lote.produto = produto.id;

update ingrediente
set stock = stock - produto_ingrediente.quantidade * lote.quantidade
from produto_ingrediente, lote
where produto_ingrediente.produto = lote.produto and produto_ingrediente.ingrediente = ingrediente.id;

insert into lote_compra (lote, compra) values
    (1, 1), (1, 2), (1, 4), (1, 6),
    (2, 1), (2, 2), (2, 3), (2, 5), (2, 6); 

insert into lote_loja (lote, loja, stock) values
    (1, 1, 0),
    (2, 1, 0);

update lote_loja
set stock = lote.quantidade
from lote
where lote_loja.lote = lote.id;

--venda de produtos
insert into venda (lote, funcionario, cliente, quantidade, data, preco) values
    (1, 259486157, 195486735, 1000, strftime('%F', '2024-11-24'), 0),
    (1, 259486157, 254851346, 2, strftime('%F', '2024-11-26'), 0);

update venda
set preco = (
    select preco * venda.quantidade
    from (
        select venda.id as venda_id, produto.precoAvulso as preco, venda.quantidade
        from venda, produto, lote
        where venda.lote = lote.id and lote.produto = produto.id and venda.quantidade < produto.limiarTrocaPreco
        union
        select venda.id as venda_id, produto.precoQuantidade as preco, venda.quantidade
        from venda, produto, lote
        where venda.lote = lote.id and lote.produto = produto.id and venda.quantidade >= produto.limiarTrocaPreco)
    where venda.id = venda_id);

update lote_loja
set stock = lote_loja.stock - venda.quantidade
from venda
where venda.lote = lote_loja.loja;
