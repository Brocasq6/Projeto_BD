-- =============================================================
--  EvenSync — Script de Criação do Esquema (Modelo Físico)
--  Base de Dados — LCC 2025/2026
--  SGBD: MySQL 8.x
--
--  CORREÇÕES APLICADAS (v2):
--  [C1] Evento      — adicionado numero_edicao (RD1 exige-o explicitamente)
--  [C2] Participante — telemovel passou a NOT NULL (RD7: campo obrigatório)
--  [C3] Sessao      — adicionado id_evento FK (1:N em vez de N:M)
--                   — sala passou a NOT NULL (RC6: controlo de sobreposição)
--  [C4] Tabela Tem  — REMOVIDA (era N:M sem base nos requisitos;
--                     substituída pela FK id_evento em Sessao)
--  [OK] Pagamento   — uq_pag_inscricao (UNIQUE) já garantia o 1:1; mantido
--
--  CORREÇÕES APLICADAS (v3):
--  [C5] Evento.tipo — CONSTRAINT CHECK adicionada para restringir os
--                     valores aceites a: 'conferencia', 'workshop',
--                     'corporativo', 'seminario'
-- =============================================================

DROP DATABASE IF EXISTS eventsync;
CREATE DATABASE eventsync
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE eventsync;

-- -------------------------------------------------------------
-- 1. Participante
--    RD7: nome, email, telefone e organização
--    [C2] telemovel: NULL → NOT NULL
-- -------------------------------------------------------------
CREATE TABLE Participante (
    id_participante INT          NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    telemovel       VARCHAR(15)  NOT NULL,          -- [C2] era NULL
    organizacao     VARCHAR(100)     NULL,

    CONSTRAINT pk_participante       PRIMARY KEY (id_participante),
    CONSTRAINT uq_participante_email UNIQUE      (email)
);

-- -------------------------------------------------------------
-- 2. Evento
--    RD1: id, nome, tipo, numero_edicao, data_inicio, data_fim,
--         localizacao, capacidade, descricao
--    [C1] numero_edicao: campo novo (estava omitido)
--    [C5] tipo: restrito a conferencia | workshop | corporativo | seminario
-- -------------------------------------------------------------
CREATE TABLE Evento (
    id_evento      INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(150) NOT NULL,
    tipo           VARCHAR(50)  NOT NULL,
    numero_edicao  INT          NOT NULL,           -- [C1] novo campo
    data_inicio    DATE         NOT NULL,
    data_fim       DATE         NOT NULL,
    localizacao    VARCHAR(150) NOT NULL,
    descricao      TEXT             NULL,
    capacidade     INT          NOT NULL,

    CONSTRAINT pk_evento            PRIMARY KEY (id_evento),
    CONSTRAINT ck_evento_tipo       CHECK (tipo IN ('conferencia','workshop','corporativo','seminario')),  -- [C5]
    CONSTRAINT ck_evento_datas      CHECK (data_inicio <= data_fim),
    CONSTRAINT ck_evento_capacidade CHECK (capacidade > 0),
    CONSTRAINT ck_evento_edicao     CHECK (numero_edicao > 0)
);

-- -------------------------------------------------------------
-- 3. Organizador
--    RD2: id, nome, email, telefone
-- -------------------------------------------------------------
CREATE TABLE Organizador (
    id_organizador INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL,
    telefone       VARCHAR(15)      NULL,

    CONSTRAINT pk_organizador       PRIMARY KEY (id_organizador),
    CONSTRAINT uq_organizador_email UNIQUE      (email)
);

