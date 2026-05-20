# Session 2026-04-07

## Topics covered
- Vector Search with Oracle 23ai
- Vector embeddings (text to numbers)
- Cosine similarity
- Semantic search vs keyword search

## SQL overview
Practice the use of:
- CREATE TABLE with VECTOR data type
- INSERT with TO_VECTOR
- VECTOR_DISTANCE(..., COSINE)
- FETCH FIRST N ROWS ONLY

## What I understood
- Vector search finds by MEANING, not keywords
- Score near 0 = very similar
- Score near 1 = very different
- Generate embeddings with SentenceTransformer
- Load vectors into Oracle using TO_VECTOR

## What is still confusing
- When to use LIKE vs = (answer: = for exact value, LIKE for patterns with %)

## Questions
None

## Related concepts
No

## Resources Used
Google Colab, Wikipedia API, SentenceTransformers, Oracle 23ai, freesql.com