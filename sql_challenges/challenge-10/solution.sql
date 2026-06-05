## Oracle Schema Backup & Restore - Exercise Solutions

### EXERCISE 1: Explore your schema

**Problem: List all objects in your schema grouped by type**
```
```sql
SELECT object_type, COUNT(*) AS cnt
FROM user_objects
GROUP BY object_type
ORDER BY object_type;
```

**Problem: Get detailed object information**

```sql
SELECT object_name, object_type, created, last_ddl_time
FROM user_objects
ORDER BY object_type, object_name;
```

---

### EXERCISE 2: Basic GET_DDL

**Problem: Set transform parameters for clean output**

```sql
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

SET LONG 100000
SET PAGESIZE 0
```

**Problem: Get DDL for one table (replace EMPLOYEES with actual table name)**

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE', 'EMPLOYEES') FROM DUAL;
```

**Problem: Get DDL for all tables at once**

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
ORDER BY table_name;
```

---

### EXERCISE 3: Clean DDL for portability

**Problem: Remove schema names from DDL**

```sql
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/
```

**Problem: Compare output with and without EMIT_SCHEMA**

```sql
-- Without EMIT_SCHEMA false (default includes schema name)
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
WHERE ROWNUM = 1;
```

---

### EXERCISE 4: Plan a migration

**Problem: Identify schema names embedded in DDL**

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
WHERE table_name = 'EMPLOYEES';
```

**Problem: Check for schema-qualified references in foreign keys**

```sql
SELECT constraint_name, table_name, r_constraint_name
FROM user_constraints
WHERE constraint_type = 'R';
```

**Problem: Write a migration checklist**

```sql
-- Migration Checklist Query - Verify all objects exist
SELECT object_type, COUNT(*) as count
FROM user_objects
GROUP BY object_type
ORDER BY object_type;
```

---

### EXERCISE 5: Dependency order

**Problem: See all dependencies in your schema**

```sql
SELECT referenced_name, referencing_name, referencing_type
FROM user_dependencies
ORDER BY referenced_name;
```

**Problem: Find objects that depend on tables**

```sql
SELECT referencing_name, referencing_type
FROM user_dependencies
WHERE referenced_name IN (
  SELECT table_name FROM user_tables
)
ORDER BY referencing_type, referencing_name;
```

**Problem: Find direct dependencies for a specific object**

```sql
SELECT referenced_name, referenced_type
FROM user_dependencies
WHERE referencing_name = 'GET_SALARY';  -- Replace with your procedure name
```

**Problem: Build a dependency tree for PL/SQL objects**

```sql
SELECT referencing_name, referencing_type,
       LISTAGG(referenced_name, ', ') WITHIN GROUP (ORDER BY referenced_name) AS dependencies
FROM user_dependencies
WHERE referencing_type IN ('PACKAGE', 'PROCEDURE', 'FUNCTION')
GROUP BY referencing_name, referencing_type
ORDER BY referencing_type, referencing_name;
```

---

### EXERCISE 6: Design your own backup strategy

**STEP 1: Document your current schema structure**

```sql
SELECT object_type, COUNT(*) FROM user_objects GROUP BY object_type;

SELECT table_name, num_rows FROM user_tables ORDER BY num_rows DESC;
```

**STEP 2: Extract all DDL**

```sql
-- Set transform parameters (clean, portable DDL)
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

-- Extract tables
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name) FROM user_tables;

-- Extract indexes
SELECT DBMS_METADATA.GET_DDL('INDEX', index_name) FROM user_indexes;

-- Extract views
SELECT DBMS_METADATA.GET_DDL('VIEW', view_name) FROM user_views;

-- Extract sequences
SELECT DBMS_METADATA.GET_DDL('SEQUENCE', sequence_name) FROM user_sequences;

-- Extract constraints
SELECT DBMS_METADATA.GET_DDL('CONSTRAINT', constraint_name) FROM user_constraints;

-- Extract procedures
SELECT DBMS_METADATA.GET_DDL('PROCEDURE', object_name) 
FROM user_objects WHERE object_type = 'PROCEDURE';

-- Extract functions
SELECT DBMS_METADATA.GET_DDL('FUNCTION', object_name) 
FROM user_objects WHERE object_type = 'FUNCTION';

-- Extract packages
SELECT DBMS_METADATA.GET_DDL('PACKAGE', object_name) 
FROM user_objects WHERE object_type = 'PACKAGE';
```

**STEP 3: Verify everything transferred**

```sql
SELECT object_type, COUNT(*) FROM user_objects GROUP BY object_type;

SELECT table_name, num_rows FROM user_tables ORDER BY table_name;

SELECT index_name, table_name FROM user_indexes ORDER BY index_name;
```

---

### DISCUSSION QUESTIONS ANSWERS

**Q1: What are the limitations of DBMS_METADATA vs expdp?**

```sql
-- DBMS_METADATA: DDL only, no data export, requires manual spooling
-- expdp: Exports data + DDL, faster, handles large schemas, needs directory privileges

-- Example of what DBMS_METADATA cannot do (data export):
-- SELECT * FROM my_table;  -- Would need separate INSERT statements for data

-- expdp equivalent (requires DBA access):
-- expdp username/password SCHEMAS=my_schema DIRECTORY=data_pump_dir DUMPFILE=backup.dmp
```

**Q2: Handling circular dependencies**

```sql
-- Strategy for circular dependencies:
-- 1. Create all tables first (without foreign key constraints)
-- 2. Create all sequences
-- 3. Create all indexes
-- 4. Add all constraints (including foreign keys) using ALTER TABLE

-- Example of creating table without FK:
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    manager_id NUMBER
);  -- FK added later

-- Then add FK after both tables exist:
ALTER TABLE employees ADD CONSTRAINT fk_manager 
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id);
```

**Q3: Migration plan from read-only source to new database**

```sql
-- Step 1: Document source schema
SELECT object_type, COUNT(*) FROM user_objects GROUP BY object_type;

-- Step 2: Extract clean DDL (no schema names, no storage)
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  -- ... other transform parameters
END;
/

-- Step 3: Check for cross-schema dependencies
SELECT * FROM user_dependencies 
WHERE referenced_owner != USER AND referenced_type = 'TABLE';

-- Step 4: Create objects in correct order on target
-- (Run scripts in sequence: tables → sequences → indexes → constraints → views → code)

-- Step 5: Verify migration
SELECT 'Source: ' || (SELECT COUNT(*) FROM user_tables@source_link) AS source_count,
       'Target: ' || (SELECT COUNT(*) FROM user_tables) AS target_count
FROM DUAL;
```