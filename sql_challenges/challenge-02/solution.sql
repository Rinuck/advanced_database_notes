# SQL Challenge 02 Join

## Problem
Find the domestic and international sales for each movie

## Schema

SELECT title, domestic_sales, international_sales 
FROM movies
  JOIN boxoffice
    ON movies.id = boxoffice.movie_id;

## Problem
Show the sales numbers for each movie that did better internationally rather than domestically

## Schema

SELECT title, domestic_sales, international_sales 
FROM movies
  JOIN boxoffice
    ON movies.id = boxoffice.movie_id
    Where domestic_sales < international_sales;

## Problem
List all the movies by their ratings in descending order

## Schema
SELECT title, rating
FROM movies
  JOIN boxoffice
    ON movies.id = boxoffice.movie_id
    ORDER BY rating DESC

![alt text](image.png)


## Problem
Find the list of all buildings that have employees

## Schema
SELECT DISTINCT building FROM employees;


## Problem

Find the list of all buildings and their capacity

## Schema

SELECT building_name, capacity 
from buildings;

## Problem
List all buildings and the distinct employee roles in each building (including empty buildings)

## Schema

SELECT DISTINCT building_name, role 
FROM buildings 
  LEFT JOIN employees
    ON building_name = building;

![alt text](image-1.png)

## Problem

Assume youre given two tables containing data about Facebook Pages and their respective likes (as in "Like a Facebook Page").

Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.

## Schema

SELECT page_id from pages except select page_id from page_likes order by page_id;

![alt text](image-2.png)


