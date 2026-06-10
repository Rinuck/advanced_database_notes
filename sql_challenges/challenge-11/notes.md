## Ejercicio 1: Preguntas

**Modelo Comment**
- Relaciones: Task y User (cada comentario pertenece a una tarea y a un usuario)
- Task debe tener relación `comments` (una tarea puede tener muchos comentarios)
- Al eliminar una tarea, los comentarios se eliminan automáticamente (`ondelete="CASCADE"`)

## Ejercicio 2: Preguntas

1. **¿Qué hace `upgrade()`?**  
   Aplica los cambios de la migración a la base de datos (crea tablas, columnas, restricciones)

2. **¿Qué hace `downgrade()`?**  
   Revierte la migración (elimina tablas, columnas, restricciones)

3. **¿Qué pasa al revertir esta migración?**  
   La tabla `comments` se elimina y todos sus datos se pierden

## Ejercicio 3: Preguntas

**Flujo del código:**
- Crea un equipo → Crea un usuario → Crea 3 tareas → Cuenta 3 tareas → Cierra tarea1 → Elimina tarea3

## Ejercicio 4: Preguntas

1. La columna se elimina del esquema
2. Los datos se pierden permanentemente

## Ejercicio 5: Preguntas

1. **¿Por qué ORM en lugar de SQL?**  
   Trabajar con objetos Python en lugar de SQL manual. Beneficios: código limpio, fácil mantenimiento, portabilidad, relaciones automáticas

2. **¿Por qué migraciones?**  
   Gestionan cambios del esquema de forma segura. Permiten: control de versiones, rollback, sincronización en equipo

3. **¿Cuándo hacer rollback?**  
   Cuando una migración tiene errores o el despliegue falla

4. **Diferencia entre `add()` y `commit()`**  
   `add()` prepara objetos en la sesión. `commit()` guarda permanentemente en la BD

5. **¿Por qué útiles las relaciones?**  
   Permiten navegar entre objetos relacionados sin escribir JOIN manualmente