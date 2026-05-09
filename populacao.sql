-- =============================================================
--  EvenSync — Povoamento da Base de Dados
--  Base de Dados — LCC 2025/2026
--  6 Organizadores | 7 Eventos | 8 Sessões | 8 Oradores
--  10 Participantes | 14 Inscrições | 14 Pagamentos
-- =============================================================

USE eventsync;

-- -------------------------------------------------------------
-- 1. ORGANIZADORES (IDs 1–6)
-- -------------------------------------------------------------
INSERT INTO Organizador (nome, email, telefone) VALUES
('José Bumblebee',  'jose.bumblebee@eventsync.pt',      '253000001'),
('André Marques',   'a111634@alunos.uminho.pt',          '253604401'),
('Bruno Freitas',   'a110016@alunos.uminho.pt',          '253604402'),
('João Ribeiro',    'a111041@alunos.uminho.pt',          '253604403'),
('Tiago Santos',    'a110313@alunos.uminho.pt',          '253604404'),
('Nelson Antunes',  'a110360@alunos.uminho.pt',          '253604405');

-- -------------------------------------------------------------
-- 2. EVENTOS (IDs 1–7)
--    Cobre os 4 tipos permitidos: conferencia, workshop,
--    corporativo, seminario
-- -------------------------------------------------------------
INSERT INTO Evento (nome, tipo, numero_edicao, data_inicio, data_fim, localizacao, capacidade, descricao) VALUES
('Workshop Flutter & Dart',              'workshop',    2,  '2026-05-25', '2026-05-25', 'DI-A1',       45,  'Desenvolvimento mobile multiplataforma.'),
('Congresso Nacional de Cibersegurança', 'conferencia', 5,  '2026-06-10', '2026-06-12', 'Auditório B1',300, 'Debate sobre ameaças e defesa digital.'),
('Hackathon UMinho 2026',                'workshop',    1,  '2026-09-01', '2026-09-03', 'CP1',         100, '48 horas de código sem parar.'),
('Sessão Solene de Abertura LCC',        'corporativo', 32, '2026-09-15', '2026-09-15', 'Auditório B2',150, 'Boas-vindas aos novos alunos.'),
('Seminário de Bases de Dados',          'seminario',   3,  '2026-10-05', '2026-10-05', 'DI-B1',       60,  'Tendências e práticas em SGBD relacionais.'),
('Encontro de Inovação Empresarial',     'corporativo', 7,  '2026-10-20', '2026-10-21', 'Auditório B2',200, 'Networking e apresentação de casos de sucesso.'),
('Conferência de Inteligência Artificial','conferencia', 2,  '2026-11-20', '2026-11-22', 'Auditório B1',250, 'Avanços recentes em IA e Machine Learning.');

-- -------------------------------------------------------------
-- 3. GERE — Organizador gere Evento (N:M)
-- -------------------------------------------------------------
INSERT INTO Gere (id_organizador, id_evento) VALUES
(1, 1), (1, 2),   -- José gere Workshop e Congresso
(2, 3),           -- André gere Hackathon
(3, 4), (6, 4),   -- Bruno e Nelson gerem Sessão Solene
(4, 5), (4, 6),   -- João gere Seminário e Encontro
(5, 7);           -- Tiago gere Conferência de IA

-- -------------------------------------------------------------
-- 4. ORADORES (IDs 1–8)
-- -------------------------------------------------------------
INSERT INTO Orador (nome, email, especialidade) VALUES
('Prof. Alberto Silva',  'alberto@di.uminho.pt',     'Engenharia de Software'),
('Eng. Maria Fontes',    'mfontes@checkpoint.com',   'Network Security'),
('Dr. Ricardo Jorge',    'rjorge@google.com',        'Cloud Computing'),
('Sara Antunes',         'sara@flutter.dev',         'Mobile Dev'),
('Nelson Antunes',       'nantunes@di.uminho.pt',    'Distributed Databases'),
('Prof. Paulo Martins',  'pmartins@di.uminho.pt',    'Inteligência Artificial'),
('Dra. Sofia Costa',     'scosta@inovacao.pt',       'Inovação Empresarial'),
('Eng. Rui Pereira',     'rpereira@checkpoint.com',  'Cibersegurança');

-- -------------------------------------------------------------
-- 5. SESSÕES (IDs 1–8)
-- -------------------------------------------------------------
INSERT INTO Sessao (tema, data, hora_inicio, hora_fim, sala, id_evento) VALUES
('Introdução ao Flutter',           '2026-05-25', '09:00:00', '11:00:00', 'DI-A1',       1),
('Widgets Avançados',               '2026-05-25', '11:30:00', '13:00:00', 'DI-A1',       1),
('Painel: IA e Cibersegurança',     '2026-06-10', '14:30:00', '16:00:00', 'Auditório B1',2),
('Criptografia Quântica',           '2026-06-11', '10:00:00', '12:00:00', 'Auditório B1',2),
('Final Pitch & Demo Day',          '2026-09-03', '15:00:00', '18:00:00', 'CP1',         3),
('Abertura Oficial',                '2026-09-15', '09:00:00', '10:00:00', 'Auditório B2',4),
('Fundamentos de BD Relacionais',   '2026-10-05', '10:00:00', '12:00:00', 'DI-B1',       5),
('Tendências em Machine Learning',  '2026-11-20', '14:00:00', '16:00:00', 'Auditório B1',7);

