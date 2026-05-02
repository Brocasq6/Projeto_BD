-- =============================================================
--  EvenSync — Povoamento Extenso (v2)
--  Foco: Diversidade de dados para testes de stress e lógica
-- =============================================================

USE eventsync;

-- 1. MAIS ORGANIZADORES
INSERT INTO Organizador (nome, email, telefone) VALUES
('André Marques', 'amarques@di.uminho.pt', '253604401'),
('João Ribeiro', 'jribeiro@di.uminho.pt', '253604402'),
('Centro de Computação Gráfica', 'geral@ccg.pt', '253510580');

-- 2. MAIS EVENTOS (Tipos variados para testar filtros RM1)
INSERT INTO Evento (nome, tipo, numero_edicao, data_inicio, data_fim, localizacao, capacidade, descricao) VALUES
('Workshop Flutter & Dart', 'Workshop', 2, '2026-05-25', '2026-05-25', 'DI-A1', 45, 'Desenvolvimento mobile multiplataforma.'),
('Congresso Nacional de Cibersegurança', 'Conferência', 5, '2026-06-10', '2026-06-12', 'Auditório B1', 300, 'Debate sobre ameaças e defesa digital.'),
('Hackathon UMinho 2026', 'Competição', 1, '2026-09-01', '2026-09-03', 'CP1', 100, '48 horas de código sem parar.'),
('Sessão Solene de Abertura LCC', 'Sessão', 32, '2026-09-15', '2026-09-15', 'Auditório B2', 150, 'Boas-vindas aos novos alunos.');

-- 3. GERE (Associações de gestão)
INSERT INTO Gere (id_organizador, id_evento) VALUES
(4, 4), (4, 5), -- André gere o Workshop e o Congresso
(5, 6),        -- João gere o Hackathon
(6, 7);        -- CCG gere a Sessão Solene

-- 4. MAIS ORADORES (Especialistas convidados)
INSERT INTO Orador (nome, email, especialidade) VALUES
('Prof. Alberto Silva', 'alberto@di.uminho.pt', 'Engenharia de Software'),
('Eng. Maria Fontes', 'mfontes@CheckPoint.com', 'Network Security'),
('Dr. Ricardo Jorge', 'rjorge@google.com', 'Cloud Computing'),
('Sara Antunes', 'sara@flutter.dev', 'Mobile Dev'),
('Nelson Antunes', 'nantunes@di.uminho.pt', 'Distributed Databases');

-- 5. MAIS SESSÕES (Para testar sobreposição RC6 e filtros RM8)
INSERT INTO Sessao (tema, data, hora_inicio, hora_fim, sala, id_evento) VALUES
('Introdução ao Flutter', '2026-05-25', '09:00:00', '11:00:00', 'DI-A1', 4),
('Widgets Avançados', '2026-05-25', '11:30:00', '13:00:00', 'DI-A1', 4),
('Painel: IA e Cibersegurança', '2026-06-10', '14:30:00', '16:00:00', 'Auditório B1', 5),
('Criptografia Quântica', '2026-06-11', '10:00:00', '12:00:00', 'Auditório B1', 5),
('Final Pitch & Demo Day', '2026-09-03', '15:00:00', '18:00:00', 'CP1', 6);

-- 6. APRESENTADA (Oradores nas sessões)
INSERT INTO Apresentada (id_sessao, id_orador) VALUES
(4, 7), (5, 7), -- Sara nas sessões de Flutter
(6, 4), (6, 5), -- Alberto e Maria no painel de IA
(7, 5),        -- Maria na Criptografia
(8, 8);        -- Nelson no Hackathon

-- 7. PARTICIPANTES (Grande volume para testar RM6 - Taxa de ocupação)
INSERT INTO Participante (nome, email, telemovel, organizacao) VALUES
('Tiago Santos', 'tiago.a110313@alunos.uminho.pt', '910000001', 'UMinho'),
('Bruno Freitas', 'bruno.a110016@alunos.uminho.pt', '910000002', 'UMinho'),
('João Silva', 'jsilva@empresa.pt', '920000001', 'TechCorp'),
('Maria Oliveira', 'moliveira@gmail.com', '930000001', NULL),
('Ricardo Costa', 'rcosta@hotmail.com', '960000001', 'IT Solutions'),
('Sílvia Mendes', 'smendes@alunos.uminho.pt', '910000003', 'UMinho'),
('Nuno Rocha', 'nuno.rocha@ieee.org', '910000004', 'IEEE Student Branch'),
('Beatriz Dias', 'beatriz@gmail.com', '920000002', NULL),
('Fernando Pessoa', 'fpessoa@literatura.pt', '910000005', 'Casa Fernando Pessoa'),
('Marta Ferreira', 'marta.f@uminho.pt', '253000000', 'UMinho');

-- 8. INSCRIÇÕES (Diversidade de estados para RM3, RM4 e RM10)
INSERT INTO Inscricao (id_participante, id_evento, estado) VALUES
(5, 4, 'confirmada'), (6, 4, 'confirmada'), (7, 4, 'pendente'),    -- Workshop Flutter
(5, 5, 'confirmada'), (8, 5, 'confirmada'), (9, 5, 'cancelada'),   -- Congresso
(10, 5, 'confirmada'), (11, 5, 'confirmada'), (12, 5, 'confirmada'),
(5, 6, 'confirmada'), (13, 6, 'confirmada'), (14, 6, 'confirmada'), -- Hackathon
(5, 7, 'confirmada'), (14, 7, 'confirmada');                       -- Sessão Solene

-- 9. PAGAMENTOS (Testar RM5 e RM10 com diferentes estados)
INSERT INTO Pagamento (valor, metodo, estado, id_inscricao) VALUES
(10.00, 'MBWay', 'pago', 5),       -- Tiago pagou Workshop
(10.00, 'cartao', 'pago', 6),      -- Bruno pagou Workshop
(25.00, 'transferencia', 'pago', 8), -- Tiago pagou Congresso
(25.00, 'MBWay', 'pendente', 9),   -- Maria (Pagamento pendente)
(25.00, 'cartao', 'pago', 11),     -- Nuno pagou Congresso
(25.00, 'MBWay', 'rejeitado', 12), -- Beatriz (Pagamento falhou)
(0.00, 'numerario', 'pago', 17),   -- Carlos (Hackathon Grátis/Simulado)
(0.00, 'numerario', 'pago', 18);   -- Tiago (Sessão Solene Grátis)