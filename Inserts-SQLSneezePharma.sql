--inserindo clientes
EXEC sp_Clientes @Nome='Giovanna Fornazari', @CPF='42443294803', @DataNascimento = '2006/05/24', @Contato = '16999999999';
EXEC sp_Clientes @Nome =N'Joao Silva', @CPF =  '12345678934', @DataNascimento ='2000/10/21', @Contato = N'14963259696';
EXEC sp_Clientes @Nome =N'Carol Dias', @CPF =  '78978978978', @DataNascimento ='1987/02/08', @Contato = N'11987458585';
EXEC sp_Clientes @Nome =N'Kaio Bandeira', @CPF =  '12363254125', @DataNascimento ='1950/12/25', @Contato = N'16996525555';

SELECT * FROM Clientes
SELECT * FROM TelefonesClientes

--alterando situacao do cliente
UPDATE Clientes
SET Situacao = 'I'
WHERE idCliente = 4
SELECT * FROM Clientes

--testando se o delete esta sendo bloqueado
DELETE FROM Clientes
WHERE idCliente = 1

--inserindo clientes restritos
INSERT INTO ClientesRestritos(idCliente)
VALUES
	(2);
SELECT * FROM ClientesRestritos

--inserindo outro telefone para o cliente de id 2
INSERT INTO TelefonesClientes (Contato, idCliente)
VALUES
	('16999995999',2)


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

--inserindo uma venda
EXEC sp_VendasMedicamentos @idCliente = 1 , @idMedicamento = 2, @Quantidade = 5;
EXEC sp_VendasMedicamentos @idCliente = 3 , @idMedicamento = 3, @Quantidade = 10;
EXEC sp_VendasMedicamentos @idCliente = 1 , @idMedicamento = 2, @Quantidade = 2;

SELECT * FROM VendasMedicamentos
SELECT * FROM Vendas_ItensVenda
SELECT * FROM ItensVenda


--inserindo fornecedores
EXEC sp_Fornecedores @RazaoSocial='5BY5 - CONSULTORIA EM TI LTDA', @CNPJ='16598745635412', @Pais='Brasil', @DataAbertura='2008-03-20';
EXEC sp_Fornecedores @RazaoSocial='SHOPPING JARAGUA', @CNPJ='12365874568451', @Pais='Brasil', @DataAbertura='2011-09-09';
EXEC sp_Fornecedores @RazaoSocial='VENDINHA SEU ZÉ', @CNPJ='12345678910234', @Pais='Brasil', @DataAbertura='2022-09-18';
EXEC sp_Fornecedores @RazaoSocial='MERCADO TEM TUDO', @CNPJ='98745632102365', @Pais='Brasil', @DataAbertura='2019-02-08';
EXEC sp_Fornecedores @RazaoSocial='SHOPPING LUPO', @CNPJ='65874697548965', @Pais='Brasil', @DataAbertura='2018-10-31';
EXEC sp_Fornecedores @RazaoSocial='EXTRA', @CNPJ='03258749658741', @Pais='Brasil', @DataAbertura='2022-08-12';

SELECT * FROM Fornecedores

--alterando a situação do fornecedor
UPDATE Fornecedores
SET Situacao = 'I'
WHERE idFornecedor = 3;
SELECT * FROM Fornecedores;

--testando se o delete está sendo bloqueado
DELETE FROM Fornecedores
WHERE idFornecedor = 1;

--inserindo fornecedores bloqueados
INSERT INTO FornecedoresBloqueados(idFornecedor)
VALUES (2);
SELECT * FROM FornecedoresBloqueados;

--inserindo princípios ativos
INSERT INTO PrincipiosAtivos(DataCadastro, Nome, Situacao)
VALUES
	(GETDATE(), 'Citrato de Orfenadrina', 'A'),
	(GETDATE(), 'Dipirona Monoidratada', 'A'),
	(GETDATE(), 'Ácido Ascórbico', 'A'),
	(GETDATE(), 'Colecalciferol', 'A');

--alterando situação de alguns princípios ativos
UPDATE PrincipiosAtivos
SET Situacao = 'I'
WHERE idPrincipioAtivo IN (1,3);
SELECT * FROM PrincipiosAtivos;

--inserindo produção
EXEC sp_Producoes
    @idPrincipioAtivo = 2,
    @idMedicamento = 4,
    @QuantidadeProducao = 20,
    @QuantidadePA = 20;

EXEC sp_Producoes
    @idPrincipioAtivo = 4,
    @idMedicamento = 2,
    @QuantidadeProducao = 27,
    @QuantidadePA = 27;

SELECT * FROM Producoes;
SELECT * FROM ItensProducao;
SELECT * FROM Producoes_ItensProducao;

--inserindo compras
EXEC sp_Compras @idPrincipioAtivo = 2, @Quantidade = 100, @ValorUnitario = 5.50, @idFornecedor = 1;
EXEC sp_Compras @idPrincipioAtivo = 4, @Quantidade = 50, @ValorUnitario = 8.00, @idFornecedor = 5;
SELECT * FROM Compras;
SELECT * FROM ItensCompras;
SELECT * FROM Compras_ItensCompra;


SELECT * FROM Clientes
SELECT * FROM ClientesRestritos
SELECT * FROM TelefonesClientes
SELECT * FROM VendasMedicamentos
SELECT * FROM ItensVenda
SELECT * FROM Vendas_ItensVenda
SELECT * FROM Medicamentos
SELECT * FROM Producoes
SELECT * FROM ItensProducao
SELECT * FROM Producoes_ItensProducao
SELECT * FROM PrincipiosAtivos
SELECT * FROM Compras
SELECT * FROM ItensCompras
SELECT * FROM Compras_ItensCompra
SELECT * FROM Fornecedores
SELECT * FROM FornecedoresBloqueados


