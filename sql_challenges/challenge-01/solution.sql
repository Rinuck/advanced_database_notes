```
## SQL Challenge 1: Select Queries

### Problem 1: Find the title of each film
```sql
SELECT Title FROM Movies;
```

### Problem 2: Find the director of each film
```sql
SELECT Director FROM Movies;
```

### Problem 3: Find the title and director
```sql
SELECT Title, Director FROM Movies;
```

### Problem 4: Find the title and year of each film
```sql
SELECT Title, Year FROM movies;
```

### Problem 5: Find all the information about each film
```sql
SELECT * FROM movies;
```

---

## SQL Challenge 2: Queries with Constraints

### Problem 1: Find the movie with a row id of 6
```sql
SELECT Title FROM movies WHERE id = 6;
```

### Problem 2: Find the movies released in the years between 2000 and 2010
```sql
SELECT Title FROM movies WHERE year BETWEEN 2000 AND 2010;
```

### Problem 3: Find the movies not released in the years between 2000 and 2010
```sql
SELECT Title FROM movies WHERE year NOT BETWEEN 2000 AND 2010;
```

### Problem 4: Find the first 5 Pixar movies and their release year
```sql
SELECT Title, Year FROM movies WHERE id <= 5;
```

---

## SQL Challenge 3: Queries with Constraints Pt.2

### Problem 1: Find all the Toy Story movies
```sql
SELECT Title FROM movies WHERE Title LIKE '%Toy Story%';
```

### Problem 2: Find all the movies directed by John Lasseter
```sql
SELECT Title FROM movies WHERE Director = "John Lasseter";
```

### Problem 3: Find all the movies (and director) not directed by John Lasseter
```sql
SELECT Title, Director FROM movies WHERE Director != "John Lasseter";
```

### Problem 4: Find all the WALL-* movies
```sql
SELECT Title FROM movies WHERE Title LIKE "WALL-%";
```

---

## SQL Challenge 4: Filtering and Sorting Query Results

### Problem 1: List all directors of Pixar movies (alphabetically), without duplicates
```sql
SELECT DISTINCT Director FROM movies ORDER BY Director ASC;
```

### Problem 2: List the last four Pixar movies released (ordered from most recent to least)
```sql
SELECT Title FROM movies ORDER BY Year DESC LIMIT 4;
```

### Problem 3: List the first five Pixar movies sorted alphabetically
```sql
SELECT Title FROM movies ORDER BY Title ASC LIMIT 5;
```

### Problem 4: List the next five Pixar movies sorted alphabetically
```sql
SELECT Title FROM movies ORDER BY Title ASC LIMIT 5 OFFSET 5;
```

---

## Review: Simple Select Queries

### Problem 1: List all the Canadian cities and their populations
```sql
SELECT City, Population FROM north_american_cities WHERE Country = "Canada";
```

### Problem 2: Order all the cities in the United States by their latitude from north to south
```sql
SELECT * FROM north_american_cities WHERE Country = "United States" ORDER BY Latitude DESC;
```

### Problem 3: List all the cities west of Chicago, ordered from west to east
```sql
SELECT City, Longitude FROM north_american_cities WHERE Longitude < -87.629798 ORDER BY Longitude ASC;
```

### Problem 4: List the two largest cities in Mexico (by population)
```sql
SELECT City, Population FROM north_american_cities WHERE Country = "Mexico" ORDER BY Population DESC LIMIT 2;
```

### Problem 5: List the third and fourth largest cities (by population) in the United States and their population
```sql
SELECT City, Population FROM north_american_cities WHERE Country = "United States" ORDER BY Population DESC LIMIT 2 OFFSET 2;
```
```