```
## SQL Challenge: Triggers on PET_CARE_LOG

### Trigger 1: BEFORE INSERT - Auto-fill user and date/time
```sql
CREATE OR REPLACE TRIGGER trg_pet_care_log_insert
BEFORE INSERT ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    :NEW.LAST_UPDATE_DATETIME := SYSDATE;
    :NEW.CREATED_BY_USER := USER;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error en trigger INSERT: ' || SQLERRM);
END;
/
```

### Trigger 2: BEFORE UPDATE - Only allow creator to update
```sql
CREATE OR REPLACE TRIGGER trg_pet_care_log_update
BEFORE UPDATE ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    
    IF USER != :OLD.CREATED_BY_USER THEN
        RAISE_APPLICATION_ERROR(-20002, 'Solo el usuario que creó el registro puede actualizarlo.');
    END IF;
    :NEW.LAST_UPDATE_DATETIME := SYSDATE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error en trigger UPDATE: ' || SQLERRM);
END;
/
```

### Trigger 3: BEFORE DELETE - Only manager can delete
```sql
CREATE OR REPLACE TRIGGER trg_pet_care_log_delete
BEFORE DELETE ON PET_CARE_LOG
FOR EACH ROW
BEGIN
   
    IF USER != 'JOEMANAGER' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Solo JOEMANAGER puede eliminar registros del log.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error en trigger DELETE: ' || SQLERRM);
END;
/
```
```

