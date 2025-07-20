-- População de dados na base de dados com correções

-- Inserir entidades (genéricas, clientes e fornecedores)
INSERT INTO entidade (nif, nome, morada, contacto) VALUES
('123456789', 'Entidade Exemplo', 'Rua A, 1', '912345678'),
('987654321', 'Fornecedor Exemplo', 'Rua B, 2', '987654321'),
('111111111', 'João Silva', 'Rua C, 3', '919191919'),
('222222222', 'Ana Maria', 'Rua D, 4', '929292929'),
('333333333', 'Pedro Santos', 'Rua E, 5', '939393939');

-- Inserir clientes e fornecedores com base em entidades existentes
INSERT INTO cliente (nif) VALUES ('123456789');
INSERT INTO fornecedor (nif) VALUES ('987654321');

-- Inserir ingredientes com calorias por kg/litro ajustadas
INSERT INTO ingrediente (id, nome, calorias, unidade, stock) VALUES
(1, 'Farinha', 364, 'kg', 0),
(2, 'Açúcar', 387, 'kg', 0),
(3, 'Ovos', 155 * 0.05, 'unidade', 0), -- Cada ovo pesa cerca de 50g, ajustado para calorias por unidade
(4, 'Leite', 42, 'litro', 0),
(5, 'Manteiga', 717, 'kg', 0);

-- Inserir compras e atualizar estoque de ingredientes
INSERT INTO compra (id, ingrediente_id, fornecedor_id, quantidade, precoKg) VALUES
(1, 1, '987654321', 100, 0.5),
(2, 2, '987654321', 50, 0.8),
(3, 3, '987654321', 200, 0.2),
(4, 4, '987654321', 100, 0.6),
(5, 5, '987654321', 20, 5.0);

-- Atualizar estoque de ingredientes
UPDATE ingrediente SET stock = stock + (
    SELECT SUM(quantidade) FROM compra WHERE compra.ingrediente_id = ingrediente.id
);

-- Inserir produtos
INSERT INTO produto (id, nome, precoAvulso, precoQuantidade, limiarTrocaPreco, calorias) VALUES
(1, 'Bolo de Chocolate', 10, 8, 3, 0),
(2, 'Pão de Forma', 2, 1.5, 10, 0),
(3, 'Tarte de Limão', 12, 10, 2, 0);

-- Relacionar produtos com ingredientes e calcular calorias
INSERT INTO produto_ingrediente (produto_id, ingrediente_id, quantidade) VALUES
(1, 1, 0.3), -- 300g de farinha
(1, 2, 0.2), -- 200g de açúcar
(1, 3, 3),   -- 3 ovos
(1, 4, 0.1), -- 100ml de leite
(2, 1, 0.5), -- 500g de farinha
(2, 4, 0.2), -- 200ml de leite
(3, 1, 0.2), -- 200g de farinha
(3, 5, 0.1), -- 100g de manteiga
(3, 2, 0.1); -- 100g de açúcar

-- Calcular calorias dos produtos
UPDATE produto SET calorias = (
    SELECT SUM(pi.quantidade * i.calorias)
    FROM produto_ingrediente pi
    JOIN ingrediente i ON pi.ingrediente_id = i.id
    WHERE pi.produto_id = produto.id
);

-- Inserir lojas
INSERT INTO loja (id, nome, morada, contacto, nfuncionarios, totalSalario) VALUES
(1, 'Loja A', 'Centro Comercial X', '917654321', 0, 0),
(2, 'Loja B', 'Centro Comercial Y', '913246578', 0, 0);

-- Inserir funcionários e associá-los a entidades e lojas
INSERT INTO funcionario (nif, loja_id, salario, dataNascimento) VALUES
('111111111', 1, 1000, '1980-05-15'),
('222222222', 1, 1200, '1990-11-20'),
('333333333', 2, 950, '1995-06-10');

-- Atualizar nfuncionarios e totalSalario das lojas
UPDATE loja SET nfuncionarios = (SELECT COUNT(*) FROM funcionario WHERE funcionario.loja_id = loja.id);
UPDATE loja SET totalSalario = (SELECT SUM(salario) FROM funcionario WHERE funcionario.loja_id = loja.id);

-- Inserir lotes e calcular validade
INSERT INTO lote (id, produto_id, dataProducao, validade, quantidade) VALUES
(1, 1, '2024-11-01', 15, 50),
(2, 2, '2024-11-10', 10, 100),
(3, 3, '2024-11-15', 7, 30);

-- Inserir lotes em lojas
INSERT INTO lote_loja (lote_id, loja_id, quantidade) VALUES
(1, 1, 30),
(1, 2, 20),
(2, 1, 50),
(2, 2, 50),
(3, 1, 15),
(3, 2, 15);

-- Inserir vendas e calcular preços
INSERT INTO venda (id, produto_id, loja_id, quantidade, preco) VALUES
(1, 1, 1, 2, 0), -- Preço a calcular
(2, 2, 2, 15, 0), -- Preço a calcular
(3, 3, 1, 5, 0); -- Preço a calcular

-- Atualizar preços das vendas
UPDATE venda SET preco = CASE
    WHEN quantidade < (SELECT limiarTrocaPreco FROM produto WHERE produto.id = venda.produto_id)
    THEN quantidade * (SELECT precoAvulso FROM produto WHERE produto.id = venda.produto_id)
    ELSE quantidade * (SELECT precoQuantidade FROM produto WHERE produto.id = venda.produto_id)
END;