-- -------------------------------------------------------------
-- 4. Sessao
--    RD4: id, titulo, sala, data, hora_inicio, hora_fim, descricao
--    RC6: não pode haver sobreposição de sessões na mesma sala
--    [C3a] id_evento INT NOT NULL FK → Evento  (1:N — RD4 "associadas a UM evento")
--    [C3b] sala: NULL → NOT NULL  (RC6 pressupõe sala sempre preenchida)
--    [C4]  tabela Tem removida; relação gerida por este FK
-- -------------------------------------------------------------
CREATE TABLE Sessao (
    id_sessao   INT          NOT NULL AUTO_INCREMENT,
    tema        VARCHAR(150) NOT NULL,
    data        DATE         NOT NULL,
    hora_inicio TIME         NOT NULL,
    hora_fim    TIME         NOT NULL,
    sala        VARCHAR(50)  NOT NULL,              -- [C3b] era NULL
    id_evento   INT          NOT NULL,              -- [C3a] novo FK

    CONSTRAINT pk_sessao        PRIMARY KEY (id_sessao),
    CONSTRAINT fk_sessao_evento FOREIGN KEY (id_evento)
        REFERENCES Evento(id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_sessao_horas  CHECK (hora_inicio < hora_fim)
);

-- -------------------------------------------------------------
-- 5. Orador
--    RD5: id, nome, email, biografia, especialidade
-- -------------------------------------------------------------
CREATE TABLE Orador (
    id_orador     INT          NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,

    CONSTRAINT pk_orador       PRIMARY KEY (id_orador),
    CONSTRAINT uq_orador_email UNIQUE      (email)
);

-- -------------------------------------------------------------
-- 6. Inscricao  (R1: Participante 1—N; R2: Evento 1—N)
--    RD8: id, data_inscricao, estado
--    RC1: um participante não pode ter mais de uma inscrição activa
--         no mesmo evento → UNIQUE(id_participante, id_evento)
-- -------------------------------------------------------------
CREATE TABLE Inscricao (
    id_inscricao    INT         NOT NULL AUTO_INCREMENT,
    data_inscricao  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          VARCHAR(15) NOT NULL DEFAULT 'pendente',
    id_participante INT         NOT NULL,
    id_evento       INT         NOT NULL,

    CONSTRAINT pk_inscricao        PRIMARY KEY (id_inscricao),
    CONSTRAINT fk_insc_part        FOREIGN KEY (id_participante)
        REFERENCES Participante(id_participante)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_insc_evento      FOREIGN KEY (id_evento)
        REFERENCES Evento(id_evento)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_insc_part_evento UNIQUE (id_participante, id_evento),  -- RC1
    CONSTRAINT ck_insc_estado      CHECK  (estado IN ('pendente','confirmada','cancelada'))
);

-- -------------------------------------------------------------
-- 7. Pagamento  (R3: Inscricao 1—1)
--    RD9: id, valor, data_pagamento, metodo, estado
--    RC2: cada inscrição tem no máximo um pagamento
--    [OK] uq_pag_inscricao (UNIQUE) já existia e garante o 1:1
-- -------------------------------------------------------------
CREATE TABLE Pagamento (
    id_pagamento   INT          NOT NULL AUTO_INCREMENT,
    valor          DECIMAL(8,2) NOT NULL,
    data_pagamento DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo         VARCHAR(20)  NOT NULL,
    estado         VARCHAR(15)  NOT NULL DEFAULT 'pendente',
    id_inscricao   INT          NOT NULL,

    CONSTRAINT pk_pagamento     PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pag_insc      FOREIGN KEY (id_inscricao)
        REFERENCES Inscricao(id_inscricao)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_pag_inscricao UNIQUE (id_inscricao),                    -- RC2 / 1:1
    CONSTRAINT ck_pag_metodo    CHECK  (metodo IN ('cartao','transferencia','MBWay','numerario')),
    CONSTRAINT ck_pag_estado    CHECK  (estado IN ('pendente','pago','rejeitado')),
    CONSTRAINT ck_pag_valor     CHECK  (valor > 0)
);

-- -------------------------------------------------------------
-- 8. Gere  (R4: Organizador N—M Evento)
--    RD3: um organizador pode gerir múltiplos eventos e vice-versa
-- -------------------------------------------------------------
CREATE TABLE Gere (
    id_organizador INT NOT NULL,
    id_evento      INT NOT NULL,

    CONSTRAINT pk_gere        PRIMARY KEY (id_organizador, id_evento),
    CONSTRAINT fk_gere_org    FOREIGN KEY (id_organizador)
        REFERENCES Organizador(id_organizador)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_gere_evento FOREIGN KEY (id_evento)
        REFERENCES Evento(id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- -------------------------------------------------------------
-- 9. Apresentada  (R6: Sessao N—M Orador)
--    RD6: uma sessão pode ter vários oradores; um orador pode
--         apresentar em várias sessões
-- -------------------------------------------------------------
CREATE TABLE Apresentada (
    id_sessao INT NOT NULL,
    id_orador INT NOT NULL,

    CONSTRAINT pk_apresentada PRIMARY KEY (id_sessao, id_orador),
    CONSTRAINT fk_apr_sessao  FOREIGN KEY (id_sessao)
        REFERENCES Sessao(id_sessao)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_apr_orador  FOREIGN KEY (id_orador)
        REFERENCES Orador(id_orador)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =============================================================
--  Verificação: listar tabelas criadas (deve mostrar 9 tabelas)
--  Participante, Evento, Organizador, Sessao, Orador,
--  Inscricao, Pagamento, Gere, Apresentada
-- =============================================================
SHOW TABLES;