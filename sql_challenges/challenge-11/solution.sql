-- ============================================================
-- EJERCICIO: SQLAlchemy ORM + Alembic Migrations
-- ============================================================

-- ============================================================
-- EJERCICIO 1 — Model Design: Tabla COMMENTS
-- ============================================================

-- Limpiar tablas anteriores
BEGIN EXECUTE IMMEDIATE 'DROP TABLE comments'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE tasks'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE users'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE teams'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ============================================================
-- TABLA TEAMS (V1)
-- ============================================================
CREATE TABLE teams (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR2(50) NOT NULL UNIQUE,
    description VARCHAR2(200),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLA USERS (V1)
-- ============================================================
CREATE TABLE users (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username    VARCHAR2(50) NOT NULL UNIQUE,
    email       VARCHAR2(100) NOT NULL,
    full_name   VARCHAR2(100),
    team_id     NUMBER,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_team FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE SET NULL
);

-- ============================================================
-- TABLA TASKS (V1)
-- ============================================================
CREATE TABLE tasks (
    id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title        VARCHAR2(200) NOT NULL,
    description  VARCHAR2(1000),
    status       VARCHAR2(20) DEFAULT 'open',
    assigned_to  NUMBER,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP,
    CONSTRAINT fk_tasks_user FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_task_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed'))
);

-- ============================================================
-- TABLA COMMENTS (NUEVA — Ejercicio 1)
-- ============================================================
CREATE TABLE comments (
    id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id      NUMBER NOT NULL,
    user_id      NUMBER NOT NULL,
    content      VARCHAR2(4000) NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_comment_content CHECK (TRIM(content) IS NOT NULL AND LENGTH(content) > 0)
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_comments_task_id ON comments(task_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);

-- ============================================================
-- DATOS DE PRUEBA (seed data)
-- ============================================================

-- Teams
INSERT INTO teams (name, description) VALUES ('Engineering', 'Software development team');
INSERT INTO teams (name, description) VALUES ('Product', 'Product management team');
INSERT INTO teams (name, description) VALUES ('DevOps', 'Infrastructure and operations team');

-- Users
INSERT INTO users (username, email, full_name, team_id) VALUES ('alice_dev', 'alice@example.com', 'Alice Smith', 1);
INSERT INTO users (username, email, full_name, team_id) VALUES ('bob_dev', 'bob@example.com', 'Bob Jones', 1);
INSERT INTO users (username, email, full_name, team_id) VALUES ('carol_pm', 'carol@example.com', 'Carol White', 2);
INSERT INTO users (username, email, full_name, team_id) VALUES ('diana_ops', 'diana@example.com', 'Diana Ross', 3);

-- Tasks
INSERT INTO tasks (title, description, status, assigned_to) VALUES ('Fix login bug', 'Users cannot log in with SSO', 'open', 1);
INSERT INTO tasks (title, description, status, assigned_to) VALUES ('Design new dashboard', 'Create mockups for analytics page', 'in_progress', 3);
INSERT INTO tasks (title, description, status, assigned_to) VALUES ('Update dependencies', 'Upgrade numpy and pandas', 'open', 2);

-- Comments (Ejercicio 1 - demostración)
INSERT INTO comments (task_id, user_id, content) VALUES (1, 1, 'I am working on this bug. Found the issue in auth module.');
INSERT INTO comments (task_id, user_id, content) VALUES (1, 2, 'Let me know if you need help with the tests.');
INSERT INTO comments (task_id, user_id, content) VALUES (2, 3, 'Created initial wireframes. Ready for review.');

COMMIT;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT 'Teams:' AS section, name FROM teams
UNION ALL
SELECT 'Users:' AS section, username FROM users
UNION ALL
SELECT 'Tasks:' AS section, title FROM tasks
UNION ALL
SELECT 'Comments:' AS section, SUBSTR(content, 1, 50) || '...' FROM comments;

-- ============================================================
-- EJERCICIO 3 — CRUD Challenge (versión SQL)
-- ============================================================

-- 1. Crear team "DevOps" (ya creado arriba)
-- 2. Crear user "diana_ops" (ya creado arriba)

-- 3. Crear 3 tareas con diferentes prioridades
-- Nota: Se necesita añadir columna priority a tasks
ALTER TABLE tasks ADD priority VARCHAR2(10) DEFAULT 'medium';
ALTER TABLE tasks ADD CONSTRAINT chk_task_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'));

-- Insertar 3 tareas
INSERT INTO tasks (title, description, status, assigned_to, priority) 
VALUES ('Configure CI/CD pipeline', 'Set up GitHub Actions', 'open', 4, 'high');

INSERT INTO tasks (title, description, status, assigned_to, priority) 
VALUES ('Update Kubernetes config', 'Upgrade k8s to v1.28', 'open', 4, 'critical');

INSERT INTO tasks (title, description, status, assigned_to, priority) 
VALUES ('Write deployment docs', 'Document deployment process', 'open', 4, 'low');

COMMIT;

-- 4. Mostrar conteo de tareas
SELECT 'Total tasks:' AS metric, COUNT(*) AS value FROM tasks
UNION ALL
SELECT 'Tasks assigned to Diana:' AS metric, COUNT(*) FROM tasks WHERE assigned_to = 4;

-- 5. Cerrar una tarea (cambiar status a 'resolved')
UPDATE tasks SET status = 'resolved', updated_at = CURRENT_TIMESTAMP 
WHERE title = 'Configure CI/CD pipeline';

-- 6. Eliminar la tarea de menor prioridad (priority = 'low')
DELETE FROM tasks WHERE priority = 'low' AND ROWNUM = 1;

COMMIT;

-- Verificar resultados después de CRUD
SELECT title, status, priority FROM tasks ORDER BY priority;

-- ============================================================
-- EJERCICIO 4 — Migration Rollback (simulado)
-- ============================================================
-- Para simular una migración con columna bad 'estimated_hours':

ALTER TABLE tasks ADD estimated_hours NUMBER;
COMMENT ON COLUMN tasks.estimated_hours IS 'BAD COLUMN - to be removed';

-- Verificar que existe
SELECT column_name FROM user_tab_columns WHERE table_name = 'TASKS' AND column_name = 'ESTIMATED_HOURS';

-- Rollback (eliminar la columna)
ALTER TABLE tasks DROP COLUMN estimated_hours;

-- Verificar que ya no existe
SELECT column_name FROM user_tab_columns WHERE table_name = 'TASKS' AND column_name = 'ESTIMATED_HOURS';

-- ============================================================
-- EJERCICIO 5 — Concept Check (respuestas)
-- ============================================================

-- Pregunta 1: ¿Por qué usar ORM en lugar de SQL crudo?
-- Respuesta: ORM abstrae la base de datos, permite usar objetos Python,
-- evita SQL injection, facilita cambios entre DB, y maneja relaciones.

-- Pregunta 2: ¿Por qué usar migraciones?
-- Respuesta: Versionan cambios de esquema, permiten rollback,
-- mantienen consistencia entre entornos, automatizan despliegues.

-- Pregunta 3: ¿Cuándo harías rollback?
-- Respuesta: Cuando una migración falla, contiene errores,
-- o se necesita revertir cambios por bugs o problemas de rendimiento.

-- Pregunta 4: Diferencia entre add() y commit()
-- Respuesta: add() prepara un objeto para ser guardado (pendiente),
-- commit() persiste permanentemente todos los cambios pendientes.

-- Pregunta 5: ¿Por qué son útiles las relaciones?
-- Respuesta: Permiten navegar entre objetos fácilmente (task.assignee.full_name),
-- evitan JOINs manuales, mantienen integridad referencial automática.

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT '=========================================' AS status FROM DUAL;
SELECT '✅ Todos los ejercicios completados' AS status FROM DUAL;
SELECT '=========================================' AS status FROM DUAL;

SELECT table_name AS "Tablas creadas" FROM user_tables 
WHERE table_name IN ('TEAMS', 'USERS', 'TASKS', 'COMMENTS')
ORDER BY table_name;