# SQL Challenge 05 – Union, Minus, and Intersect: Databases for Developers

## Tabla de datos inicial

### my_brick_collection
| colour | shape  |
|--------|--------|
| red    | square |
| blue   | circle |
| green  | square |

### your_brick_collection
| colour | shape  |
|--------|--------|
| red    | circle |
| yellow | square |
| green  | circle |

---

## Problem 01 – UNION

**Objetivo:** Colores únicos de ambas tablas

### Query SQL
```sql
SELECT colour FROM my_brick_collection
UNION
SELECT colour FROM your_brick_collection
ORDER BY colour;
```

### Resultado
| colour |
|--------|
| blue   |
| green  |
| red    |
| yellow |


---

## Problem 02 – UNION ALL

**Objetivo:** Shapes de ambas tablas (con duplicados)

### Query SQL
```sql
SELECT shape FROM my_brick_collection
UNION ALL
SELECT shape FROM your_brick_collection
ORDER BY shape;
```

### Resultado
| shape  |
|--------|
| circle |
| circle |
| circle |
| square |
| square |
| square |


---

## Problem 03 – MINUS

**Objetivo:** Shapes que están en my collection pero NO en your collection

### Query SQL
```sql
SELECT shape FROM my_brick_collection
MINUS
SELECT shape FROM your_brick_collection
ORDER BY shape;
```

### Resultado
| shape  |
|--------|
| square |


## Problem 04 – INTERSECT

**Objetivo:** Colores que están en AMBAS tablas

### Query SQL
```sql
SELECT colour FROM my_brick_collection
INTERSECT
SELECT colour FROM your_brick_collection
ORDER BY colour;
```

### Resultado
| colour |
|--------|
| green  |
| red    |
