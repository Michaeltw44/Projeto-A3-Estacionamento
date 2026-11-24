# Decisões de Projeto – Sistema de Estacionamento

## 1. Banco de dados utilizado

Foi escolhido o SQLite como sistema gerenciador de banco de dados, utilizando o DB Browser for SQLite para criação, execução e validação dos scripts SQL.

## 2. Tabelas fornecidas pelo professor

As tabelas `Marca` e `Modelo` foram mantidas conforme a estrutura disponibilizada pelo professor. Elas não foram recriadas nem modificadas, sendo utilizadas como referência para o cadastro dos veículos.

## 3. Cadastro de veículos e clientes

Foi definido que um veículo pode estar cadastrado sem um cliente associado, pois o sistema também atende veículos de clientes não cadastrados previamente. Por esse motivo, a chave estrangeira de cliente na tabela `Veiculo` permite valores nulos.

A placa foi definida como identificador único do veículo.

## 4. Controle de estadias

A tabela `Estadia` registra a entrada e a saída dos veículos. O campo de data e hora de saída permite valor nulo para representar uma estadia ainda aberta.

Foi utilizado um índice único parcial para impedir que um mesmo veículo possua mais de uma estadia aberta simultaneamente.

## 5. Controle de tarifas e pagamentos

As tarifas são armazenadas separadamente para permitir o registro de diferentes valores e suas respectivas datas de vigência.

O pagamento é associado à estadia e possui uma restrição de unicidade para impedir mais de um pagamento por estadia.

As formas de pagamento aceitas são dinheiro, débito, crédito e PIX.

## 6. Controle de contratos e mensalidades

Os contratos registram o cliente titular, o veículo associado, o período de vigência e o valor mensal.

As mensalidades são registradas por competência, com restrição para impedir duplicidade de mensalidades do mesmo contrato na mesma competência.

A ausência de uma data de pagamento representa uma mensalidade pendente.

## 7. Integridade e regras de negócio

Foram utilizadas chaves primárias, chaves estrangeiras, restrições `NOT NULL`, `UNIQUE` e `CHECK` para garantir a integridade dos dados.

Também foram utilizadas restrições para validar datas, valores e impedir situações incompatíveis com as regras de negócio do estacionamento.

## 8. Tabela associativa Emprega

Foi mantida a tabela associativa `Emprega` para representar o relacionamento entre funcionários e estacionamentos, permitindo registrar a associação entre essas entidades.

## 9. Organização dos scripts

Os scripts SQL foram separados por finalidade:

- `00-base-fornecida.sql`: estrutura disponibilizada pelo professor.
- `01-schema.sql`: criação das tabelas e restrições.
- `02-dados.sql`: inserção dos dados fictícios.
- `03-consultas.sql`: consultas utilizadas para atender aos requisitos do projeto.

Essa organização facilita a execução, manutenção e validação do banco de dados.