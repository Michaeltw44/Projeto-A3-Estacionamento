
-- =====================================================
-- PROJETO A3 - CONTROLE DE ESTACIONAMENTO
-- Arquivo: 01-schema.sql
-- Banco de dados: SQLite
-- =====================================================

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------
-- Remoção das tabelas do grupo (ordem INVERSA à de criação)
-- Garante a recriação limpa do schema em caso de rollback.
-- Os índices são removidos junto com a sua tabela.
-- marca e modelo NÃO são removidas aqui (pertencem a 00-base-fornecida.sql).
-- -----------------------------------------------------
DROP TABLE IF EXISTS Emprega;
DROP TABLE IF EXISTS Ocorrencia;
DROP TABLE IF EXISTS Pagamento;
DROP TABLE IF EXISTS Estadia;
DROP TABLE IF EXISTS Mensalidade;
DROP TABLE IF EXISTS Contrato;
DROP TABLE IF EXISTS Veiculo;
DROP TABLE IF EXISTS Tarifa;
DROP TABLE IF EXISTS Loja_Conveniada;
DROP TABLE IF EXISTS Funcionario;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Estacionamento;


CREATE TABLE Estacionamento (
    ID_Estacionamento INTEGER PRIMARY KEY,
    Logradouro TEXT NOT NULL,
    Numero TEXT NOT NULL,
    Cidade TEXT NOT NULL,
    CEP TEXT NOT NULL,
    Capacidade INTEGER NOT NULL CHECK (Capacidade > 0),
    Nome TEXT NOT NULL
);


CREATE TABLE Cliente (
    ID_Cliente INTEGER PRIMARY KEY,
    Nome TEXT NOT NULL,
    Telefone TEXT,
    CPF TEXT NOT NULL UNIQUE
);


CREATE TABLE Funcionario (
    ID_Funcionario INTEGER PRIMARY KEY,
    Nome TEXT NOT NULL,
    CPF TEXT,
    Telefone TEXT
);


CREATE TABLE Loja_Conveniada (
    ID_Loja INTEGER PRIMARY KEY,
    Nome TEXT NOT NULL
);


CREATE TABLE Tarifa (
    ID_Tarifa INTEGER PRIMARY KEY,
    Valor_hora NUMERIC NOT NULL CHECK (Valor_hora > 0),
    Data_Vigencia DATE NOT NULL
);


CREATE TABLE Veiculo (
    Placa TEXT PRIMARY KEY,
    Id_Cliente INTEGER,
    Cor TEXT,
    Cod_Modelo INTEGER NOT NULL,

    FOREIGN KEY (Id_Cliente)
        REFERENCES Cliente (ID_Cliente),

    FOREIGN KEY (Cod_Modelo)
        REFERENCES modelo (cod_modelo)
);


CREATE TABLE Contrato (
    ID_Contrato INTEGER PRIMARY KEY,
    Data_inicio DATE NOT NULL,
    Data_fim DATE,
    Valor_mensal NUMERIC NOT NULL CHECK (Valor_mensal > 0),
    Id_Cliente INTEGER NOT NULL,
    Placa TEXT NOT NULL,

    CHECK (
        Data_fim IS NULL
        OR Data_fim >= Data_inicio
    ),

    FOREIGN KEY (Id_Cliente)
        REFERENCES Cliente (ID_Cliente),

    FOREIGN KEY (Placa)
        REFERENCES Veiculo (Placa)
);


CREATE TABLE Mensalidade (
    ID_Mensalidade INTEGER PRIMARY KEY,
    Competencia TEXT NOT NULL,
    Data_Vencimento DATE NOT NULL,
    Data_Pagamento DATE,
    Id_Contrato INTEGER NOT NULL,

    UNIQUE (Id_Contrato, Competencia),

    FOREIGN KEY (Id_Contrato)
        REFERENCES Contrato (ID_Contrato)
);


CREATE TABLE Estadia (
    ID_Estadia INTEGER PRIMARY KEY,
    Data_hora_entrada DATETIME NOT NULL,
    Data_hora_saida DATETIME,
    Placa TEXT NOT NULL,
    Id_Tarifa INTEGER,
    Id_Loja INTEGER,
    Id_Estacionamento INTEGER NOT NULL,
    Id_Funcionario INTEGER NOT NULL,

    CHECK (
        Data_hora_saida IS NULL
        OR Data_hora_saida > Data_hora_entrada
    ),

    FOREIGN KEY (Placa)
        REFERENCES Veiculo (Placa),

    FOREIGN KEY (Id_Tarifa)
        REFERENCES Tarifa (ID_Tarifa),

    FOREIGN KEY (Id_Loja)
        REFERENCES Loja_Conveniada (ID_Loja),

    FOREIGN KEY (Id_Estacionamento)
        REFERENCES Estacionamento (ID_Estacionamento),

    FOREIGN KEY (Id_Funcionario)
        REFERENCES Funcionario (ID_Funcionario)
);


CREATE UNIQUE INDEX idx_estadia_veiculo_aberta
ON Estadia (Placa)
WHERE Data_hora_saida IS NULL;


CREATE TABLE Pagamento (
    ID_Pagamento INTEGER PRIMARY KEY,
    Forma TEXT NOT NULL CHECK (
        Forma IN ('Dinheiro', 'Débito', 'Crédito', 'PIX')
    ),
    Valor_Pago NUMERIC NOT NULL CHECK (Valor_Pago > 0),
    Data_hora_pagamento DATETIME NOT NULL
        DEFAULT CURRENT_TIMESTAMP,
    Id_Estadia INTEGER NOT NULL UNIQUE,
    Id_Funcionario INTEGER NOT NULL,

    FOREIGN KEY (Id_Estadia)
        REFERENCES Estadia (ID_Estadia),

    FOREIGN KEY (Id_Funcionario)
        REFERENCES Funcionario (ID_Funcionario)
);


CREATE TABLE Ocorrencia (
    ID_Ocorrencia INTEGER PRIMARY KEY,
    Data_hora DATETIME NOT NULL,
    Tipo TEXT NOT NULL,
    Descricao TEXT NOT NULL,
    Id_Estadia INTEGER NOT NULL,
    Id_Funcionario INTEGER NOT NULL,

    FOREIGN KEY (Id_Estadia)
        REFERENCES Estadia (ID_Estadia),

    FOREIGN KEY (Id_Funcionario)
        REFERENCES Funcionario (ID_Funcionario)
);


CREATE TABLE Emprega (
    Id_Estacionamento INTEGER NOT NULL,
    Id_Funcionario INTEGER NOT NULL,

    PRIMARY KEY (Id_Estacionamento, Id_Funcionario),

    FOREIGN KEY (Id_Estacionamento)
        REFERENCES Estacionamento (ID_Estacionamento),

    FOREIGN KEY (Id_Funcionario)
        REFERENCES Funcionario (ID_Funcionario)
);
