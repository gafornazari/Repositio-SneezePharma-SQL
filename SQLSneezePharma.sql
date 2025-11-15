CREATE DATABASE SneezePharma;

USE SneezePharma;

CREATE TABLE Clientes(
	idCliente INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nome NVARCHAR(255) NOT NULL,
	CPF VARCHAR(11) NOT NULL UNIQUE,
	DataCadastro DATE NOT NULL,
	DataNascimento DATE NOT NULL,
	UltimaCompra DATE,
	Situacao CHAR NOT NULL
);

CREATE TABLE ClientesRestritos(
	idClientesRestritos INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idCliente INT NOT NULL
);

CREATE TABLE TelefonesClientes(
	idTelefoneCliente INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idCliente INT NOT NULL,
	Contato NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE VendasMedicamentos(
	idVenda INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idCliente INT NOT NULL,
	DataVenda DATE NOT NULL
);

CREATE TABLE Vendas_ItensVenda(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idVenda INT NOT NULL,
	idItemVenda INT NOT NULL
);

CREATE TABLE ItensVenda(
	idItemVenda INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idMedicamento INT NOT NULL,
	Quantidade INT NOT NULL
);

CREATE TABLE Medicamentos(
	idMedicamento INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	CDB VARCHAR(13) NOT NULL UNIQUE,
	Nome NVARCHAR(255) NOT NULL,
	Categoria CHAR NOT NULL,
	ValorVenda FLOAT NOT NULL,
	UltimaVenda DATE,
	DataCadastro DATE NOT NULL,
	Situacao CHAR NOT NULL
);

CREATE TABLE Producoes(
	idProducao INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idMedicamento INT NOT NULL,
	DataProducao DATE NOT NULL,
	Quantidade INT NOT NULL
);

CREATE TABLE Producoes_ItensProducao(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idProducao INT NOT NULL,
	idItemProducao INT NOT NULL
);

CREATE TABLE ItensProducao(
	idItemProducao INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idPrincipioAtivo INT NOT NULL,
	QuantidadePA FLOAT NOT NULL
);

CREATE TABLE Fornecedores(
	idFornecedor INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	RazaoSocial NVARCHAR(255) NOT NULL,
	Pais NVARCHAR(255) NOT NULL,
	DataAbertura DATE NOT NULL,
	DataCadastro DATE NOT NULL,
	CNPJ VARCHAR(14) NOT NULL UNIQUE,
	UltimoFornecimento DATE,
	Situacao CHAR NOT NULL
);

CREATE TABLE FornecedoresBloqueados(
	idFornecedorBloqueado INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idFornecedor INT NOT NULL
);

CREATE TABLE Compras(
	idCompra INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DataCompra DATE NOT NULL,
	idFornecedor INT NOT NULL
);

CREATE TABLE ItensCompras(
	idItemCompra INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idPrincipioAtivo INT NOT NULL,
	Quantidade INT NOT NULL,
	ValorUnitario FLOAT NOT NULL
);

CREATE TABLE Compras_ItensCompra(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idCompra INT NOT NULL ,
	idItemCompra INT NOT NULL
);

CREATE TABLE PrincipiosAtivos(
	idPrincipioAtivo INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DataCadastro DATE NOT NULL,
	UltimaCompra DATE,
	Nome NVARCHAR(255) NOT NULL UNIQUE,
	Situacao CHAR NOT NULL
);

ALTER TABLE ClientesRestritos
ADD FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)

ALTER TABLE TelefonesClientes
ADD FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)

ALTER TABLE VendasMedicamentos
ADD FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)

ALTER TABLE Vendas_ItensVenda
ADD FOREIGN KEY (idVenda) REFERENCES VendasMedicamentos(idVenda)

ALTER TABLE Vendas_ItensVenda
ADD FOREIGN KEY (idItemVenda) REFERENCES ItensVenda(idItemVenda)

ALTER TABLE ItensVenda
ADD FOREIGN KEY (idMedicamento) REFERENCES Medicamentos(idMedicamento)

ALTER TABLE Producoes
ADD FOREIGN KEY (idMedicamento) REFERENCES Medicamentos(idMedicamento)

ALTER TABLE ItensProducao
ADD FOREIGN KEY (idPrincipioAtivo) REFERENCES PrincipiosAtivos(idPrincipioAtivo);

ALTER TABLE Producoes_ItensProducao
ADD FOREIGN KEY (idProducao) REFERENCES Producoes (idProducao),
FOREIGN KEY (idItemProducao) REFERENCES ItensProducao(idItemProducao);

ALTER TABLE Compras_ItensCompra
ADD FOREIGN KEY (idCompra) REFERENCES Compras(idCompra),
FOREIGN KEY (idItemCompra) REFERENCES ItensCompras(idItemCompra);

