-- =====================================================
-- PROJETO A3 - CONTROLE DE ESTACIONAMENTO
-- Arquivo: 03-consultas.sql
-- As 17 consultas obrigatórias
-- Convenções:
--   * duração em segundos = strftime('%s', saida) - strftime('%s', entrada)
--   * horas cobradas (fração = hora cheia) = (segundos + 3599) / 3600  (divisão inteira)
--   * tarifa vigente em D = a de maior Data_Vigencia <= D
--   * contrato vigente em D = Data_inicio <= D AND (Data_fim IS NULL OR Data_fim >= D)
-- =====================================================

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------
-- Consulta 01 (RN06): Quais veículos estão no estacionamento agora
-- (entrada sem saída)? Placa e horário de entrada, do mais antigo ao mais recente.
-- -----------------------------------------------------
SELECT e.Placa,
       e.Data_hora_entrada
FROM Estadia AS e
WHERE e.Data_hora_saida IS NULL
ORDER BY e.Data_hora_entrada ASC;

-- -----------------------------------------------------
-- Consulta 02 (RN02): Quais veículos cadastrados não têm cliente associado?
-- -----------------------------------------------------
SELECT v.Placa,
       mo.nome AS Modelo,
       ma.nome AS Marca
FROM Veiculo AS v
JOIN modelo AS mo ON mo.cod_modelo = v.Cod_Modelo
JOIN marca  AS ma ON ma.cod_marca  = mo.cod_marca
WHERE v.Id_Cliente IS NULL
ORDER BY v.Placa;

-- -----------------------------------------------------
-- Consulta 03 (RN13): Quais mensalidades ainda não foram pagas?
-- Contrato, competência e vencimento.
-- -----------------------------------------------------
SELECT m.Id_Contrato,
       m.Competencia,
       m.Data_Vencimento
FROM Mensalidade AS m
WHERE m.Data_Pagamento IS NULL
ORDER BY m.Data_Vencimento, m.Id_Contrato;

-- -----------------------------------------------------
-- Consulta 04 (RN09): Qual era a tarifa por hora vigente em 05/03/2024?
-- -----------------------------------------------------
SELECT t.ID_Tarifa,
       t.Valor_hora,
       t.Data_Vigencia
FROM Tarifa AS t
WHERE t.Data_Vigencia <= '2024-03-05'
ORDER BY t.Data_Vigencia DESC
LIMIT 1;

-- -----------------------------------------------------
-- Consulta 05 (RN06): Quantas estadias começaram em cada dia?
-- -----------------------------------------------------
SELECT date(e.Data_hora_entrada) AS Dia,
       COUNT(*)                  AS Qtd_Estadias
FROM Estadia AS e
GROUP BY date(e.Data_hora_entrada)
ORDER BY Dia;

-- -----------------------------------------------------
-- Consulta 06 (RN10): Quanto foi recebido em cada forma de pagamento?
-- -----------------------------------------------------
SELECT p.Forma,
       COUNT(*)                     AS Qtd_Pagamentos,
       ROUND(SUM(p.Valor_Pago), 2)  AS Total_Recebido
FROM Pagamento AS p
GROUP BY p.Forma
ORDER BY Total_Recebido DESC;

-- -----------------------------------------------------
-- Consulta 07 (RN15): Quantas ocorrências houve de cada tipo?
-- -----------------------------------------------------
SELECT o.Tipo,
       COUNT(*) AS Qtd_Ocorrencias
FROM Ocorrencia AS o
GROUP BY o.Tipo
ORDER BY Qtd_Ocorrencias DESC, o.Tipo;

-- -----------------------------------------------------
-- Consulta 08 (RN06): Qual a permanência média, em minutos, das estadias encerradas?
-- -----------------------------------------------------
SELECT ROUND(AVG(
         (strftime('%s', e.Data_hora_saida) - strftime('%s', e.Data_hora_entrada)) / 60.0
       ), 2) AS Permanencia_Media_Min
FROM Estadia AS e
WHERE e.Data_hora_saida IS NOT NULL;

-- -----------------------------------------------------
-- Consulta 09 (RN01): Para cada estadia, mostrar a placa, a marca e o modelo do veículo.
-- -----------------------------------------------------
SELECT e.ID_Estadia,
       e.Placa,
       ma.nome AS Marca,
       mo.nome AS Modelo
FROM Estadia AS e
JOIN Veiculo AS v  ON v.Placa       = e.Placa
JOIN modelo  AS mo ON mo.cod_modelo = v.Cod_Modelo
JOIN marca   AS ma ON ma.cod_marca  = mo.cod_marca
ORDER BY e.ID_Estadia;

-- -----------------------------------------------------
-- Consulta 10 (RN12): Listar os contratos com o nome do cliente, a placa e o modelo do veículo.
-- -----------------------------------------------------
SELECT c.ID_Contrato,
       cl.Nome  AS Cliente,
       c.Placa,
       mo.nome  AS Modelo,
       c.Data_inicio,
       c.Data_fim,
       c.Valor_mensal
FROM Contrato AS c
JOIN Cliente AS cl ON cl.ID_Cliente = c.Id_Cliente
JOIN Veiculo AS v  ON v.Placa       = c.Placa
JOIN modelo  AS mo ON mo.cod_modelo = v.Cod_Modelo
ORDER BY c.ID_Contrato;

-- -----------------------------------------------------
-- Consulta 11 (RN11): Quantas estadias cada loja conveniada vinculou,
-- incluindo as lojas sem nenhuma?
-- -----------------------------------------------------
SELECT l.ID_Loja,
       l.Nome,
       COUNT(e.ID_Estadia) AS Qtd_Estadias
