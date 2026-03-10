# Session 2026-3-03

## Topics covereded
Window Functions (Analytic Functions): These allow you to perform complex calculations across a set of rows while keeping individual row details visible, unlike aggregate functions that collapse rows.

Window Definition with OVER(): This clause is the heart of the window function, defining exactly which "window" of data the function should analyze.

Data Partitioning: Using PARTITION BY to group data into logical chunks (like by Department) within the window without hiding rows.

Data Sorting: Implementing ORDER BY within the window to define the specific sequence for calculations or rankings.

Ranking and Numbering: Applying functions like ROW_NUMBER(), RANK(), and DENSE_RANK() to create ordered lists and handle ties.

Cumulative Calculations: Creating running totals by combining aggregate functions with the OVER(ORDER BY...) syntax.

Windowing Frames (ROWS/RANGE): Using the "Windowing Clause" (e.g., BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) to set precise boundaries for calculations as the window moves.



## Sql overview

Window Functions: These allow for complex calculations across a set of rows while keeping individual row details visible.

The OVER() Clause: The core requirement that defines the "window" of data; it can be empty or contain specific instructions.

Partitioning and Sorting: PARTITION BY groups data into chunks, and ORDER BY defines the sequence for calculations like rankings or totals.

Windowing Frames: Using ROWS BETWEEN to set precise boundaries for calculations, such as cumulative sums.


## what i understood
Function vs. Aggregate: Unlike aggregates, window functions return a value for every single row instead of collapsing them.

Ranking Logic: ROW_NUMBER() gives a unique ID, RANK() leaves gaps during ties, and DENSE_RANK() provides continuous numbering.

Running Totals: Combining SUM() with OVER(ORDER BY...) creates a cumulative total that grows as you move down the list.

Frame Control: UNBOUNDED PRECEDING AND CURRENT ROW is the standard way to define a sliding window for running totals.


## what is still confusing
Nothing especific


## Questions
No questions


## Related concepts



## Resources Used



