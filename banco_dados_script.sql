-- Criando o banco de dados
CREATE DATABASE dbvarejo;
USE dbvarejo;

-- tabela de clientes
CREATE TABLE Clientes (
    Codigo INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Cidade VARCHAR(50) NOT NULL,
    UF CHAR(2) NOT NULL,
    Valido BOOL DEFAULT 1 NOT NULL   
);
ALTER TABLE Clientes COMMENT='Tabela usada para armazena os clientes do sistema';
ALTER TABLE Clientes MODIFY COLUMN Codigo int auto_increment NOT NULL COMMENT 'Coluna para armazenar sequencial auto incremento do cliente';
ALTER TABLE Clientes MODIFY COLUMN Nome varchar(100) NOT NULL COMMENT 'Coluna para o nome do cliente com no máximo 100 caracteres';
ALTER TABLE Clientes MODIFY COLUMN Cidade varchar(50) NOT NULL COMMENT 'Coluna para a cidade do cliente com no máximo 50 caracteres';
ALTER TABLE Clientes MODIFY COLUMN UF varchar(2) NOT NULL COMMENT 'Coluna para a UF do cliente com no máximo 2 caracteres. OBS: "EX" para cliente estrangeiro';
ALTER TABLE Clientes MODIFY COLUMN Valido BOOL DEFAULT 1 NOT NULL COMMENT 'Coluna usada para exclusão logica do registro. 1 = registro valido ou 0 = registro excluído';

-- tabela de produtos
CREATE TABLE Produtos (
    Codigo INT AUTO_INCREMENT PRIMARY KEY,
    Descricao VARCHAR(100) NOT NULL,
    Preco_Venda DECIMAL(10, 2) NOT NULL DEFAULT 0,
    Valido BOOL DEFAULT 1 NOT NULL
);
ALTER TABLE Produtos COMMENT='Tabela usada para armazena os produtos do sistema';
ALTER TABLE Produtos MODIFY COLUMN Codigo int auto_increment NOT NULL COMMENT 'Coluna para armazenar sequencial auto incremento do produto';
ALTER TABLE Produtos MODIFY COLUMN Descricao varchar(100) NOT NULL COMMENT 'Coluna para nomear um produto com no máximo 100 caracteres';
ALTER TABLE Produtos MODIFY COLUMN Preco_Venda DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT 'Coluna para valorizar o preço do produto';
ALTER TABLE Produtos MODIFY COLUMN Valido BOOL DEFAULT 1 NOT NULL COMMENT 'Coluna usada para exclusão logica do registro. 1 = registro valido ou 0 = registro excluído';

-- tabela de pedidos (dados gerais)
CREATE TABLE Pedidos (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Data_Emissao DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Codigo_Cliente INT NOT NULL,
    Valor_Total DECIMAL(10, 2) NOT NULL,
    Valido BOOL DEFAULT 1 NOT NULL,
    FOREIGN KEY (Codigo_Cliente) REFERENCES Clientes(Codigo)
);
ALTER TABLE Pedidos COMMENT='Tabela usada para armazena os pedidos do sistema';
ALTER TABLE Pedidos MODIFY COLUMN Id int auto_increment NOT NULL COMMENT 'Coluna para armazenar sequencial auto incremento do pedido';
ALTER TABLE Pedidos MODIFY COLUMN Data_Emissao date NOT NULL COMMENT 'Guarda a data e hora da emissão do pedido';
ALTER TABLE Pedidos MODIFY COLUMN Codigo_Cliente int NOT NULL COMMENT 'Coluna para armazenar a chave primaria do cliente';
ALTER TABLE Pedidos MODIFY COLUMN Valor_Total decimal(10,2) NOT NULL COMMENT 'valor decimal (10,2) que representa a soma da operação valor unitario x quantidade de todos os itens que compõem o pedido';
ALTER TABLE Pedidos MODIFY COLUMN Valido BOOL DEFAULT 1 NOT NULL COMMENT 'Coluna usada para exclusão logica do registro. 1 = registro valido ou 0 = registro excluído';

