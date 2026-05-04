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