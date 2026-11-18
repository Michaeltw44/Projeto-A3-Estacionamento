/* Der_Estacionamento: */

CREATE TABLE Estacionamento (
    ID_Estacionamento INTEGER PRIMARY KEY,
    Logradouro VARCHAR,
    Numero VARCHAR,
    Cidade VARCHAR,
    CEP VARCHAR,
    Capacidade NUMERIC,
    Nome VARCHAR
);

CREATE TABLE Marca (
    cod_marca INTEGER PRIMARY KEY,
    Nome VARCHAR
);

CREATE TABLE Modelo (
    cod_modelo INTEGER PRIMARY KEY,
    Nome VARCHAR,
    Carroceria VARCHAR,
    cod_marca INTEGER
);

CREATE TABLE Veiculo (
    Placa VARCHAR PRIMARY KEY UNIQUE,
    Id_Cliente INTEGER,
    Cor VARCHAR,
    fk_Modelo_cod_modelo INTEGER
);

CREATE TABLE Cliente (
    ID_Cliente INTEGER PRIMARY KEY,
    Nome VARCHAR,
    Telefone VARCHAR,
    CPF VARCHAR
);

CREATE TABLE Funcionario (
    ID_Funcionario INTEGER PRIMARY KEY,
    Nome VARCHAR,
    CPF VARCHAR,
    Telefone VARCHAR
);

CREATE TABLE Loja_Conveniada (
    ID_Loja INTEGER PRIMARY KEY,
    Nome VARCHAR
);

CREATE TABLE Estadia (
    ID_Estadia INTEGER PRIMARY KEY,
    Data_hora_entrada DATE,
    Data_hora_saida DATE,
    Placa VARCHAR UNIQUE,
    Id_Tarifa INTEGER,
    Id_Loja INTEGER,
    Id_Estacionamento INTEGER,
    Id_Funcionario INTEGER
);

CREATE TABLE Pagamento (
    ID_Pagamento INTEGER PRIMARY KEY,
    Forma VARCHAR,
    Valor_Pago NUMERIC,
    Data_hora_pagamento DATE,
    Id_Estadia INTEGER UNIQUE,
    Id_Funcionario INTEGER
);

CREATE TABLE Tarifa (
    ID_Tarifa INTEGER PRIMARY KEY,
    Valor_hora NUMERIC,
    Data_Vigencia DATE
);

CREATE TABLE Ocorrencia (
    ID_Ocorrencia INTEGER PRIMARY KEY,
    Data_hora DATE,
    Tipo VARCHAR,
    Descricao VARCHAR,
    Id_Estadia INTEGER,
    Id_Funcionario INTEGER
);

CREATE TABLE Contrato (
    ID_Contrato INTEGER PRIMARY KEY,
    Data_inicio DATE,
    Data_fim DATE,
    Valor_mensal NUMERIC,
    Id_Cliente INTEGER,
    Placa VARCHAR
);

CREATE TABLE Mensalidade (
    ID_Mensalidade INTEGER PRIMARY KEY,
    Competencia VARCHAR,
    Data_Vencimento DATE,
    Data_Pagamento DATE,
    Status VARCHAR,
    Id_Contrato INTEGER
);

CREATE TABLE Emprega (
    fk_Estacionamento_ID_Estacionamento INTEGER,
    fk_Funcionario_ID_Funcionario INTEGER
);
 
ALTER TABLE Modelo ADD CONSTRAINT FK_Modelo_2
    FOREIGN KEY (cod_marca)
    REFERENCES Marca (cod_marca);
 
ALTER TABLE Veiculo ADD CONSTRAINT FK_Veiculo_2
    FOREIGN KEY (fk_Modelo_cod_modelo)
    REFERENCES Modelo (cod_modelo)
    ON DELETE RESTRICT;
 
ALTER TABLE Veiculo ADD CONSTRAINT FK_Veiculo_3
    FOREIGN KEY (Id_Cliente)
    REFERENCES Cliente (ID_Cliente);
 
ALTER TABLE Estadia ADD CONSTRAINT FK_Estadia_3
    FOREIGN KEY (Placa)
    REFERENCES Veiculo (Placa);
 
ALTER TABLE Estadia ADD CONSTRAINT FK_Estadia_4
    FOREIGN KEY (Id_Tarifa)
    REFERENCES Tarifa (ID_Tarifa);
 
ALTER TABLE Estadia ADD CONSTRAINT FK_Estadia_5
    FOREIGN KEY (Id_Loja)
    REFERENCES Loja_Conveniada (ID_Loja);
 
ALTER TABLE Estadia ADD CONSTRAINT FK_Estadia_6
    FOREIGN KEY (Id_Estacionamento)
    REFERENCES Estacionamento (ID_Estacionamento);
 
ALTER TABLE Estadia ADD CONSTRAINT FK_Estadia_7
    FOREIGN KEY (Id_Funcionario)
    REFERENCES Funcionario (ID_Funcionario);
 
ALTER TABLE Pagamento ADD CONSTRAINT FK_Pagamento_2
    FOREIGN KEY (Id_Estadia)
    REFERENCES Estadia (ID_Estadia);
 
ALTER TABLE Pagamento ADD CONSTRAINT FK_Pagamento_3
    FOREIGN KEY (Id_Funcionario)
    REFERENCES Funcionario (ID_Funcionario);
 
ALTER TABLE Ocorrencia ADD CONSTRAINT FK_Ocorrencia_2
    FOREIGN KEY (Id_Estadia)
    REFERENCES Estadia (ID_Estadia);
 
ALTER TABLE Ocorrencia ADD CONSTRAINT FK_Ocorrencia_3
    FOREIGN KEY (Id_Funcionario)
    REFERENCES Funcionario (ID_Funcionario);
 
ALTER TABLE Contrato ADD CONSTRAINT FK_Contrato_2
    FOREIGN KEY (Id_Cliente)
    REFERENCES Cliente (ID_Cliente);
 
ALTER TABLE Contrato ADD CONSTRAINT FK_Contrato_3
    FOREIGN KEY (Placa)
    REFERENCES Veiculo (Placa);
 
ALTER TABLE Mensalidade ADD CONSTRAINT FK_Mensalidade_2
    FOREIGN KEY (Id_Contrato)
    REFERENCES Contrato (ID_Contrato);
 
ALTER TABLE Emprega ADD CONSTRAINT FK_Emprega_1
    FOREIGN KEY (fk_Estacionamento_ID_Estacionamento)
    REFERENCES Estacionamento (ID_Estacionamento)
    ON DELETE RESTRICT;
 
ALTER TABLE Emprega ADD CONSTRAINT FK_Emprega_2
    FOREIGN KEY (fk_Funcionario_ID_Funcionario)
    REFERENCES Funcionario (ID_Funcionario)
    ON DELETE SET NULL;