ALTER TABLE ItensCompras
ADD FOREIGN KEY (idPrincipioAtivo) REFERENCES PrincipiosAtivos(idPrincipioAtivo);

ALTER TABLE Compras
ADD FOREIGN KEY (idFornecedor) REFERENCES Fornecedores(idFornecedor);

ALTER TABLE FornecedoresBloqueados
ADD FOREIGN KEY (idFornecedor) REFERENCES Fornecedores(idFornecedor);

--restrição idade cliente maior que 18 anos
ALTER TABLE Clientes
ADD CONSTRAINT Maioridade CHECK (
  DATEDIFF(YEAR, DataNascimento, GETDATE()) -
  CASE
    WHEN DATEADD(YEAR, DATEDIFF(YEAR, DataNascimento, GETDATE()), DataNascimento) > GETDATE()
    THEN 1 ELSE 0
  END >= 18
);

--restrição 11 caracteres no CPF
ALTER TABLE Clientes
ADD CONSTRAINT TamanhoCPF CHECK (LEN(CPF) = 11);

--restrição cliente restrito não pode fazer venda
GO
CREATE TRIGGER RestricaoClienteRestrito
ON VendasMedicamentos
AFTER INSERT
AS
BEGIN
  IF EXISTS (
    SELECT 1
    FROM inserted i
    JOIN ClientesRestritos cr ON i.idCliente = cr.idCliente
  )
  BEGIN
    RAISERROR ('Venda não permitida: cliente está restrito.', 16, 1);
    ROLLBACK TRANSACTION;
  END
END;

--RESTRICAO ABERTURA CNPJ TEM QUE SER MAIOR QUE 2 ANOS
ALTER TABLE Fornecedores
ADD CONSTRAINT fornecedor_maior_2_anos CHECK (
  DATEDIFF(YEAR, DataAbertura, GETDATE()) -
  CASE
    WHEN DATEADD(YEAR, DATEDIFF(YEAR, DataAbertura, GETDATE()), DataAbertura) > GETDATE()
    THEN 1 ELSE 0
  END >= 2
);

-- RESTRICAO CNPJ TEM QUE TER 14 CARACTERES
ALTER TABLE Fornecedores
ADD CONSTRAINT cnpj_14_chars CHECK (LEN(CNPJ) = 14);

