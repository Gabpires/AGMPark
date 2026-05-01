-- Criação do banco
CREATE DATABASE TesteAGMpark;

USE TesteAGMpark;

CREATE TABLE funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    primeiro_nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(18) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('PROPRIETARIO','FUNCIONARIO') NOT NULL,
    status ENUM('ATIVO','INATIVO') DEFAULT 'ATIVO',
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estacionamento (
    id_estacionamento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    rua VARCHAR(150) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    numero_estacionamento INT NOT NULL,
    cep VARCHAR(10) NOT NULL,
    quantidade_tempo INT NOT NULL,
    valor_tempo DECIMAL(10,2) NOT NULL,
    numero_vagas INT NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ATIVO','INATIVO') DEFAULT 'ATIVO',
    UNIQUE(nome, rua, numero_estacionamento)
);

CREATE TABLE veiculos (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    placa VARCHAR(10) NOT NULL UNIQUE,
    status ENUM('ATIVO','INATIVO') DEFAULT 'ATIVO'
);

CREATE TABLE vagas (
    id_vaga INT AUTO_INCREMENT PRIMARY KEY,
    id_estacionamento INT NOT NULL,
    numero_vaga INT NOT NULL,
    status ENUM('LIVRE','RESERVADA','OCUPADA','MANUTENCAO') DEFAULT 'LIVRE',
    FOREIGN KEY (id_estacionamento)
        REFERENCES estacionamento(id_estacionamento),
    UNIQUE(id_estacionamento, numero_vaga)
);

CREATE TABLE reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_estacionamento INT NOT NULL,
    id_vaga INT NULL,
    data_reserva DATETIME NOT NULL,
    data_expiracao DATETIME NOT NULL,
    data_cancelamento DATETIME NULL,
    valor DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status ENUM('ATIVA','CANCELADA','EXPIRADA','CONCLUIDA') DEFAULT 'ATIVA',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (id_veiculo)
        REFERENCES veiculos(id_veiculo),
    FOREIGN KEY (id_estacionamento)
        REFERENCES estacionamento(id_estacionamento),
    FOREIGN KEY (id_vaga)
        REFERENCES vagas(id_vaga)
);

CREATE TABLE estadias (
    id_estadia INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_vaga INT NOT NULL,
    id_reserva INT NULL,
    data_entrada DATETIME NOT NULL,
    data_saida DATETIME NULL,
    valor_total DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('EM_ANDAMENTO','FINALIZADA','CANCELADA') DEFAULT 'EM_ANDAMENTO',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (id_veiculo)
        REFERENCES veiculos(id_veiculo),
    FOREIGN KEY (id_vaga)
        REFERENCES vagas(id_vaga),
    FOREIGN KEY (id_reserva)
        REFERENCES reservas(id_reserva)
);

CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_estadia INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    taxa_app DECIMAL(10,2) DEFAULT 0.00,
    forma_pagamento VARCHAR(50) NOT NULL,
    data_pagamento DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_estadia)
        REFERENCES estadias(id_estadia)
);

ALTER TABLE pagamentos
ADD COLUMN status ENUM('PAGO','CANCELADO') DEFAULT 'PAGO';



CREATE TABLE funcionario_estacionamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    id_estacionamento INT NOT NULL,
    FOREIGN KEY (id_funcionario)
        REFERENCES funcionario(id_funcionario)
        ON DELETE CASCADE,
    FOREIGN KEY (id_estacionamento)
        REFERENCES estacionamento(id_estacionamento)
        ON DELETE CASCADE,
    UNIQUE(id_funcionario, id_estacionamento)
);

CREATE TABLE horarios_funcionamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_estacionamento INT NOT NULL,
    dia_semana ENUM('SEG','TER','QUA','QUI','SEX','SAB','DOM') NOT NULL,
    hora_abertura TIME NOT NULL,
    hora_fechamento TIME NOT NULL,
    FOREIGN KEY (id_estacionamento)
        REFERENCES estacionamento(id_estacionamento)
        ON DELETE CASCADE,
    UNIQUE(id_estacionamento, dia_semana)
);

ALTER TABLE horarios_funcionamento
ADD COLUMN status ENUM('ATIVO','INATIVO') DEFAULT 'ATIVO';

CREATE TABLE tarifas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_estacionamento INT NOT NULL,
    tempo INT NOT NULL,
    unidade ENUM('MINUTO') NOT NULL DEFAULT 'MINUTO',
    valor DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_estacionamento)
        REFERENCES estacionamento(id_estacionamento)
        ON DELETE CASCADE
);

ALTER TABLE tarifas 
ADD COLUMN status ENUM('ATIVO','INATIVO') DEFAULT 'ATIVO';

CREATE INDEX idx_vagas_status ON vagas(status);
CREATE INDEX idx_reservas_status ON reservas(status);
CREATE INDEX idx_reservas_veiculo ON reservas(id_veiculo);
CREATE INDEX idx_estadias_status ON estadias(status);
CREATE INDEX idx_estadias_veiculo ON estadias(id_veiculo);
CREATE INDEX idx_pagamentos_estadia ON pagamentos(id_estadia);
