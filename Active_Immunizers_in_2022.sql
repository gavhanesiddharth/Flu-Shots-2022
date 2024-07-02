WITH Active_users AS 
(
SELECT DISTINCT e.patient
FROM encounters AS e
JOIN patients AS pat
ON e.patient = pat.id
WHERE EXTRACT(YEAR FROM e.start) = '2022' 
	  AND pat.deathdate IS NULL 
	  AND EXTRACT(MONTH FROM AGE('2022-12-31', pat.birthdate)) >= 6

),
flu_shot_2022 AS 
(SELECT patient, MIN(date) AS date
FROM immunizations
WHERE description = 'Seasonal Flu Vaccine' AND EXTRACT(YEAR FROM date) = 2022
GROUP BY patient)

SELECT pat.id
	  ,pat.first || ' ' || pat.last AS Name
	  ,pat.birthdate 
	  ,pat.race
	  ,pat.city
	  ,CAST(flu.date AS DATE) AS date
	  ,flu.patient
	  ,EXTRACT(YEAR FROM AGE('2022-12-31', pat.birthdate)) AS AGE
	  ,CASE WHEN flu.patient IS NOT NULL THEN '1'
	   ELSE '0' END AS Count
	  
FROM public.patients AS pat
LEFT JOIN flu_shot_2022 AS flu
ON pat.id = flu.patient
WHERE pat.id IN (SELECT patient FROM Active_users)

