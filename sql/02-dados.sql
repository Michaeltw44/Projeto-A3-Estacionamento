-- =====================================================
-- PROJETO A3 - CONTROLE DE ESTACIONAMENTO
-- Arquivo: 02-dados.sql
-- Dados de teste (100% fictícios)
-- Executar DEPOIS de 00-base-fornecida.sql e 01-schema.sql
-- Formatos: DATE = 'AAAA-MM-DD' | DATETIME = 'AAAA-MM-DD HH:MM:SS'
--           Competencia = 'AAAA-MM'
-- =====================================================

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------
-- Estacionamento (RN03) - capacidade 80
-- -----------------------------------------------------
INSERT INTO Estacionamento (ID_Estacionamento, Logradouro, Numero, Cidade, CEP, Capacidade, Nome) VALUES
  (1, 'Rua das Acácias Fictícias', '1000', 'São Paulo', '05500-000', 80, 'Estacionamento Central A3');

-- -----------------------------------------------------
-- Funcionários (3) e vínculo N:N com o estacionamento
-- -----------------------------------------------------
INSERT INTO Funcionario (ID_Funcionario, Nome, CPF, Telefone) VALUES
  (1, 'Carlos Ficticio Andrade', '900.000.001-01', '(11) 90000-0001'),
  (2, 'Beatriz Exemplo Souza',   '900.000.002-02', '(11) 90000-0002'),
  (3, 'Diego Teste Ramos',       '900.000.003-03', '(11) 90000-0003');

INSERT INTO Emprega (Id_Estacionamento, Id_Funcionario) VALUES
  (1, 1), (1, 2), (1, 3);

-- -----------------------------------------------------
-- Clientes (5)
-- -----------------------------------------------------
INSERT INTO Cliente (ID_Cliente, Nome, Telefone, CPF) VALUES
  (1, 'Ana Modelo Pereira',   '(11) 91111-0001', '800.000.001-11'),
  (2, 'Bruno Amostra Lima',   '(11) 91111-0002', '800.000.002-22'),
  (3, 'Clara Ficticia Rocha', '(11) 91111-0003', '800.000.003-33'),
  (4, 'Daniel Simulado Costa', NULL,             '800.000.004-44'),
  (5, 'Eduarda Teste Nunes',  '(11) 91111-0005', '800.000.005-55');

-- -----------------------------------------------------
-- Lojas conveniadas (3) - a loja 3 não terá estadias
-- -----------------------------------------------------
INSERT INTO Loja_Conveniada (ID_Loja, Nome) VALUES
  (1, 'Farmácia Bem Estar'),
  (2, 'Padaria Pão Dourado'),
  (3, 'Livraria Página Nova');

-- -----------------------------------------------------
-- Tarifas (RN08/RN09) - Data_Vigencia = início da vigência.
-- A vigente numa data D é a de maior Data_Vigencia <= D.
-- Em 05/03/2024 vale a tarifa 2 (R$ 10,00).
-- -----------------------------------------------------
INSERT INTO Tarifa (ID_Tarifa, Valor_hora, Data_Vigencia) VALUES
  (1,  8.00, '2023-01-01'),
  (2, 10.00, '2024-03-01'),
  (3, 12.00, '2024-03-06');

-- -----------------------------------------------------

-- Veículos (15) - 15 modelos, 10 marcas, 9 sem cliente (RN01/RN02)
INSERT INTO Veiculo (Placa, Id_cliente, Cor, Cod_Modelo) VALUES
  ('FKT1A11', 1,    'Prata',    35), -- Toyota Corolla
  ('GHB2B22', 2,    'Preto',    15), -- Chevrolet Onix
  ('JLM3C33', 3,    'Branco',    2), -- Volkswagen Polo
  ('KPR4D44', 4,    'Vermelho',  9), -- Fiat Argo
  ('MNS5E55', 5,    'Cinza',    44), -- Hyundai HB20
  ('QRT6F66', 2,    'Azul',     41), -- Honda Civic
  ('RSV7G77', NULL, 'Branco',   46), -- Hyundai Creta
  ('STU8H88', NULL, 'Verde',    53), -- Jeep Renegade
  ('TUV9J99', NULL, 'Prata',     7), -- Fiat Uno
  ('UVW0K10', NULL, 'Preto',    28), -- Renault Sandero
  ('VWX1L21', NULL, NULL,       22), -- Ford Ka
  ('WXY2M32', NULL, 'Cinza',    18), -- Chevrolet Tracker
  ('XYZ3N43', NULL, 'Branco',   57), -- Peugeot 2008
  ('BCD4P54', NULL, 'Prata',     1), -- Volkswagen Gol
  ('CDE5Q65', NULL, 'Azul',     36); -- Toyota Corolla Cross


-- -----------------------------------------------------
-- Contratos (3, clientes diferentes, 1 encerrado) - RN12/RN14
-- Data_fim NULL = contrato por prazo indeterminado
-- -----------------------------------------------------
INSERT INTO Contrato (ID_Contrato, Data_inicio, Data_fim, Valor_mensal, Id_Cliente, Placa) VALUES
  (1, '2023-07-01', '2023-12-31', 250.00, 1, 'FKT1A11'),
  (2, '2024-01-01', '2024-12-31', 280.00, 2, 'GHB2B22'),
  (3, '2024-02-01', NULL,         300.00, 3, 'JLM3C33');

