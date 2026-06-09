
 Ejercicio 1 – Team Velocity
``sql
-- CONTRATO: Velocidad = tareas completadas / tareas totales por equipo
-- Edge cases: Equipos sin tareas = 0 velocidad

SELECT t.name AS team_name,
       COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) AS completed_tasks,
       COUNT(ts.id) AS total_tasks,
       ROUND(COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100.0 / NULLIF(COUNT(ts.id), 0), 1) AS velocity_pct,
       CASE WHEN ROUND(COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100.0 / NULLIF(COUNT(ts.id), 0), 1) < 
                 (SELECT AVG(vel) FROM (SELECT ROUND(COUNT(CASE WHEN ts2.status = 'completed' THEN 1 END) * 100.0 / NULLIF(COUNT(ts2.id), 0), 1) AS vel
                                        FROM teams t2 LEFT JOIN users u2 ON u2.team_id = t2.id LEFT JOIN tasks ts2 ON ts2.assigned_to = u2.id
                                        GROUP BY t2.id)) THEN 'Below Average'
            ELSE 'At or Above Average'
       END AS velocity_vs_avg
FROM teams t
LEFT JOIN users u ON u.team_id = t.id
LEFT JOIN tasks ts ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY velocity_pct DESC;
```

```python
# Gráfico para Ejercicio 1
df_vel = pd.read_sql(query, engine)
fig = px.bar(df_vel, x='team_name', y='velocity_pct', 
             title='Team Velocity (Completion %)', 
             color='velocity_vs_avg', text='velocity_pct')
fig.show()
```

### Ejercicio 2 – On-Time Delivery Rate
```sql
-- CONTRATO: On-time = completed_at <= due_date (antes de fin del día de la fecha de vencimiento)
-- Tareas sin due_date se excluyen del cálculo

SELECT priority,
       COUNT(*) AS total_completed,
       COUNT(CASE WHEN completed_at <= due_date + INTERVAL '1' DAY THEN 1 END) AS on_time_count,
       ROUND(COUNT(CASE WHEN completed_at <= due_date + INTERVAL '1' DAY THEN 1 END) * 100.0 / COUNT(*), 1) AS on_time_rate,
       ROUND(AVG(EXTRACT(DAY FROM (completed_at - due_date)) * 24 + 
                 EXTRACT(HOUR FROM (completed_at - due_date))), 1) AS avg_lateness_hours
FROM tasks
WHERE status = 'completed'
  AND due_date IS NOT NULL
  AND completed_at IS NOT NULL
GROUP BY priority
ORDER BY CASE priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 WHEN 'low' THEN 4 END;
```

### Ejercicio 3 – Tasks per Team (Mejorado)
```sql
SELECT t.name AS team_name,
       COUNT(ts.id) AS total_tasks,
       COUNT(CASE WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN 1 END) AS active_tasks,
       ROUND(COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100.0 / NULLIF(COUNT(CASE WHEN ts.status != 'cancelled' THEN 1 END), 0), 1) AS completion_rate,
       CASE WHEN COUNT(CASE WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN 1 END) > 10 THEN 'Overloaded'
            WHEN COUNT(CASE WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN 1 END) >= 5 THEN 'Healthy'
            ELSE 'Underutilized'
       END AS health_score
FROM teams t
LEFT JOIN users u ON u.team_id = t.id
LEFT JOIN tasks ts ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY active_tasks DESC;
```

### Ejercicio 4 – Avg Resolution Time (Mejorado)
```sql
WITH resolution_stats AS (
    SELECT priority,
           ROUND(EXTRACT(DAY FROM (completed_at - created_at)) * 24 +
                 EXTRACT(HOUR FROM (completed_at - created_at)) +
                 EXTRACT(MINUTE FROM (completed_at - created_at)) / 60, 1) AS resolution_hours
    FROM tasks
    WHERE status = 'completed' AND completed_at IS NOT NULL
)
SELECT priority,
       COUNT(*) AS completed_count,
       ROUND(AVG(resolution_hours), 1) AS avg_hours,
       ROUND(MEDIAN(resolution_hours), 1) AS median_hours,
       MIN(resolution_hours) AS fastest_hours,
       MAX(resolution_hours) AS slowest_hours,
       CASE priority 
           WHEN 'critical' THEN 24
           WHEN 'high' THEN 72
           WHEN 'medium' THEN 168
           WHEN 'low' THEN 336
       END AS sla_hours,
       CASE WHEN AVG(resolution_hours) <= 
                 CASE priority WHEN 'critical' THEN 24 WHEN 'high' THEN 72 WHEN 'medium' THEN 168 WHEN 'low' THEN 336 END
            THEN 'Met SLA' ELSE 'Breached SLA'
       END AS sla_status