--restrição maximo 3 itens por venda
GO
CREATE TRIGGER LimiteItensVenda
ON Vendas_ItensVenda
INSTEAD OF INSERT
AS
BEGIN
  IF EXISTS (
    SELECT 1
    FROM inserted i
    GROUP BY i.idVenda
    HAVING (
      SELECT COUNT(DISTINCT idItemVenda) FROM Vendas_ItensVenda v WHERE v.idVenda = i.idVenda
    ) + (
      SELECT COUNT(DISTINCT idItemVenda) FROM inserted WHERE idVenda = i.idVenda
    ) > 3
  )
  BEGIN
    RAISERROR('Limite de 3 tipos diferentes de itens por venda excedido.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
  END;
  INSERT INTO Vendas_ItensVenda (idVenda, idItemVenda)
  SELECT idVenda, idItemVenda
  FROM inserted;
END;

--RESTRICAO MAXIMO 3 ITENS POR COMPRA
GO

CREATE TRIGGER LimiteItensCompra
ON Compras_ItensCompra
AFTER INSERT
AS
BEGIN
  IF EXISTS (
    SELECT 1
    FROM inserted i
    GROUP BY i.idCompra
    HAVING (
      (SELECT COUNT(DISTINCT idItemCompra) FROM Compras_ItensCompra WHERE idCompra = i.idCompra) 
      > 3
    )
  )
  BEGIN
    RAISERROR('Limite de 3 tipos diferentes de itens por compra excedido.', 16, 1);
    ROLLBACK TRANSACTION;
  END
END;

GO
CREATE OR ALTER TRIGGER LimiteItensCompra
ON Compras_ItensCompra
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica para cada compra se a soma de itens existentes + itens inseridos ultrapassa 3
    IF EXISTS (
        SELECT i.idCompra
        FROM inserted i
        GROUP BY i.idCompra
        HAVING (
            (SELECT COUNT(DISTINCT idItemCompra) FROM Compras_ItensCompra WHERE idCompra = i.idCompra)
            + (SELECT COUNT(DISTINCT idItemCompra) FROM inserted WHERE idCompra = i.idCompra)
        ) > 3
    )
    BEGIN
        RAISERROR('Limite de 3 tipos diferentes de itens por compra excedido.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


--RESTRICAO FORNECEDOR BLOQUEADO NAO PODE FAZER COMPRA
GO
CREATE TRIGGER RestricaoFornecedorBloqueado
ON Compras
AFTER INSERT
AS
BEGIN
  IF EXISTS (
    SELECT 1
    FROM inserted i
    JOIN FornecedoresBloqueados fb ON i.idFornecedor = fb.idFornecedor
  )
  BEGIN
    RAISERROR ('Compra não permitida: fornecedor está bloqueado.', 16, 1);
    ROLLBACK TRANSACTION;
  END
END;



--atualizando ultimas datas de fornecedor
GO
CREATE TRIGGER AtualizaUltimoFornecimento
ON Compras
AFTER INSERT
AS
BEGIN
    UPDATE f
    SET UltimoFornecimento = GETDATE()
    FROM Fornecedores f
    INNER JOIN inserted i ON f.idFornecedor = i.idFornecedor;
END;

--atualizando ultimas datas de principio ativo
GO
CREATE TRIGGER AtualizaUltimaCompra
ON Compras_ItensCompra
AFTER INSERT
AS
BEGIN
    UPDATE pa
    SET UltimaCompra = GETDATE()
    FROM PrincipiosAtivos pa
    JOIN ItensCompras ic ON pa.idPrincipioAtivo = ic.idPrincipioAtivo
    JOIN inserted i ON ic.idItemCompra = i.idItemCompra;
END;

--atualizando ultima compra cliente
GO
CREATE TRIGGER AtualizandoUltimaCompraCliente
ON VendasMedicamentos
AFTER INSERT
AS
BEGIN
  UPDATE c
  SET UltimaCompra = (
    SELECT MAX(vm.DataVenda)
    FROM VendasMedicamentos vm
    WHERE vm.idCliente = c.idCliente
  )
  FROM Clientes c
  JOIN inserted i ON c.idCliente = i.idCliente;
END;

--atualizando ultima venda de medicamentos
GO
CREATE TRIGGER AtualizandoUltimaVendaMedicamentos
ON Vendas_ItensVenda
AFTER INSERT
AS
BEGIN
	UPDATE m
	SET m.UltimaVenda = vm.DataVenda
	FROM Medicamentos m
	INNER JOIN ItensVenda iv ON m.idMedicamento = iv.idMedicamento
	INNER JOIN Vendas_ItensVenda vi ON vi.idItemVenda = iv.idItemVenda
	INNER JOIN VendasMedicamentos vm ON vm.idVenda = vi.idVenda
	INNER JOIN inserted i ON vi.id = i.id
	WHERE m.idMedicamento = iv.idMedicamento
END;

--BLOQUEIOS DELETE
--delete Clientes
GO
CREATE TRIGGER Bloqueio_Delete_Clientes
ON Clientes
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete Clientes Restritos
GO
CREATE TRIGGER Bloqueio_Delete_ClientesRestritos
ON ClientesRestritos
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete Telefones Clientes
GO
CREATE TRIGGER Bloqueio_Delete_TelefonesCliente
ON TelefonesClientes
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete Vendas Medicamentos
GO
CREATE TRIGGER Bloqueio_Delete_VendaMedicamentos
ON VendasMedicamentos
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete Vendas-ItensVenda
GO
CREATE TRIGGER Bloqueio_Delete_Vendas_ItensVenda
ON Vendas_ItensVenda
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete ItensVenda
GO
CREATE TRIGGER Bloqueio_Delete_ItensVenda
ON ItensVenda
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete Medicamentos
GO
CREATE TRIGGER Bloqueio_Delete_Medicamentos
ON Medicamentos
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete Producoes
GO
CREATE TRIGGER Bloqueio_Delete_Producoes
ON Producoes
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete Producoes_ItensProducao
GO
CREATE TRIGGER Bloqueio_Delete_Producoes_ItensProducao
ON Producoes_ItensProducao
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete ItensProducao
GO
CREATE TRIGGER Bloqueio_Delete_ItensProducao
ON ItensProducao
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete PrincipiosAtivos
GO
CREATE TRIGGER Bloqueio_Delete_PrincipiosAtivos
ON PrincipiosAtivos
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete fornecedor
GO
CREATE TRIGGER Bloqueio_Delete_Fornecedores
ON Fornecedores
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete fornecedor bloqueado
GO
CREATE TRIGGER Bloqueio_Delete_FornecedoresBloqueados
ON FornecedoresBloqueados
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete compra
GO
CREATE TRIGGER Bloqueio_Delete_Compras
ON Compras
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--delete ItensCompras
GO
CREATE TRIGGER Bloqueio_Delete_ItensCompras
ON ItensCompras
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

-- delete Compras_ItensCompra
GO
CREATE TRIGGER Bloqueio_Delete_Compras_ItensCompra
ON Compras_ItensCompra
INSTEAD OF DELETE
AS
BEGIN
  RAISERROR ('A exclusão não é permitida!', 16, 1);
  ROLLBACK TRANSACTION;
END;

--PROCEDURES

--procedure vendas
GO
CREATE PROCEDURE sp_VendasMedicamentos
@idCliente INT,
@idMedicamento INT,
@Quantidade INT
AS
BEGIN
DECLARE @idVenda INT, @idItemVenda INT

	INSERT INTO VendasMedicamentos(DataVenda, idCliente)
	VALUES (GETDATE(), @idCliente)

	SET @idVenda = SCOPE_IDENTITY();

	INSERT INTO ItensVenda(idMedicamento, Quantidade)
	VALUES(@idMedicamento, @Quantidade)

	SET @idItemVenda = SCOPE_IDENTITY();

	INSERT INTO Vendas_ItensVenda(idVenda, idItemVenda)
	VALUES(@idVenda, @idItemVenda)

END;

--procedure clientes
GO
CREATE PROCEDURE sp_Clientes
@Nome NVARCHAR(255),
@CPF VARCHAR(11),
@DataNascimento DATE,
@UltimaCompra DATE = NULL, --aceita null
@Contato NVARCHAR(50)
AS
BEGIN
DECLARE @idCliente INT, @idTelefonesCliente INT

	INSERT INTO Clientes(Nome, CPF, DataCadastro, DataNascimento, UltimaCompra, Situacao)
	VALUES(@Nome, @CPF, CAST(GETDATE() AS DATE), @DataNascimento, @UltimaCompra, 'A')

	SET @idCliente = SCOPE_IDENTITY();

	INSERT INTO TelefonesClientes(idCliente, Contato)
	VALUES(@idCliente, @Contato)

	SET @idTelefonesCliente  = SCOPE_IDENTITY();

END;

--procedure compra
GO
CREATE PROCEDURE sp_Compras
    @idPrincipioAtivo INT,
    @Quantidade INT,
    @ValorUnitario FLOAT,
    @idFornecedor INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idCompra INT, @idItemCompra INT;
    DECLARE @OutputCompra TABLE (idCompra INT);
    DECLARE @OutputItem TABLE (idItemCompra INT);

    INSERT INTO Compras(DataCompra, idFornecedor)
    OUTPUT INSERTED.idCompra INTO @OutputCompra
    VALUES (GETDATE(), @idFornecedor);

    SELECT @idCompra = idCompra FROM @OutputCompra;

    -- Valide que @idCompra não seja nulo/zero
    IF @idCompra IS NULL OR @idCompra = 0
    BEGIN
        RAISERROR('Falha ao inserir Compra.', 16, 1);
        RETURN;
    END

    INSERT INTO ItensCompras(idPrincipioAtivo, Quantidade, ValorUnitario)
    OUTPUT INSERTED.idItemCompra INTO @OutputItem
    VALUES (@idPrincipioAtivo, @Quantidade, @ValorUnitario);

    SELECT @idItemCompra = idItemCompra FROM @OutputItem;

    -- Valide @idItemCompra também
    IF @idItemCompra IS NULL OR @idItemCompra = 0
    BEGIN
        RAISERROR('Falha ao inserir ItemCompra.', 16, 1);
        RETURN;
    END

    INSERT INTO Compras_ItensCompra(idCompra, idItemCompra)
    VALUES (@idCompra, @idItemCompra);
END;


GO
CREATE PROCEDURE sp_Fornecedores
    @RazaoSocial NVARCHAR(255),
    @CNPJ VARCHAR(14),
    @Pais NVARCHAR(255),
    @DataAbertura DATE,
    @UltimoFornecimento DATE = NULL
AS
BEGIN
    DECLARE @idFornecedor INT;
    INSERT INTO Fornecedores(RazaoSocial, CNPJ, Pais, DataAbertura, DataCadastro, UltimoFornecimento, Situacao)
    VALUES(@RazaoSocial, @CNPJ, @Pais, @DataAbertura, CAST(GETDATE() AS DATE), @UltimoFornecimento, 'A');
    SET @idFornecedor = SCOPE_IDENTITY();
END;

--procedure produção
GO
CREATE PROCEDURE sp_Producoes
    @idMedicamento INT,
    @QuantidadeProducao INT,
    @idPrincipioAtivo INT,
    @QuantidadePA FLOAT
AS
BEGIN
    DECLARE @idProducao INT, @idItemProducao INT;

    INSERT INTO Producoes(idMedicamento, DataProducao, Quantidade)
    VALUES (@idMedicamento, CAST(GETDATE() AS DATE) , @QuantidadeProducao);

    SET @idProducao = SCOPE_IDENTITY();

    INSERT INTO ItensProducao(idPrincipioAtivo, QuantidadePA)
    VALUES (@idPrincipioAtivo, @QuantidadePA);

    SET @idItemProducao = SCOPE_IDENTITY();

    INSERT INTO Producoes_ItensProducao(idProducao, idItemProducao)
    VALUES (@idProducao, @idItemProducao);
END;