-- -----------------------------------------------------
-- Mensalidades (7: 5 pagas, 2 pendentes) - RN13
-- -----------------------------------------------------
INSERT INTO Mensalidade (ID_Mensalidade, Competencia, Data_Vencimento, Data_Pagamento, Id_Contrato) VALUES
  (1, '2023-11', '2023-11-10', '2023-11-08', 1),
  (2, '2023-12', '2023-12-10', '2023-12-09', 1),
  (3, '2024-01', '2024-01-10', '2024-01-10', 2),
  (4, '2024-02', '2024-02-10', '2024-02-15', 2),
  (5, '2024-03', '2024-03-10', NULL,         2),
  (6, '2024-02', '2024-02-10', '2024-02-05', 3),
  (7, '2024-03', '2024-03-10', NULL,         3);

-- -----------------------------------------------------
-- Estadias (30) - RN05..RN08, RN11
-- Id_Tarifa: tarifa vigente na data da entrada (rotativas); NULL para mensalistas
-- 4 dias | 3 em aberto | 7 de mensalistas | 10 com loja | várias fracionadas
-- -----------------------------------------------------
INSERT INTO Estadia (ID_Estadia, Data_hora_entrada, Data_hora_saida, Placa, Id_Tarifa, Id_Loja, Id_Estacionamento, Id_Funcionario) VALUES
  -- 29/02/2024 (tarifa 1 - R$ 8,00)
  ( 1, '2024-02-29 08:00:00', '2024-02-29 10:30:00', 'RSV7G77', 1,    1,    1, 1), -- 2h30 -> 3h
  ( 2, '2024-02-29 07:45:00', '2024-02-29 18:10:00', 'GHB2B22', NULL, NULL, 1, 1), -- mensalista
  ( 3, '2024-02-29 09:00:00', '2024-02-29 11:00:00', 'FKT1A11', 1,    NULL, 1, 2), -- contrato encerrado -> rotativa
  ( 4, '2024-02-29 12:10:00', '2024-02-29 13:25:00', 'TUV9J99', 1,    2,    1, 2), -- 1h15 -> 2h
  ( 5, '2024-02-29 08:30:00', '2024-02-29 17:30:00', 'JLM3C33', NULL, NULL, 1, 1), -- mensalista
  ( 6, '2024-02-29 14:00:00', '2024-02-29 14:40:00', 'KPR4D44', 1,    NULL, 1, 3), -- 40min -> 1h
  ( 7, '2024-02-29 15:00:00', '2024-02-29 19:00:00', 'UVW0K10', 1,    NULL, 1, 3), -- 4h
  -- 04/03/2024 (tarifa 2 - R$ 10,00)
  ( 8, '2024-03-04 07:50:00', '2024-03-04 18:00:00', 'GHB2B22', NULL, NULL, 1, 1), -- mensalista
  ( 9, '2024-03-04 08:15:00', '2024-03-04 11:45:00', 'STU8H88', 2,    1,    1, 1), -- 3h30 -> 4h
  (10, '2024-03-04 09:00:00', '2024-03-04 10:00:00', 'MNS5E55', 2,    NULL, 1, 2), -- 1h
  (11, '2024-03-04 10:20:00', '2024-03-04 12:05:00', 'VWX1L21', 2,    2,    1, 2), -- 1h45 -> 2h
  (12, '2024-03-04 13:00:00', '2024-03-04 16:00:00', 'QRT6F66', 2,    NULL, 1, 3), -- 3h (cliente sem contrato p/ este carro)
  (13, '2024-03-04 08:40:00', '2024-03-04 12:00:00', 'JLM3C33', NULL, NULL, 1, 1), -- mensalista
  (14, '2024-03-04 16:30:00', '2024-03-04 17:10:00', 'WXY2M32', 2,    1,    1, 3), -- 40min -> 1h
  -- 05/03/2024 (tarifa 2 - R$ 10,00)
  (15, '2024-03-05 07:40:00', '2024-03-05 17:55:00', 'GHB2B22', NULL, NULL, 1, 1), -- mensalista
  (16, '2024-03-05 08:00:00', '2024-03-05 13:20:00', 'FKT1A11', 2,    NULL, 1, 1), -- 5h20 -> 6h
  (17, '2024-03-05 09:10:00', '2024-03-05 11:10:00', 'XYZ3N43', 2,    2,    1, 2), -- 2h
  (18, '2024-03-05 10:00:00', '2024-03-05 10:50:00', 'BCD4P54', 2,    NULL, 1, 2), -- 50min -> 1h
  (19, '2024-03-05 11:30:00', '2024-03-05 14:45:00', 'CDE5Q65', 2,    1,    1, 3), -- 3h15 -> 4h
  (20, '2024-03-05 13:00:00', '2024-03-05 15:00:00', 'RSV7G77', 2,    NULL, 1, 3), -- 2h
  (21, '2024-03-05 15:20:00', '2024-03-05 18:00:00', 'KPR4D44', 2,    NULL, 1, 1), -- 2h40 -> 3h
  -- 06/03/2024 (tarifa 3 - R$ 12,00)
  (22, '2024-03-06 08:00:00', '2024-03-06 18:30:00', 'JLM3C33', NULL, NULL, 1, 1), -- mensalista
  (23, '2024-03-06 08:30:00', '2024-03-06 09:30:00', 'TUV9J99', 3,    NULL, 1, 1), -- 1h
  (24, '2024-03-06 09:00:00', '2024-03-06 11:30:00', 'MNS5E55', 3,    2,    1, 2), -- 2h30 -> 3h
  (25, '2024-03-06 10:00:00', '2024-03-06 10:20:00', 'UVW0K10', 3,    NULL, 1, 2), -- 20min -> 1h
  (26, '2024-03-06 12:00:00', '2024-03-06 16:10:00', 'STU8H88', 3,    NULL, 1, 3), -- 4h10 -> 5h
  (27, '2024-03-06 13:30:00', '2024-03-06 15:00:00', 'VWX1L21', 3,    1,    1, 3), -- 1h30 -> 2h
  -- Em aberto (veículos dentro do estacionamento)
  (28, '2024-03-06 07:55:00', NULL,                  'GHB2B22', NULL, NULL, 1, 1), -- mensalista
  (29, '2024-03-06 14:00:00', NULL,                  'WXY2M32', 3,    2,    1, 3),
  (30, '2024-03-06 16:45:00', NULL,                  'CDE5Q65', 3,    NULL, 1, 2);

