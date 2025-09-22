-- Sprint 2 — SQL - 
## Eduardo Mejía Carballo

-- =========================
-- NIVELL 1
-- =========================
-- Exercici 1
-- A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules.
-- Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen.
-- Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

## Diagrama: en Workbench > Database > Reverse Engineer > EER Diagram y captura ##
 
-- Exercici 2.
-- Utilitzant JOIN realitzaràs les següents consultes: 
-- Llistat dels països que estan fent compres.
SELECT DISTINCT c.country
FROM company c 
JOIN transaction t on t.company_id = c.id
ORDER BY c.country ASC;

-- Exercici 2.1 
-- Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT c.country) AS num_countries
FROM company c 
JOIN transaction t on t.company_id = c.id; 

-- Exercici 2.2 
-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name, 
	avg(t.amount) AS avg_amount
FROM company c 
JOIN transaction t ON t.company_id = c.id
GROUP BY c.id, c.company_name 
ORDER BY avg_amount DESC
limit 1;

-- Exercici 3.
-- Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction t 
WHERE company_id IN (
	SELECT id 
    FROM company 
    WHERE  country = 'Germany');
    
-- EXERCICI 3.1 
-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT DISTINCT c.company_name
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.amount > (SELECT AVG(amount) FROM transaction);

-- Exercici 3.2 
-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT * 
FROM company c 
LEFT JOIN transaction t ON c.id = t.company_id
WHERE t.company_id = null;
-- ---------------------
SELECT c.id, c.company_name, 
COUNT(t.id) AS num_transacciones
FROM company c 
LEFT JOIN transaction t On c.id = t.company_id
GROUP BY c.id, c.company_name
ORDER BY num_transacciones;

-- =========================
-- NIVELL 2
-- =========================

### **Exercici 1**
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.**
SELECT t.timestamp, 
	sum(t.amount) AS total_day
FROM transaction t 
GROUP BY t.timestamp
ORDER BY total_day DESC
LIMIT 5; 

### **Exercici 2**
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.**
SELECT c.country, 
	avg(t.amount) AS avg_amount
FROM company c 
JOIN transaction t ON t.company_id = c.id
GROUP BY c.country
ORDER BY avg_amount DESC;

### **Exercici 3**
-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT *
FROM transaction t	
JOIN company c ON c.id = t.company_id
WHERE c.country = ( 
	SELECT country FROM company WHERE company_name = 'Non Institute'Limit 1
    );
    
-- Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction t
WHERE company_id IN (
	SELECT id FROM company
    WHERE country = (SELECT country FROM company WHERE company_name = 'Non Institute' LIMIT 1)
    );

-- =========================
-- NIVELL 3
-- =========================
### **Exercici 1**

-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022.
-- Ordena els resultats de major a menor quantitat.

SELECT 	c.company_name, c.phone, c.country, t.timestamp, t.amount
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.amount between 100 AND 200 AND DATE(t.timestamp) IN ('2021-04-29','2021-07-20','2022-03-13')
ORDER BY t.amount DESC;

### **Exercici 2**
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es 
-- requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que 
-- realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de 
-- les empreses on especifiquis si tenen més de 4 transaccions o menys.
SELECT c.company_name, 
		COUNT(t.id) AS num_transaccions, 
        CASE
			WHEN count(t.id) > 4 THEN 'Mes de 4'
			ELSE 'Menys o igual a 4'
        END AS classificacio
FROM company c 
JOIN transaction t ON c.id = t.company_id
GROUP BY c.company_name;