FROM resolution_stats
GROUP BY priority
ORDER BY CASE priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 WHEN 'low' THEN 4 END;
```

### Ejercicio 5 – Overdue Tasks (Mejorado)
```sql
SELECT ts.title,
       u.full_name AS assignee,
       t.name AS team,
       ts.priority,
       ts.due_date,
       TRUNC(SYSDATE) - ts.due_date AS days_overdue,
       CASE WHEN ts.priority = 'critical' AND TRUNC(SYSDATE) - ts.due_date > 0 THEN 'CRITICAL'
            WHEN ts.priority = 'high' AND TRUNC(SYSDATE) - ts.due_date > 2 THEN 'HIGH'
            WHEN ts.priority = 'medium' AND TRUNC(SYSDATE) - ts.due_date > 5 THEN 'MEDIUM'
            ELSE 'LOW'
       END AS severity
FROM tasks ts
LEFT JOIN users u ON u.id = ts.assigned_to
LEFT JOIN teams t ON t.id = u.team_id
WHERE ts.due_date < TRUNC(SYSDATE)
  AND ts.status NOT IN ('completed', 'cancelled')
  AND ts.due_date IS NOT NULL
ORDER BY CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 WHEN 'LOW' THEN 4 END,
         days_overdue DESC;
```

### Ejercicio 6 – Productivity Score (Corregido)
```sql
-- PROBLEMA: COUNT(ts.id) cuenta tareas asignadas sin importar si están completadas
-- Ni pondera por prioridad ni por tiempo. Un task creado hace 1 año cuenta igual.

SELECT u.full_name,
       COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) AS completed_tasks,
       ROUND(COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 1.0 / 
             NULLIF(EXTRACT(DAY FROM (SYSDATE - MIN(ts.created_at))), 0), 2) AS tasks_per_day,
       SUM(CASE WHEN ts.priority = 'critical' AND ts.status = 'completed' THEN 4
                WHEN ts.priority = 'high' AND ts.status = 'completed' THEN 3
                WHEN ts.priority = 'medium' AND ts.status = 'completed' THEN 2
                WHEN ts.priority = 'low' AND ts.status = 'completed' THEN 1
                ELSE 0 END) AS weighted_productivity_score
FROM users u
LEFT JOIN tasks ts ON ts.assigned_to = u.id
GROUP BY u.id, u.full_name
ORDER BY weighted_productivity_score DESC;
```

### Ejercicio 7 – Team Efficiency (Corregido)
```sql
-- PROBLEMA: AVG(ts.id) no tiene significado matemático
-- El ID es un identificador arbitrario, no una medida de eficiencia

SELECT t.name AS team_name,
       COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) AS completed_tasks,
       COUNT(ts.id) AS total_tasks,
       ROUND(COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100.0 / NULLIF(COUNT(ts.id), 0), 1) AS completion_rate,
       ROUND(COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 1.0 / 
             NULLIF(COUNT(DISTINCT u.id), 0), 1) AS completed_per_member
FROM teams t
LEFT JOIN users u ON u.team_id = t.id
LEFT JOIN tasks ts ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY completion_rate DESC;
```

### Ejercicio 8 – Urgency Index (Corregido)
```sql
-- PROBLEMA: priority es VARCHAR, no se puede multiplicar por 10
-- DUE_DATE tampoco se puede sumar directamente a un número

SELECT title,
       priority,
       due_date,
       TRUNC(SYSDATE) - due_date AS days_relative,
       CASE priority WHEN 'critical' THEN 4 WHEN 'high' THEN 3 WHEN 'medium' THEN 2 WHEN 'low' THEN 1 END AS priority_weight,
       (CASE priority WHEN 'critical' THEN 4 WHEN 'high' THEN 3 WHEN 'medium' THEN 2 WHEN 'low' THEN 1 END) + 
       (TRUNC(SYSDATE) - due_date) * 2 AS urgency_score
FROM tasks
WHERE due_date IS NOT NULL
ORDER BY urgency_score DESC;