-- -----------------------------------------------------
-- Pagamentos (21) - um por estadia rotativa ENCERRADA (RN10)
-- Valor = tarifa vigente na entrada x horas (fração = hora cheia)
-- -----------------------------------------------------
INSERT INTO Pagamento (ID_Pagamento, Forma, Valor_Pago, Data_hora_pagamento, Id_Estadia, Id_Funcionario) VALUES
  ( 1, 'PIX',      24.00, '2024-02-29 10:30:00',  1, 1),
  ( 2, 'Crédito',  16.00, '2024-02-29 11:00:00',  3, 2),
  ( 3, 'Dinheiro', 16.00, '2024-02-29 13:25:00',  4, 2),
  ( 4, 'Débito',    8.00, '2024-02-29 14:40:00',  6, 3),
  ( 5, 'PIX',      32.00, '2024-02-29 19:00:00',  7, 3),
  ( 6, 'Crédito',  40.00, '2024-03-04 11:45:00',  9, 1),
  ( 7, 'Dinheiro', 10.00, '2024-03-04 10:00:00', 10, 2),
  ( 8, 'PIX',      20.00, '2024-03-04 12:05:00', 11, 2),
  ( 9, 'Débito',   30.00, '2024-03-04 16:00:00', 12, 3),
  (10, 'Dinheiro', 10.00, '2024-03-04 17:10:00', 14, 3),
  (11, 'Crédito',  60.00, '2024-03-05 13:20:00', 16, 1),
  (12, 'PIX',      20.00, '2024-03-05 11:10:00', 17, 2),
  (13, 'Dinheiro', 10.00, '2024-03-05 10:50:00', 18, 2),
  (14, 'Débito',   40.00, '2024-03-05 14:45:00', 19, 3),
  (15, 'PIX',      20.00, '2024-03-05 15:00:00', 20, 3),
  (16, 'Crédito',  30.00, '2024-03-05 18:00:00', 21, 1),
  (17, 'Dinheiro', 12.00, '2024-03-06 09:30:00', 23, 1),
  (18, 'PIX',      36.00, '2024-03-06 11:30:00', 24, 2),
  (19, 'Débito',   12.00, '2024-03-06 10:20:00', 25, 2),
  (20, 'Crédito',  60.00, '2024-03-06 16:10:00', 26, 3),
  (21, 'PIX',      24.00, '2024-03-06 15:00:00', 27, 3);

-- -----------------------------------------------------
-- Ocorrências (5, 4 tipos) - RN15
-- -----------------------------------------------------
INSERT INTO Ocorrencia (ID_Ocorrencia, Data_hora, Tipo, Descricao, Id_Estadia, Id_Funcionario) VALUES
  (1, '2024-02-29 13:00:00', 'Veículo mal estacionado', 'Veículo ocupando duas vagas na área coberta.', 4, 2),
  (2, '2024-03-04 11:30:00', 'Perda de comprovante', 'Motorista perdeu o comprovante de entrada, placa e horário conferidos no sistema.', 11, 2),
  (3, '2024-03-05 14:00:00', 'Veículo mal estacionado', 'Veículo bloqueando a rampa de saída.', 19, 3),
  (4, '2024-03-06 11:00:00', 'Objeto esquecido', 'Carteira encontrada próxima ao veículo e devolvida ao motorista.', 24, 2),
  (5, '2024-03-06 15:00:00', 'Reclamação de cliente', 'Cliente reclamou da demora no atendimento da entrada.', 29, 3);
