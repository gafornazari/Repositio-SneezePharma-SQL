--inserindo fornecedores
INSERT INTO Fornecedores (RazaoSocial, Pais, DataAbertura, DataCadastro, CNPJ, Situacao)
VALUES
	('5BY5 - CONSULTORIA EM TI LTDA', 'Brasil', '2008-03-20', GETDATE(), '16598745635412', 'A'),
	('SHOPPING JARAGUA', 'Brasil', '2011-09-09', GETDATE(), '12365874568451', 'A'),
	('VENDINHA SEU ZÉ', 'Brasil', '2022-09-18', GETDATE(), '12345678910234', 'A'),
	('MERCADO TEM TUDO', 'Brasil', '2019-02-08', GETDATE(), '98745632102365', 'I'),
	('SHOPPING LUPO', 'Brasil', '2018-10-31', GETDATE(), '65874697548965', 'A'),
	('EXTRA', 'Brasil', '2022-08-12', GETDATE(), '03258749658741', 'A');

--alterando a situação do fornecedor
UPDATE Fornecedores
SET Situacao = 'A'
WHERE idFornecedor = 4;
SELECT * FROM Fornecedores;


--inserindo fornecedores bloqueados
INSERT INTO FornecedoresBloqueados(idFornecedor)
VALUES
	(4), (6);
SELECT * FROM FornecedoresBloqueados;

--inserindo principios ativos
INSERT INTO PrincipiosAtivos(DataCadastro, Nome, Situacao)
VALUES
	(GETDATE(), 'Citrato de Orfenadrina', 'A'),
	(GETDATE(), 'Dipirona Monoidratada', 'A'),
	(GETDATE(), 'Ácido Ascórbico', 'A'),
	(GETDATE(), 'Colecalciferol', 'A');
SELECT * FROM PrincipiosAtivos;

--inserindo compras
INSERT INTO Compras(Datacompra, idFornecedor)
VALUES
	(GETDATE(), 2),
	(GETDATE(), 3),
	(GETDATE(), 3),
	(GETDATE(), 5),
	(GETDATE(), 5);

--inserindo itens compras
INSERT INTO ItensCompras (idPrincipioAtivo, Quantidade, ValorUnitario)
VALUES (1, 10, 5.00),
       (2, 20, 10.00),
       (3, 30, 15.00),
       (4, 40, 20.00);
SELECT * FROM ItensCompras;

--inserindo compra itens compra
INSERT INTO Compras_ItensCompra (idCompra, idItemCompra)
VALUES
	(1, 1),
    (1, 2),
    (1, 3);
SELECT * FROM Compras
SELECT * FROM ItensCompras
INSERT INTO Compras_ItensCompra(idCompra, idItemCompra)
VALUES
	(2, 2);
SELECT * FROM Compras_ItensCompra;

--inserindo clientes
INSERT INTO Clientes (Nome, CPF, DataCadastro, DataNascimento, Situacao)
VALUES
	('Giovanna Fornazari', '42443294803', GETDATE(), '2006/05/24', 'A'),
	('Joao Silva', '12345678934', GETDATE(), '2000/10/21', 'A'),
	('Carol Dias', '78978978978', GETDATE(), '1987/02/08', 'A'),
	('Kaio Bandeira', '12363254125', GETDATE(), '1950/12/25', 'A')
	
--alterando situacao do cliente
UPDATE Clientes
SET Situacao = 'I'
WHERE idCliente = 4
SELECT * FROM Clientes

--testando se o delete esta sendo bloqueado
DELETE FROM Clientes
WHERE idCliente = 1

--inserindo telefone para alguns clientes
INSERT INTO TelefonesClientes (Contato, idCliente)
VALUES
	('16999999999',1),
	('14963259696',1),
	('11987458585',2),
	('16996525555',3);
SELECT * FROM TelefonesClientes

--inserindo clientes restritos
INSERT INTO ClientesRestritos(idCliente)
VALUES
	(2);
SELECT * FROM ClientesRestritos

--inserindo medicamentos
INSERT INTO Medicamentos (CDB, Nome, Categoria, ValorVenda, DataCadastro, Situacao)
VALUES
	('7898626444239', 'Dorflex', 'A',15.99 , GETDATE(), 'A'),
	('7895623562541', 'Dipirona', 'A',10.99 , GETDATE(), 'A'),
	('7894561230001', 'Vitamina C', 'V',30.99 , GETDATE(), 'A'),
	('7895552226523', 'Vitamina C Power', 'V',80.99 , GETDATE(), 'A')
	
--alterando a situação dos medicamentos
UPDATE Medicamentos
SET Situacao = 'I'
WHERE idMedicamento IN (1,3)
SELECT * FROM Medicamentos

-- inserindo itens de produção
INSERT INTO ItensProducao (idPrincipioAtivo, QuantidadePA)
VALUES
	(1, 2.5),
	(2, 5.0),
	(3, 1.0),
	(4, 0.5);
SELECT * FROM ItensProducao;

-- inserindoproduções
INSERT INTO Producoes (idMedicamento, DataProducao, Quantidade)
VALUES
	(1, '2025-10-01', 1000),
	(2, '2025-10-02', 800),
	(3, '2025-10-03', 600),
	(4, '2025-10-04', 400);
SELECT * FROM Producoes;

-- producoes_itensProducao
INSERT INTO Producoes_ItensProducao (idProducao, idItemProducao)
VALUES
	(1, 1), (1, 2), (1, 2);
INSERT INTO Producoes_ItensProducao (idProducao, idItemProducao)
VALUES
	(1, 2), (2, 3), (3, 2);
SELECT * FROM Producoes_ItensProducao;

--inserindo venda
INSERT INTO VendasMedicamentos (idCliente, DataVenda)
VALUES
	(1, GETDATE());
SELECT * FROM VendasMedicamentos;

--inserindo itens venda
INSERT INTO ItensVenda (idMedicamento, Quantidade)
VALUES
	(1, 2),
	(2, 1),
	(3, 3),
	(4, 1);
SELECT * FROM ItensVenda;

--inserindo vendas_intensVenda
INSERT INTO Vendas_ItensVenda (idVenda, idItemVenda)
VALUES
	(1, 1),
	(1, 2),
	(1, 3);
SELECT * FROM Vendas_ItensVenda;