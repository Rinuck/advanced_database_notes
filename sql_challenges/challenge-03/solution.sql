### `sql_challenges/challenge-03/README.md`

```md
# SQL Challenge 03 

##Lesson 10
## Problem 1
Find the longest time that an employee has been at the studio 

## Schema
```sql
SELECT MAX(years_employed) 
FROM employees; 
```
## Problem 2
For each role, find the average number of years employed by employees in that role 

## Schema
```sql
SELECT role, AVG(years_employed) as Average_years_employed
FROM employees
GROUP BY role;
```

## Problem 3
Find the total number of employee years worked in each building
## Schema
```sql
select building, sum(years_employed) as years_employed
from employees
group by building
```
--Lesson 11
## Problem 1
Find the number of Artists in the studio (without a HAVING clause)

## Schema
```SELECT role, COUNT(*) as Number_of_artists
FROM employees
WHERE role = "Artist";
```

## Problem 2
Find the number of Employees of each role in the studio

## Schema
```SELECT role, COUNT(*)
FROM employees
GROUP BY role;
```


## Problem 3
Find the total number of years employed by all Engineers
## Schema
```SELECT role, SUM(years_employed)
FROM employees
GROUP BY role
HAVING role = "Engineer";
```

## freesql

##Problem 01
Complete the following query to return the:

Number of different shapes
The standard deviation (stddev) of the unique weights
## Schema
```select count ( distinct shape) number_of_shapes,
       stddev (distinct weight) distinct_weight_stddev
from  bricks;;
```


##Problem 02
Complete the following query to return the total weight for each shape stored in the bricks table:

## Schema
```select shape, sum (weight) shape_weight
from   bricks
group by shape;
```

##Problem 03
Complete the following query to find the shapes which have a total weight less than four:
## Schema
```select shape, sum ( weight )
from   bricks
group  by shape
having sum (weight) < 4;
```





── sql_challenges/
│   ├── challenge-01/
│   │   ├── README.md
│   │   ├── solution.sql
│   │   └── notes.md
│   ├── challenge-02/
│   │   └── README.md