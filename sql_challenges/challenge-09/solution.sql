```
## Lesson 04: Setup and Class Exercises

### Setup
```sql
DROP TABLE accounts PURGE;

CREATE TABLE accounts (
    account_id   NUMBER PRIMARY KEY,
    owner_name   VARCHAR2(50) NOT NULL,
    balance      NUMBER(10,2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO accounts VALUES (1, 'Alice',  1000.00);
INSERT INTO accounts VALUES (2, 'Bob',     500.00);
INSERT INTO accounts VALUES (3, 'Charlie', 250.00);
COMMIT;

SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
`



## Exercise 1: Manual transaction (warm-up)
Transfer $50 from Charlie (3) to Alice (1)

```sql
-- Verify starting balances
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- Start transaction
BEGIN;
UPDATE accounts SET balance = balance - 50 WHERE account_id = 3;
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;

-- Verify during transaction
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- Commit changes
COMMIT;

-- Final verification
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
-- Expected: Alice=1050, Bob=500, Charlie=200
```

---

## Exercise 2: Catch yourself with ROLLBACK
Attempt transfer of $10,000 from Bob (2) to Charlie (3)

```sql
-- Verify starting balances
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- Start transaction
BEGIN;
UPDATE accounts SET balance = balance - 10000 WHERE account_id = 2;
UPDATE accounts SET balance = balance + 10000 WHERE account_id = 3;

-- Check balances - Bob has insufficient funds (negative balance would occur)
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- Undo the incorrect transaction
ROLLBACK;

-- Verify balances restored to original
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
-- Expected: Alice=1050, Bob=500, Charlie=200
```

---

## Exercise 3: SAVEPOINT checkpoint
Add $25 to Alice, wrong deduction from Charlie, rollback, then deduct from Bob

```sql
-- Verify starting balances
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- Start transaction
BEGIN;

-- 1. Add $25 to Alice's balance
UPDATE accounts SET balance = balance + 25 WHERE account_id = 1;

-- 2. Set a savepoint
SAVEPOINT after_alice_credit;

-- 3. Deduct $25 from Charlie's balance (wrong account)
UPDATE accounts SET balance = balance - 25 WHERE account_id = 3;

-- Verify the mistake
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- 4. Rollback to savepoint
ROLLBACK TO after_alice_credit;

-- Verify Alice has the $25 but Charlie is restored
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- 5. Deduct $25 from Bob's balance instead
UPDATE accounts SET balance = balance - 25 WHERE account_id = 2;

-- 6. Commit
COMMIT;

-- Final verification
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
-- Expected: Alice=1075, Bob=475, Charlie=200
```

---

## Exercise 4: Write your own stored procedure

```sql
CREATE OR REPLACE PROCEDURE deposit_funds(
    p_account_id IN NUMBER,
    p_amount IN NUMBER
) AS
    v_old_balance NUMBER;
    v_new_balance NUMBER;
BEGIN
    -- Validate that p_amount > 0
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Deposit amount must be greater than 0. Received: ' || p_amount);
    END IF;
    
    -- Get current balance for verification
    SELECT balance INTO v_old_balance 
    FROM accounts 
    WHERE account_id = p_account_id;
    
    -- Add p_amount to the account balance
    UPDATE accounts 
    SET balance = balance + p_amount 
    WHERE account_id = p_account_id;
    
    -- Get new balance for output
    SELECT balance INTO v_new_balance 
    FROM accounts 
    WHERE account_id = p_account_id;
    
    -- Commit on success
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Deposit complete: $' || p_amount || 
                         ' added to account ' || p_account_id ||
                         '. Balance went from $' || v_old_balance || 
                         ' to $' || v_new_balance);
                         
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Deposit failed: Account ' || p_account_id || ' does not exist.');
        RAISE_APPLICATION_ERROR(-20003, 'Account not found: ' || p_account_id);
    WHEN OTHERS THEN
        -- Rollback and re-raise on any other error
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Deposit failed. All changes rolled back.');
        RAISE;
END;
/

-- Test the procedure
SET SERVEROUTPUT ON;
EXEC deposit_funds(3, 75);

-- Verify the deposit
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
-- Expected: Alice=1075, Bob=475, Charlie=275
```

---

## Exercise 5: Discussion

### Q1: Patient appointment booking system

**Inside the transaction:**
- **Reserve the time slot** - Must be atomic to prevent double-booking
- **Create the appointment record** - Core data that must be saved together with the time slot reservation

**Outside the transaction:**
- **Send confirmation notification** - This is a side effect that could fail independently without compromising data integrity. Email/SMS systems are external and can be retried asynchronously.

**Why:** The transaction ensures data consistency - either the time slot is reserved AND the appointment is created, or neither happens. The notification can be retried later without affecting the core booking data.

### Q2: Stored procedure calling COMMIT

The problem is **loss of transactional integrity**. When a developer calls a procedure that contains COMMIT inside their own larger transaction:

1. The parent transaction loses ability to roll back the procedure's changes
2. If the parent transaction fails later, the procedure's work remains committed
3. This breaks the atomicity of the parent operation
4. Creates partial updates and inconsistent data states

**Best practice:** Stored procedures called within larger transactions should NOT contain COMMIT/ROLLBACK. Let the caller control the transaction boundaries.

### Q3: calculate_copay() vs post_payment() in SELECT

**calculate_copay() - YES can be used in SELECT** because:
- It's a FUNCTION that returns a value
- It doesn't modify database state (no DML)
- It's deterministic/pure (same inputs = same output)

**post_payment() - NO cannot be used in SELECT** because:
- It's a PROCEDURE, not a function
- It modifies database state (updates tables)
- SELECT statements should be side-effect free
- Trying to use a procedure in SELECT would cause an error

**Rule:** Use FUNCTIONS for calculations/queries in SELECT. Use PROCEDURES for actions that modify data, called with EXEC or within PL/SQL blocks.

---

## Stored Procedure: transfer_funds

```sql
CREATE OR REPLACE PROCEDURE transfer_funds(
    p_from_account  IN  NUMBER,
    p_to_account    IN  NUMBER,
    p_amount        IN  NUMBER
) AS
    v_from_balance  NUMBER;
BEGIN
    -- Check sufficient funds before doing anything
    SELECT balance INTO v_from_balance
    FROM accounts
    WHERE account_id = p_from_account;

    IF v_from_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in account ' || p_from_account);
    END IF;

    -- Perform the transfer
    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from_account;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to_account;

    -- Commit only if both succeed
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Transfer complete: $' || p_amount ||
                         ' from account ' || p_from_account ||
                         ' to account ' || p_to_account);
EXCEPTION
    WHEN OTHERS THEN
        -- Something went wrong — undo everything
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed. All changes rolled back.');
        RAISE;
END;
/

-- Test transfers
SET SERVEROUTPUT ON;

-- Check starting state
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- Transfer $100 from Alice (1) to Bob (2)
EXEC transfer_funds(1, 2, 100);

-- Verify
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- Try insufficient funds
EXEC transfer_funds(1, 2, 99999);

-- Verify unchanged
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
```

---

## Function Example (contrast with procedure)

```sql
CREATE OR REPLACE FUNCTION get_balance(p_account_id IN NUMBER) RETURN NUMBER AS
    v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;
    RETURN v_balance;
END;
/

-- Function used directly in SELECT (allowed)
SELECT account_id, owner_name, get_balance(account_id) AS current_balance
FROM accounts;

-- This would ERROR - cannot use procedure in SELECT
-- SELECT transfer_funds(1, 2, 100) FROM dual;
```