-- tabela de produtos dos pedidos (itens)
CREATE TABLE Pedidos_Produtos (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Id_Pedido INT NOT NULL,
    Codigo_Produto INT NOT NULL,
    Quantidade DECIMAL(10, 5) NOT NULL,
    Valor_Unitario DECIMAL(10, 2) NOT NULL,
    Valido BOOL DEFAULT 1 NOT NULL,
    FOREIGN KEY (id_Pedido) REFERENCES Pedidos(id),
    FOREIGN KEY (Codigo_Produto) REFERENCES Produtos(Codigo)
);
ALTER TABLE Pedidos_Produtos COMMENT='Tabela usada para armazena os produtos de um pedido do sistema';
ALTER TABLE Pedidos_Produtos MODIFY COLUMN Id INT AUTO_INCREMENT NOT NULL COMMENT 'Coluna para armazenar sequencial auto incremento do produto no pedido';
ALTER TABLE Pedidos_Produtos MODIFY COLUMN Id_Pedido INT NOT NULL COMMENT 'Coluna para armazenar o código do pedido';
ALTER TABLE Pedidos_Produtos MODIFY COLUMN Codigo_Produto int NOT NULL COMMENT 'Coluna para armazenar o código do produto';
ALTER TABLE Pedidos_Produtos MODIFY COLUMN Quantidade decimal(10,5) NOT NULL COMMENT 'Coluna para armazenar a quantidade vendida do produto';
ALTER TABLE Pedidos_Produtos MODIFY COLUMN Valor_Unitario decimal(10,2) NOT NULL COMMENT 'Coluna para armazenar o valor unitario do produto';
ALTER TABLE Pedidos_Produtos MODIFY COLUMN Valido BOOL DEFAULT 1 NOT NULL COMMENT 'Coluna usada para exclusão logica do registro. 1 = registro valido ou 0 = registro excluído';

-- Criando índices
CREATE INDEX idx_cliente_pedido ON Pedidos(Codigo_Cliente);
CREATE INDEX idx_pedido_produto ON Pedidos_Produtos(Id_Pedido, Codigo_Produto);

-- Inserindo dados de teste na tabela de clientes
INSERT INTO Clientes (Nome, Cidade, UF) VALUES
('Ana Maria', 'São Paulo', 'SP'),
('Maria Oliveira', 'Rio de Janeiro', 'RJ'),
('Carlos Souza', 'Belo Horizonte', 'MG'),
('Ana Lima', 'Curitiba', 'PR'),
('Paulo Mendes', 'Porto Alegre', 'RS'),
('Fernanda Costa', 'Salvador', 'BA'),
('Ricardo Rocha', 'Fortaleza', 'CE'),
('Juliana Freitas', 'Brasília', 'DF'),
('Pedro Almeida', 'Manaus', 'AM'),
('Patrícia Santos', 'Recife', 'PE');

-- Inserindo dados de teste na tabela de produtos
INSERT INTO Produtos (Descricao, Preco_Venda) VALUES
('Bicicleta Aro 29', 1500.00),
('Capacete de Ciclismo', 200.00),
('Luva de Ciclismo', 50.00),
('Câmera de Ar', 25.00),
('Selim de Bicicleta', 100.00),
('Farol de Bicicleta', 80.00),
('Suporte para Garrafa', 15.00),
('Kit Ferramentas', 120.00),
('Pedal Clip', 300.00),
('Câmbio Traseiro', 400.00);

/*
select I.id_Pedido, I.Codigo_Produto, P.Descricao AS Produto, I.Quantidade, I.Valor_Unitario, Round(I.Quantidade * I.Valor_Unitario, 2 ) As Valor_Total
  from Pedidos_Produtos I
       inner join Pedidos PD ON I.Id_Pedido = PD.Id 
	   inner join Produtos P ON I.Codigo_Produto = P.Codigo
order by P.Descricao
*/