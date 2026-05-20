
### Exercise 1 — Find the slow query

**a) What scan type do you see? Why?**  
Full Table Scan. Because `site_id` has low cardinality (only values 1–5). Oracle decides it's faster to scan the whole table than to use an index.

**b) site_id has values 1–5. Is this high or low cardinality?**  
Low cardinality.

**c) Would adding an index on site_id help? Why or why not?**  
No, because each value returns about 20,000 rows (~20% of the table). Oracle would still choose a Full Table Scan.

---

### Exercise 2 — Create an index and see if it helps

**a) Does Oracle use the index for this range?**  
Yes, for a 30-day range because it returns a small percentage of rows.

**b) Change the range to the last 7 days. Does the plan change?**  
No, it still uses the index (even smaller range).

**c) Change to the last 700 days. What happens?**  
Oracle switches to Full Table Scan because it returns most of the rows (~95%).

**d) Why does the range size affect whether Oracle uses the index?**  
Oracle uses a cost-based optimizer. When an index would return more than ~15-20% of the rows, a Full Table Scan becomes cheaper.

---

### Exercise 3 — Composite index

**a) Does the plan use the composite index?**  
Yes, because the query filters by `patient_id` (the first column of the index).

**b) Now try querying ONLY on visit_date (no patient_id). Does the composite index get used? Why not?**  
No, because of the left-most prefix rule. The index is on `(patient_id, visit_date)`. Without filtering by `patient_id`, Oracle cannot use the index.

**c) What's the rule about column order in composite indexes?**  
The left-most prefix rule: the index can only be used when the query filters by the first column(s) in the index order.

---

### Exercise 4 — Function that breaks an index

**a) What scan type did the second query use?**  
Full Table Scan.

**b) Why does wrapping a column in a function break index use?**  
The index stores the original column values. When you apply a function like `TO_CHAR()`, Oracle cannot match the transformed value to the indexed values.

**c) How would you rewrite the second query to allow index use?**  
Remove the function and compare directly:
```sql
SELECT * FROM patient_visits WHERE patient_id = 5432;
```

---

### Exercise 5 — Discussion: real-world scenarios

**Scenario A (Reporting table, 50M rows, ETL nightly, analysts query by date):**

| Question | Answer |
|----------|--------|
| Index on date? | Yes |
| Why? | Analysts filter by date ranges. An index helps for small ranges. |
| Concerns? | Indexes slow down the nightly ETL load. Keep only necessary indexes. |

**Scenario B (OLTP orders table, 10,000 inserts/min, lookups by customer_id or order_status):**

| Question | Answer |
|----------|--------|
| What indexes? | Index on `customer_id` (high cardinality) + possibly on `order_status` |
| Why? | `customer_id` is very selective. `order_status` has low cardinality but is frequently used. |
| Concerns? | Each index slows down INSERT operations. Evaluate if the `order_status` index is truly needed. |

**Scenario C (Patient table, email column unique, 5M rows, frequent WHERE email = ...):**

| Question | Answer |
|----------|--------|
| What kind of index? | A UNIQUE index on `email` |
| Why? | Exact match search (`=`), high cardinality. A unique index also enforces data integrity. |

---

### Cleanup
```sql
DROP INDEX idx_pv_patient_date;
DROP INDEX idx_pv_visit_date;
```

---