FROM Loja_Conveniada AS l
LEFT JOIN Estadia AS e ON e.Id_Loja = l.ID_Loja
GROUP BY l.ID_Loja, l.Nome
ORDER BY Qtd_Estadias DESC, l.ID_Loja;

-- -----------------------------------------------------
-- Consulta 12 (RN15): Listar as ocorrências com data e hora, tipo,
-- placa do veículo e nome do funcionário que registrou.
-- -----------------------------------------------------
SELECT o.Data_hora,
       o.Tipo,
       e.Placa,
       f.Nome AS Funcionario
FROM Ocorrencia AS o
JOIN Estadia     AS e ON e.ID_Estadia     = o.Id_Estadia
JOIN Funcionario AS f ON f.ID_Funcionario = o.Id_Funcionario
ORDER BY o.Data_hora;

-- -----------------------------------------------------
-- Consulta 13 (RN03, RN04): Quantas vagas estão livres agora?
-- Capacidade menos as estadias sem saída (rotativos e mensalistas).
-- -----------------------------------------------------
SELECT es.Nome,
       es.Capacidade,
       COUNT(e.ID_Estadia)                 AS Veiculos_Dentro,
       es.Capacidade - COUNT(e.ID_Estadia) AS Vagas_Livres
FROM Estacionamento AS es
LEFT JOIN Estadia AS e
       ON e.Id_Estacionamento = es.ID_Estacionamento
      AND e.Data_hora_saida IS NULL
GROUP BY es.ID_Estacionamento, es.Nome, es.Capacidade;

-- -----------------------------------------------------
-- Consulta 14 (RN08, RN09): Valor devido em cada estadia rotativa encerrada,
-- pela tarifa vigente na data da entrada, com fração contando como hora cheia.
-- Rotativa = sem contrato vigente na data da entrada (RN07).
-- -----------------------------------------------------
WITH encerradas AS (
    SELECT e.ID_Estadia,
           e.Placa,
           e.Data_hora_entrada,
           e.Data_hora_saida,
           strftime('%s', e.Data_hora_saida) - strftime('%s', e.Data_hora_entrada) AS Segundos
    FROM Estadia AS e
    WHERE e.Data_hora_saida IS NOT NULL
      AND NOT EXISTS (
            SELECT 1 FROM Contrato AS c
            WHERE c.Placa = e.Placa
              AND c.Data_inicio <= date(e.Data_hora_entrada)
              AND (c.Data_fim IS NULL OR c.Data_fim >= date(e.Data_hora_entrada))
      )
)
SELECT r.ID_Estadia,
       r.Placa,
       r.Data_hora_entrada,
       r.Data_hora_saida,
       ROUND(r.Segundos / 60.0, 0)   AS Minutos,
       (r.Segundos + 3599) / 3600    AS Horas_Cobradas,
       (SELECT t.Valor_hora FROM Tarifa AS t
         WHERE t.Data_Vigencia <= date(r.Data_hora_entrada)
         ORDER BY t.Data_Vigencia DESC LIMIT 1)                        AS Valor_Hora,
       ROUND(((r.Segundos + 3599) / 3600) *
             (SELECT t.Valor_hora FROM Tarifa AS t
               WHERE t.Data_Vigencia <= date(r.Data_hora_entrada)
               ORDER BY t.Data_Vigencia DESC LIMIT 1), 2)              AS Valor_Devido
FROM encerradas AS r
ORDER BY r.ID_Estadia;

-- -----------------------------------------------------
-- Consulta 15 (RN07): Classificar cada estadia como rotativa ou de mensalista
-- (veículo com contrato vigente na data da entrada).
-- -----------------------------------------------------
SELECT e.ID_Estadia,
       e.Placa,
       e.Data_hora_entrada,
       CASE WHEN EXISTS (
                SELECT 1 FROM Contrato AS c
                WHERE c.Placa = e.Placa
                  AND c.Data_inicio <= date(e.Data_hora_entrada)
                  AND (c.Data_fim IS NULL OR c.Data_fim >= date(e.Data_hora_entrada))
            ) THEN 'Mensalista'
            ELSE 'Rotativa'
       END AS Tipo_Estadia
FROM Estadia AS e
ORDER BY e.ID_Estadia;

-- -----------------------------------------------------
-- Consulta 16 (RN05) - AUDITORIA: quais placas têm mais de uma estadia em aberto?
-- (deve retornar vazio)
-- -----------------------------------------------------
SELECT e.Placa,
       COUNT(*) AS Estadias_Abertas
FROM Estadia AS e
WHERE e.Data_hora_saida IS NULL
GROUP BY e.Placa
HAVING COUNT(*) > 1;

-- -----------------------------------------------------
-- Consulta 17 (RN14) - AUDITORIA: quais contratos do mesmo veículo têm
-- períodos sobrepostos? (deve retornar vazio)
-- Data_fim NULL = vigência aberta (tratada como '9999-12-31').
-- -----------------------------------------------------
SELECT c1.Placa,
       c1.ID_Contrato AS Contrato_A, c1.Data_inicio AS Inicio_A, c1.Data_fim AS Fim_A,
       c2.ID_Contrato AS Contrato_B, c2.Data_inicio AS Inicio_B, c2.Data_fim AS Fim_B
FROM Contrato AS c1
JOIN Contrato AS c2
  ON  c1.Placa       = c2.Placa
  AND c1.ID_Contrato < c2.ID_Contrato
WHERE c1.Data_inicio <= COALESCE(c2.Data_fim, '9999-12-31')
  AND c2.Data_inicio <= COALESCE(c1.Data_fim, '9999-12-31');
