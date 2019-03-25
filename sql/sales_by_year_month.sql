SELECT
  YEAR(created) AS YEAR,
  MONTH(created) AS MONTH,
  COUNT(*) AS reservation,
  SUM(price) AS total
FROM sales
GROUP BY YEAR(created),
         MONTH(created)