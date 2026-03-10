```md
# SQL Challenge 05 – Union, Minus, and Intersect: Databases for Developers

## Problem 01
Complete this query to return a list of all the colours in the two tables. Each colour must only appear once:

## Schema
```select colour from my_brick_collection
union
select colour from your_brick_collection
order by colour;
);




```
## Problem 02
Complete the following query to return a list of all the shapes in both tables. There must show one row for each row in the source tables:```
```
## Schema
```select shape from my_brick_collection
union all
select shape from your_brick_collection
order  by shape;```




## Problem 03
Complete the following query to return a list of all the shapes in my collection not in yours:

## Schema
``` select shape from my_brick_collection
minus
select shape from your_brick_collection;
);
```## Problem 01
Complete the following query to return a list of all the colours that are in both tables:```
```
## Schema
```select colour from my_brick_collection
intersect
select colour from your_brick_collection
order  by colour;;
);



── sql_challenges/
│   ├── challenge-01/
│   │   ├── README.md
│   │   ├── solution.sql
│   │   └── notes.md
│   ├── challenge-02/
│   │   └── README.md