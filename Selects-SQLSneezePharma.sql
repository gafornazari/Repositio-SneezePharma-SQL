--mostrando clientes
SELECT c.Nome, c.CPF, c.DataCadastro, c.DataNascimento, c.UltimaCompra, c.Situacao, tc.Contato
FROM Clientes c
JOIN TelefonesClientes tc
ON c.idCliente = tc.idCliente

--mostrando informações cientes restritos
SELECT c.Nome, c.CPF, c.DataCadastro, c.DataNascimento, c.UltimaCompra, c.Situacao, tc.Contato
FROM Clientes c
JOIN ClientesRestritos cr
ON c.idCliente = cr.idCliente
JOIN TelefonesClientes tc
ON c.idCliente = tc.idCliente

--venda com cliente
SELECT c.Nome, c.CPF, tc.Contato, vm.DataVenda
FROM Clientes c
JOIN VendasMedicamentos vm
ON c.idCliente = vm.idCliente
JOIN TelefonesClientes tc
ON c.idCliente = tc.idCliente

--mostrando a produção de cada medicamento
SELECT p.idProducao, p.DataProducao, p.Quantidade, m.Nome, m.CDB
FROM Producoes p
JOIN Medicamentos m
ON p.idMedicamento = m.idMedicamento

SELECT p.idProducao, p.DataProducao, p.Quantidade, i.QuantidadePA, pa.Nome, pa.Situacao
FROM Producoes p
JOIN Producoes_ItensProducao pip  
ON p.idProducao = pip.idProducao
JOIN ItensProducao i
ON pip.idItemProducao = i.idItemProducao
JOIN PrincipiosAtivos pa
ON i.idPrincipioAtivo = pa.idPrincipioAtivo


--listar itens com total item
SELECT
  ic.idItemCompra,
  ic.idPrincipioAtivo,
  ic.Quantidade,
  ic.ValorUnitario,
  (ic.Quantidade * ic.ValorUnitario) AS TotalItem
FROM ItensCompras ic
JOIN Compras_ItensCompra cic ON ic.idItemCompra = cic.idItemCompra
WHERE cic.idCompra = 1;

-- calcular valor total da compra
SELECT
  c.idCompra,
  c.DataCompra,
  c.idFornecedor,
  SUM(ic.Quantidade * ic.ValorUnitario) AS ValorTotal
FROM Compras c
JOIN Compras_ItensCompra cic ON c.idCompra = cic.idCompra
JOIN ItensCompras ic ON cic.idItemCompra = ic.idItemCompra
WHERE c.idCompra = 1
GROUP BY c.idCompra, c.DataCompra, c.idFornecedor;

-- verificando se  o campo do ultimo fornecimento utualizou
SELECT idFornecedor, UltimoFornecimento FROM Fornecedores;

--verificando se o campo ultimacompra atualizou
SELECT idPrincipioAtivo, Nome, UltimaCompra
FROM PrincipiosAtivos;

-- mostrar todos os fornecedores
SELECT
    f.RazaoSocial,
    f.Pais,
    f.DataAbertura,
    f.DataCadastro,
    f.CNPJ,
    f.UltimoFornecimento,
    f.Situacao
FROM Fornecedores f;

--mostrar só os fornecedores bloqueados
SELECT
    f.RazaoSocial,
    f.Pais,
    f.DataAbertura,
    f.DataCadastro,
    f.CNPJ,
    f.UltimoFornecimento,
    f.Situacao
FROM Fornecedores f
JOIN FornecedoresBloqueados fb
ON f.idFornecedor = fb.idFornecedor;

-- motstra intens das compras
SELECT
    c.idCompra,
    c.DataCompra,
    f.RazaoSocial AS NomeFornecedor,
    pa.Nome AS NomePrincipioAtivo,
    ic.Quantidade,
    ic.ValorUnitario,
    (ic.Quantidade * ic.ValorUnitario) AS TotalItem
FROM Compras c
JOIN Fornecedores f ON c.idFornecedor = f.idFornecedor
JOIN Compras_ItensCompra cic ON c.idCompra = cic.idCompra
JOIN ItensCompras ic ON cic.idItemCompra = ic.idItemCompra
JOIN PrincipiosAtivos pa ON ic.idPrincipioAtivo = pa.idPrincipioAtivo
ORDER BY c.DataCompra, c.idCompra, pa.Nome;

