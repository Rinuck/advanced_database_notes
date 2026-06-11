-- ============================================================
-- EJERCICIO: Sistema de Tickets de Soporte
-- ============================================================

-- Limpiar tablas anteriores
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ticket_assignments'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE tickets'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dim_agent'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE fact_ticket_daily'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ============================================================
-- TABLA TICKETS (fuente OLTP)
-- ============================================================
CREATE TABLE tickets (
    ticket_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       VARCHAR2(200) NOT NULL,
    status      VARCHAR2(20) DEFAULT 'open' NOT NULL,
    priority    VARCHAR2(10) DEFAULT 'medium' NOT NULL,
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    resolved_at TIMESTAMP,
    assigned_to NUMBER,  -- ID del agente
    CONSTRAINT chk_ticket_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed', 'cancelled')),
    CONSTRAINT chk_ticket_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'))
);

-- ============================================================
-- TABLA TICKET_ASSIGNMENTS (historial de asignaciones)
-- ============================================================
CREATE TABLE ticket_assignments (
    assignment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id     NUMBER NOT NULL REFERENCES tickets(ticket_id),
    assigned_to   NUMBER NOT NULL,
    assigned_by   NUMBER,
    valid_from    TIMESTAMP NOT NULL,
    valid_to      TIMESTAMP
);

-- Índice para búsquedas por fecha
CREATE INDEX idx_ticket_assignments_lookup 
ON ticket_assignments (ticket_id, valid_from, valid_to);

-- ============================================================
-- DATOS DE PRUEBA (5 tickets, uno con reasignación)
-- ============================================================

-- Ticket 1: Creado y resuelto por agente 1
INSERT INTO tickets (title, status, priority, created_at, resolved_at, assigned_to) 
VALUES ('Error de login', 'resolved', 'high', 
        TIMESTAMP '2026-05-01 09:00:00', 
        TIMESTAMP '2026-05-02 15:30:00', 1);

-- Ticket 2: Creado por agente 2, resuelto por agente 2
INSERT INTO tickets (title, status, priority, created_at, resolved_at, assigned_to) 
VALUES ('No carga la página principal', 'resolved', 'medium', 
        TIMESTAMP '2026-05-02 10:00:00', 
        TIMESTAMP '2026-05-03 11:00:00', 2);

-- Ticket 3: REASIGNADO - Creado por agente 1, luego reasignado a agente 3, resuelto por agente 3
INSERT INTO tickets (title, status, priority, created_at, assigned_to) 
VALUES ('Problema con reportes', 'resolved', 'critical', 
        TIMESTAMP '2026-05-03 14:00:00', 1);

-- Ticket 4: Abierto, asignado a agente 2
INSERT INTO tickets (title, status, priority, created_at, assigned_to) 
VALUES ('Solicitud de nueva función', 'open', 'low', 
        TIMESTAMP '2026-05-04 11:00:00', 2);

-- Ticket 5: En progreso, asignado a agente 3
INSERT INTO tickets (title, status, priority, created_at, assigned_to) 
VALUES ('Error en facturación', 'in_progress', 'high', 
        TIMESTAMP '2026-05-05 09:30:00', 3);

COMMIT;

-- ============================================================
-- REASIGNACIÓN: Ticket 3 se reasigna de agente 1 a agente 3
-- ============================================================
UPDATE tickets 
SET assigned_to = 3,
    updated_at = TIMESTAMP '2026-05-04 10:00:00'
WHERE ticket_id = 3;

-- Resolver ticket 3 (ahora con agente 3)
UPDATE tickets 
SET status = 'resolved',
    resolved_at = TIMESTAMP '2026-05-06 16:00:00'
WHERE ticket_id = 3;

COMMIT;

-- ============================================================
-- TRIGGER: Registra automáticamente cambios de asignación
-- ============================================================
CREATE OR REPLACE TRIGGER trg_ticket_assignment_log
    AFTER INSERT OR UPDATE OF assigned_to ON tickets
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- Asignación inicial: registrar cuando se crea el ticket
        INSERT INTO ticket_assignments (ticket_id, assigned_to, assigned_by, valid_from)
        VALUES (:NEW.ticket_id, :NEW.assigned_to, :NEW.assigned_by, :NEW.created_at);
    ELSIF UPDATING THEN
        -- Cerrar la asignación anterior
        UPDATE ticket_assignments
           SET valid_to = :NEW.updated_at
         WHERE ticket_id = :OLD.ticket_id
           AND valid_to IS NULL;
        
        -- Abrir nueva asignación
        INSERT INTO ticket_assignments (ticket_id, assigned_to, assigned_by, valid_from)
        VALUES (:NEW.ticket_id, :NEW.assigned_to, NULL, :NEW.updated_at);
    END IF;
END;
/

-- Verificar el historial de asignaciones
SELECT ta.ticket_id, ta.assigned_to, ta.valid_from, ta.valid_to
FROM ticket_assignments ta
ORDER BY ta.ticket_id, ta.valid_from;

-- ============================================================
-- ESQUEMA ESTRELLA
-- ============================================================

-- DIM_AGENT: información de los agentes
CREATE TABLE dim_agent (
    agent_key   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_id    NUMBER NOT NULL,  -- ID del sistema fuente
    agent_name  VARCHAR2(100) NOT NULL,
    team        VARCHAR2(50) NOT NULL,
    CONSTRAINT uq_dim_agent_source UNIQUE (agent_id)
);

-- FACT_TICKET_DAILY: métricas diarias
CREATE TABLE fact_ticket_daily (
    fact_key          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_key          NUMBER NOT NULL,  -- YYYYMMDD
    agent_key         NUMBER NOT NULL REFERENCES dim_agent(agent_key),
    status            VARCHAR2(20) NOT NULL,
    priority          VARCHAR2(10) NOT NULL,
    tickets_created   NUMBER DEFAULT 0,
    tickets_resolved  NUMBER DEFAULT 0,
    CONSTRAINT uq_fact_ticket UNIQUE (date_key, agent_key, status, priority)
);



-- ============================================================
-- AGENTES
-- ============================================================
INSERT INTO dim_agent (agent_id, agent_name, team) VALUES (1, 'Ana García', 'Soporte Técnico');
INSERT INTO dim_agent (agent_id, agent_name, team) VALUES (2, 'Carlos López', 'Soporte Técnico');
INSERT INTO dim_agent (agent_id, agent_name, team) VALUES (3, 'Laura Martínez', 'Soporte Especializado');
INSERT INTO dim_agent (agent_id, agent_name, team) VALUES (4, 'Pedro Sánchez', 'Supervisión');

COMMIT;

-- Verificar
SELECT * FROM dim_agent;