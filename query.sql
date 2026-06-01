USE eventsync;

CREATE OR REPLACE VIEW v_ProgramaDetalhado AS
SELECT 
    e.nome AS Evento,
    s.tema AS Sessao,
    s.data AS Dia,
    s.hora_inicio AS Inicio,
    s.sala AS Sala,
    GROUP_CONCAT(o.nome SEPARATOR ' | ') AS Oradores
FROM Evento e
JOIN Sessao s ON e.id_evento = s.id_evento
LEFT JOIN Apresentada apr ON s.id_sessao = apr.id_sessao
LEFT JOIN Orador o ON apr.id_orador = o.id_orador
GROUP BY s.id_sessao;

CREATE OR REPLACE VIEW v_DashboardFinanceiro AS
SELECT 
    p.nome AS Participante,
    e.nome AS Evento,
    pag.valor AS Montante,
    pag.estado AS Estado_Pagamento,
    pag.metodo AS Metodo
FROM Participante p
JOIN Inscricao i ON p.id_participante = i.id_participante
JOIN Evento e ON i.id_evento = e.id_evento
JOIN Pagamento pag ON i.id_inscricao = pag.id_inscricao;

CREATE OR REPLACE VIEW v_OcupacaoEventos AS
SELECT 
    e.nome AS Evento,
    e.capacidade AS Lotação_Máxima,
    COUNT(i.id_inscricao) AS Inscritos_Confirmados,
    ROUND((COUNT(i.id_inscricao) / e.capacidade) * 100, 2) AS Percentagem_Ocupacao
FROM Evento e
LEFT JOIN Inscricao i ON e.id_evento = i.id_evento AND i.estado = 'confirmada'
GROUP BY e.id_evento;

DELIMITER $$

CREATE TRIGGER trg_verificar_sala_disponivel
BEFORE INSERT ON Sessao
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Sessao
        WHERE sala = NEW.sala 
            AND data = NEW.data
            AND (
            (NEW.hora_inicio < hora_fim AND NEW.hora_fim > hora_inicio)
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A sala já está ocupada neste horário!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_confirmar_pagamento(IN p_id_pagamento INT)
BEGIN
    -- 1. Atualiza o pagamento
    UPDATE Pagamento SET estado = 'pago', data_pagamento = NOW() 
    WHERE id_pagamento = p_id_pagamento;
    
    -- 2. Atualiza a inscrição associada
    UPDATE Inscricao i
    JOIN Pagamento p ON i.id_inscricao = p.id_inscricao
    SET i.estado = 'confirmada'
    WHERE p.id_pagamento = p_id_pagamento;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION fn_total_gasto_participante(p_id_participante INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT SUM(p.valor) INTO v_total
    FROM Pagamento p
    JOIN Inscricao i ON p.id_inscricao = i.id_inscricao
    WHERE i.id_participante = p_id_participante AND p.estado = 'pago';
    RETURN IFNULL(v_total, 0);
END$$

DELIMITER ;

-- ============================================================
-- TRADUÇÃO DAS INTERROGAÇÕES DO UTILIZADOR PARA SQL (RM1-RM10)
-- ============================================================

-- RM1: Listar todos os eventos, com filtro por tipo, data ou localização
SELECT id_evento, nome, tipo, numero_edicao,
       data_inicio, data_fim, localizacao, capacidade
FROM Evento
WHERE tipo = 'Workshop'             -- filtro opcional por tipo
  AND data_inicio >= '2026-01-01'   -- filtro opcional por data
ORDER BY data_inicio;

-- RM2: Programa completo de um evento (recorre à vista)
SELECT * FROM v_ProgramaDetalhado
WHERE Evento = 'Workshop Flutter & Dart';

-- RM3: Inscritos num determinado evento com estado da inscrição
SELECT p.nome, p.email, i.estado, i.data_inscricao
FROM Participante p
JOIN Inscricao i ON p.id_participante = i.id_participante
JOIN Evento e    ON i.id_evento = e.id_evento
WHERE e.nome = 'Congresso Nacional de Cibersegurança'
ORDER BY i.estado, p.nome;

-- RM4: Histórico de inscrições de um participante
SELECT e.nome AS Evento, e.data_inicio, i.estado,
       i.data_inscricao
FROM Inscricao i
JOIN Evento e ON i.id_evento = e.id_evento
WHERE i.id_participante = 5
ORDER BY i.data_inscricao DESC;

-- RM5: Total de receitas de um evento (pagamentos com estado 'pago')
SELECT e.nome AS Evento,
       SUM(pag.valor) AS Total_Receitas
FROM Evento e
JOIN Inscricao i   ON e.id_evento = i.id_evento
JOIN Pagamento pag ON i.id_inscricao = pag.id_inscricao
WHERE pag.estado = 'pago'
  AND e.nome = 'Workshop Flutter & Dart'
GROUP BY e.id_evento;

-- RM6: Eventos com maior taxa de ocupação (recorre à vista)
SELECT * FROM v_OcupacaoEventos
ORDER BY Percentagem_Ocupacao DESC;

-- RM7: Oradores de um determinado evento
SELECT DISTINCT o.nome, o.especialidade
FROM Orador o
JOIN Apresentada apr ON o.id_orador = apr.id_orador
JOIN Sessao s ON apr.id_sessao = s.id_sessao
JOIN Evento e ON s.id_evento = e.id_evento
WHERE e.nome = 'Congresso Nacional de Cibersegurança';

-- RM8: Sessões agendadas numa sala ou intervalo de datas
SELECT s.tema, s.data, s.hora_inicio, s.hora_fim,
       e.nome AS Evento
FROM Sessao s
JOIN Evento e ON s.id_evento = e.id_evento
WHERE s.sala = 'Auditório B1'
   OR (s.data BETWEEN '2026-06-01' AND '2026-06-30')
ORDER BY s.data, s.hora_inicio;

-- RM9: Oradores de uma determinada sessão
SELECT o.nome, o.email, o.especialidade
FROM Orador o
JOIN Apresentada apr ON o.id_orador = apr.id_orador
WHERE apr.id_sessao = 6;

-- RM10: Pagamentos pendentes ou rejeitados, com participante e evento
SELECT pag_v.Participante, pag_v.Evento,
       pag_v.Montante, pag_v.Estado_Pagamento, pag_v.Metodo
FROM v_DashboardFinanceiro pag_v
WHERE pag_v.Estado_Pagamento IN ('pendente', 'rejeitado');
