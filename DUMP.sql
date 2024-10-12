CREATE DATABASE  IF NOT EXISTS `dbvarejo` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `dbvarejo`;
-- MySQL dump 10.13  Distrib 5.7.17, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: dbvarejo
-- ------------------------------------------------------
-- Server version	5.7.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Clientes`
--

DROP TABLE IF EXISTS `Clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Clientes` (
  `Codigo` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Coluna para armazenar sequencial auto incremento do cliente',
  `Nome` varchar(100) NOT NULL COMMENT 'Coluna para o nome do cliente com no máximo 100 caracteres',
  `Cidade` varchar(50) NOT NULL COMMENT 'Coluna para a cidade do cliente com no máximo 50 caracteres',
  `UF` varchar(2) NOT NULL COMMENT 'Coluna para a UF do cliente com no máximo 2 caracteres. OBS: "EX" para cliente estrangeiro',
  PRIMARY KEY (`Codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='Tabela usada para armazena os clientes do sistema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Clientes`
--

LOCK TABLES `Clientes` WRITE;
/*!40000 ALTER TABLE `Clientes` DISABLE KEYS */;
INSERT INTO `Clientes` VALUES (1,'Ana Maria','São Paulo','SP'),(2,'Maria Oliveira','Rio de Janeiro','RJ'),(3,'Carlos Souza','Belo Horizonte','MG'),(4,'Ana Lima','Curitiba','PR'),(5,'Paulo Mendes','Porto Alegre','RS'),(6,'Fernanda Costa','Salvador','BA'),(7,'Ricardo Rocha','Fortaleza','CE'),(8,'Juliana Freitas','Brasília','DF'),(9,'Pedro Almeida','Manaus','AM'),(10,'Patrícia Santos','Recife','PE');
/*!40000 ALTER TABLE `Clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Pedidos`
--

DROP TABLE IF EXISTS `Pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Pedidos` (
  `Id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Coluna para armazenar sequencial auto incremento do pedido',
  `Data_Emissao` date NOT NULL COMMENT 'Guarda a data e hora da emissão do pedido',
  `Codigo_Cliente` int(11) NOT NULL COMMENT 'Coluna para armazenar a chave primaria do cliente',
  `Valor_Total` decimal(10,2) NOT NULL COMMENT 'valor decimal (10,2) que representa a soma da operação valor unitario x quantidade de todos os itens que compõem o pedido',
  PRIMARY KEY (`Id`),
  KEY `idx_cliente_pedido` (`Codigo_Cliente`),
  CONSTRAINT `Pedidos_ibfk_1` FOREIGN KEY (`Codigo_Cliente`) REFERENCES `Clientes` (`Codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='Tabela usada para armazena os pedidos do sistema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Pedidos`
--

LOCK TABLES `Pedidos` WRITE;
/*!40000 ALTER TABLE `Pedidos` DISABLE KEYS */;
INSERT INTO `Pedidos` VALUES (1,'2024-10-12',1,18000.00),(2,'2024-10-12',2,3400.00),(3,'2024-10-12',3,150.00),(4,'2024-10-12',4,328.75);
/*!40000 ALTER TABLE `Pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Pedidos_Produtos`
--

DROP TABLE IF EXISTS `Pedidos_Produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Pedidos_Produtos` (
  `Id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Coluna para armazenar sequencial auto incremento do produto no pedido',
  `Id_Pedido` int(11) NOT NULL COMMENT 'Coluna para armazenar o código do pedido',
  `Codigo_Produto` int(11) NOT NULL COMMENT 'Coluna para armazenar o código do produto',
  `Quantidade` decimal(10,5) NOT NULL COMMENT 'Coluna para armazenar a quantidade vendida do produto',
  `Valor_Unitario` decimal(10,2) NOT NULL COMMENT 'Coluna para armazenar o valor unitario do produto',
  `Valor_Total` decimal(15,2) NOT NULL,
  PRIMARY KEY (`Id`),
  KEY `Codigo_Produto` (`Codigo_Produto`),
  KEY `idx_pedido_produto` (`Id_Pedido`,`Codigo_Produto`),
  CONSTRAINT `Pedidos_Produtos_ibfk_1` FOREIGN KEY (`Id_Pedido`) REFERENCES `Pedidos` (`Id`),
  CONSTRAINT `Pedidos_Produtos_ibfk_2` FOREIGN KEY (`Codigo_Produto`) REFERENCES `Produtos` (`Codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='Tabela usada para armazena os produtos de um pedido do sistema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Pedidos_Produtos`
--

LOCK TABLES `Pedidos_Produtos` WRITE;
/*!40000 ALTER TABLE `Pedidos_Produtos` DISABLE KEYS */;
INSERT INTO `Pedidos_Produtos` VALUES (1,1,1,12.00000,1500.00,18000.00),(2,2,1,1.00000,1500.00,1500.00),(3,2,1,1.00000,1500.00,1500.00),(4,2,2,2.00000,200.00,400.00),(5,3,3,3.00000,50.00,150.00),(6,4,4,1.00000,25.00,25.00),(7,4,4,0.15000,25.00,3.75),(8,4,2,1.50000,200.00,300.00);
/*!40000 ALTER TABLE `Pedidos_Produtos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Produtos`
--

DROP TABLE IF EXISTS `Produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Produtos` (
  `Codigo` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Coluna para armazenar sequencial auto incremento do produto',
  `Descricao` varchar(100) NOT NULL COMMENT 'Coluna para nomear um produto com no máximo 100 caracteres',
  `Preco_Venda` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Coluna para valorizar o preço do produto',
  PRIMARY KEY (`Codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='Tabela usada para armazena os produtos do sistema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Produtos`
--

LOCK TABLES `Produtos` WRITE;
/*!40000 ALTER TABLE `Produtos` DISABLE KEYS */;
INSERT INTO `Produtos` VALUES (1,'Bicicleta Aro 29',1500.00),(2,'Capacete de Ciclismo',200.00),(3,'Luva de Ciclismo',50.00),(4,'Câmera de Ar',25.00),(5,'Selim de Bicicleta',100.00),(6,'Farol de Bicicleta',80.00),(7,'Suporte para Garrafa',15.00),(8,'Kit Ferramentas',120.00),(9,'Pedal Clip',300.00),(10,'Câmbio Traseiro',400.00);
/*!40000 ALTER TABLE `Produtos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'dbvarejo'
--

--
-- Dumping routines for database 'dbvarejo'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-10-12 11:44:10