-- mostra a compra
SELECT
    c.idCompra,
    c.DataCompra,
    f.RazaoSocial AS NomeFornecedor,
    COUNT(ic.idItemCompra) AS TotalItens,
    SUM(ic.Quantidade * ic.ValorUnitario) AS ValorTotalCompra
FROM Compras c
JOIN Fornecedores f ON c.idFornecedor = f.idFornecedor
JOIN Compras_ItensCompra cic ON c.idCompra = cic.idCompra
JOIN ItensCompras ic ON cic.idItemCompra = ic.idItemCompra
GROUP BY c.idCompra, c.DataCompra, f.RazaoSocial
ORDER BY c.DataCompra, c.idCompra;

--mostra itens da venda
SELECT
    v.idVenda,
    v.DataVenda,
    c.Nome AS NomeCliente,
    m.Nome AS NomeMedicamento,
    iv.Quantidade,
    m.ValorVenda AS ValorUnitario,
    (iv.Quantidade * m.ValorVenda) AS TotalItem
FROM VendasMedicamentos v
JOIN Clientes c ON v.idCliente = c.idCliente
JOIN Vendas_ItensVenda viv ON v.idVenda = viv.idVenda
JOIN ItensVenda iv ON viv.idItemVenda = iv.idItemVenda
JOIN Medicamentos m ON iv.idMedicamento = m.idMedicamento
ORDER BY v.DataVenda, v.idVenda, m.Nome;
--mostra a venda
SELECT
    v.idVenda,
    v.DataVenda,
    c.Nome AS NomeCliente,
    COUNT(iv.idItemVenda) AS TotalItens,
    SUM(iv.Quantidade * m.ValorVenda) AS ValorTotalVenda
FROM VendasMedicamentos v
JOIN Clientes c ON v.idCliente = c.idCliente
JOIN Vendas_ItensVenda viv ON v.idVenda = viv.idVenda
JOIN ItensVenda iv ON viv.idItemVenda = iv.idItemVenda
JOIN Medicamentos m ON iv.idMedicamento = m.idMedicamento
GROUP BY v.idVenda, v.DataVenda, c.Nome
ORDER BY v.DataVenda, v.idVenda;


--relatorio de Medicamentos mais vendidos
SELECT m.Nome, m.Situacao, m.Categoria, m.CDB, SUM(iv.Quantidade) AS QuantidadeTotalVendida
FROM VendasMedicamentos vm
JOIN Vendas_ItensVenda viv ON vm.idVenda = viv.idVenda
JOIN ItensVenda iv ON viv.idItemVenda = iv.idItemVenda
JOIN Medicamentos m ON iv.idMedicamento = m.idMedicamento
WHERE vm.DataVenda BETWEEN '2025-11-09' AND '2025-11-10'
GROUP BY m.Nome, m.Situacao, m.Categoria, m.CDB
ORDER BY QuantidadeTotalVendida DESC;

--relatorio de vendas por periodo
SELECT
    vm.idVenda,
    vm.DataVenda,
    c.Nome AS NomeCliente,
    SUM(iv.Quantidade * m.ValorVenda) AS ValorTotal
FROM VendasMedicamentos vm
JOIN Clientes c ON vm.idCliente = c.idCliente
JOIN Vendas_ItensVenda viv ON vm.idVenda = viv.idVenda
JOIN ItensVenda iv ON viv.idItemVenda = iv.idItemVenda
JOIN Medicamentos m ON iv.idMedicamento = m.idMedicamento
WHERE vm.DataVenda BETWEEN '2025-11-08' AND '2025-11-09'
GROUP BY vm.idVenda, vm.DataVenda, c.Nome
ORDER BY vm.DataVenda, vm.idVenda;

--relatorio de compras por fornecedor
SELECT
  f.idFornecedor,
  f.RazaoSocial,
  f.CNPJ,
  SUM(ic.Quantidade * ic.ValorUnitario) AS ValorTotalComprado,
  COUNT(DISTINCT c.idCompra) AS NumeroDeCompras
FROM Fornecedores f
JOIN Compras c ON f.idFornecedor = c.idFornecedor
JOIN Compras_ItensCompra cic ON c.idCompra = cic.idCompra
JOIN ItensCompras ic ON cic.idItemCompra = ic.idItemCompra
GROUP BY f.idFornecedor, f.RazaoSocial, f.CNPJ
ORDER BY ValorTotalComprado DESC;