-- -------------------------------------------------------------
-- 6. APRESENTADA — Orador apresenta Sessão (N:M)
-- -------------------------------------------------------------
INSERT INTO Apresentada (id_sessao, id_orador) VALUES
(1, 4),         -- Sara na sessão de Flutter Intro
(2, 4),         -- Sara em Widgets Avançados
(3, 1), (3, 2), -- Alberto e Maria no painel de IA
(4, 8),         -- Rui na Criptografia Quântica
(5, 5),         -- Nelson no Hackathon
(7, 5),         -- Nelson no Seminário de BD
(8, 6);         -- Paulo em Machine Learning

-- -------------------------------------------------------------
-- 7. PARTICIPANTES (IDs 1–10)
-- -------------------------------------------------------------
INSERT INTO Participante (nome, email, telemovel, organizacao) VALUES
('Tiago Santos',    'tiago.a110313@alunos.uminho.pt', '910000001', 'UMinho'),
('Bruno Freitas',   'bruno.a110016@alunos.uminho.pt', '910000002', 'UMinho'),
('João Silva',      'jsilva@empresa.pt',               '920000001', 'TechCorp'),
('Maria Oliveira',  'moliveira@gmail.com',             '930000001',  NULL),
('Ricardo Costa',   'rcosta@hotmail.com',              '960000001', 'IT Solutions'),
('Sílvia Mendes',   'smendes@alunos.uminho.pt',        '910000003', 'UMinho'),
('Nuno Rocha',      'nuno.rocha@ieee.org',             '910000004', 'IEEE Student Branch'),
('Beatriz Dias',    'beatriz@gmail.com',               '920000002',  NULL),
('Fernando Pessoa', 'fpessoa@literatura.pt',           '910000005', 'Casa Fernando Pessoa'),
('Marta Ferreira',  'marta.f@uminho.pt',               '253000010', 'UMinho');

-- -------------------------------------------------------------
-- 8. INSCRIÇÕES (IDs 1–14)
--    Estados variados para testar RM3, RM4, RM10
--    UNIQUE(id_participante, id_evento) garante RC1
-- -------------------------------------------------------------
INSERT INTO Inscricao (id_participante, id_evento, estado) VALUES
(1, 1, 'confirmada'), (2, 1, 'confirmada'), (3, 1, 'pendente'),     -- Workshop Flutter
(1, 2, 'confirmada'), (4, 2, 'confirmada'), (5, 2, 'cancelada'),    -- Congresso
(6, 2, 'confirmada'), (7, 2, 'confirmada'), (8, 2, 'confirmada'),   -- Congresso (cont.)
(1, 3, 'confirmada'), (9, 3, 'confirmada'), (10, 3, 'confirmada'),  -- Hackathon
(1, 4, 'confirmada'), (10, 4, 'confirmada');                        -- Sessão Solene

-- -------------------------------------------------------------
-- 9. PAGAMENTOS (IDs 1–14)
--    Métodos e estados distintos para testar RM5, RM10
--    uq_pag_inscricao garante RC2 (1 pagamento por inscrição)
--    Todas as inscrições têm pagamento (R3 P:T — Inscrição parcial, Pagamento total)
-- -------------------------------------------------------------
INSERT INTO Pagamento (valor, metodo, estado, id_inscricao) VALUES
(10.00, 'MBWay',        'pago',      1),  -- Tiago pagou Workshop
(10.00, 'cartao',       'pago',      2),  -- Bruno pagou Workshop
(10.00, 'transferencia','pendente',  3),  -- João Silva pagamento pendente (inscrição pendente)
(25.00, 'transferencia','pago',      4),  -- Tiago pagou Congresso
(25.00, 'MBWay',        'pendente',  5),  -- Maria pagamento pendente
(25.00, 'cartao',       'pago',      6),  -- Sílvia pagou Congresso
(25.00, 'cartao',       'pago',      7),  -- Nuno pagou Congresso
(25.00, 'transferencia','pago',      8),  -- Beatriz pagou Congresso
(25.00, 'MBWay',        'rejeitado', 9),  -- Beatriz 2.º pagamento rejeitado
(5.00,  'numerario',    'pago',      10), -- Tiago pagou Hackathon
(5.00,  'MBWay',        'pago',      11), -- Fernando Pessoa pagou Hackathon
(5.00,  'cartao',       'pago',      12), -- Marta pagou Hackathon
(5.00,  'numerario',    'pago',      13), -- Tiago pagou Sessão Solene
(5.00,  'MBWay',        'pago',      14); -- Marta pagou Sessão Solene
