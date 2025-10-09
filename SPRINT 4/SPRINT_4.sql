-- SPRINT 4 - EMC
-- =============================================

CREATE DATABASE sprint4;
USE sprint4;

-- =============================================
-- CREACIÓN DE TABLAS
-- =============================================

-- Tabla companies
CREATE TABLE companies (
    company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

-- Tabla products
CREATE TABLE products (
    id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    colour VARCHAR(50),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(20)
);

-- Tabla users (combinar americanos y europeos)
CREATE TABLE users (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    region ENUM('America', 'Europe')
);

-- Tabla credit_cards
CREATE TABLE credit_cards (
    id VARCHAR(20) PRIMARY KEY,
    user_id VARCHAR(20),
    iban VARCHAR(50),
    pan VARCHAR(30),
    pin VARCHAR(10),
    cvv VARCHAR(5),
    track1 TEXT,
    track2 TEXT,
    expiring_date VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Tabla transactions
CREATE TABLE transactions (
    id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp DATETIME,
    amount DECIMAL(10,2),
    declined TINYINT(1),
    product_ids TEXT,
    user_id VARCHAR(20),
    lat DECIMAL(10,6),
    longitude DECIMAL(10,6),
    FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =============================================
-- CARGA DE DATOS DESDE ARCHIVOS CSV
-- =============================================

-- 1. Cargar companies
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. Cargar products (limpiando símbolo $ del precio)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id)
SET price = REPLACE(@price, '$', '');

-- 3. Cargar american_users como región America
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET region = 'America', 
    birth_date = STR_TO_DATE(@birth_date, '%M %d, %Y');

-- 4. Cargar european_users como región Europe
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET region = 'Europe', 
    birth_date = STR_TO_DATE(@birth_date, '%M %d, %Y');

-- 5. Cargar credit_cards
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 6. Cargar transactions (con ; como separador)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =============================================
-- VERIFICACIÓN DE DATOS CARGADOS
-- =============================================

SELECT 'companies' as tabla, COUNT(*) as total FROM companies
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL  
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'credit_cards', COUNT(*) FROM credit_cards
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions;

-- =============================================
-- NIVEL 1 - CONSULTAS
-- =============================================

-- Exercici 1: Usuarios con más de 80 transacciones
SELECT u.*
FROM users u
WHERE u.id IN (
    SELECT t.user_id
    FROM transactions t
    GROUP BY t.user_id
    HAVING COUNT(*) > 80
);

-- Exercici 2: Media de amount por IBAN en Donec Ltd
SELECT AVG(t.amount) as mitjana_amount, cc.iban
FROM transactions t
JOIN credit_cards cc ON t.card_id = cc.id
JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

-- =============================================
-- NIVEL 2 - ESTADO DE TARJETAS
-- =============================================

-- Exercici 1: Tarjetas activas (solución compleja - exacta)
SELECT COUNT(*) as targetes_actives
FROM (
    SELECT 
        card_id,
        SUM(declined) as total_declinadas
    FROM (
        SELECT 
            card_id,
            declined,
            (SELECT COUNT(*) 
             FROM transactions t2 
             WHERE t2.card_id = t1.card_id 
             AND t2.timestamp >= t1.timestamp) as orden
        FROM transactions t1
    ) AS transacciones_numeradas
    WHERE orden <= 3
    GROUP BY card_id
    HAVING COUNT(*) = 3 AND SUM(declined) < 3  
) AS tarjetas_activas;

-- Exercici 1: Tarjetas activas (solución simple - práctica)
SELECT COUNT(DISTINCT card_id) as targetes_actives
FROM transactions 
WHERE card_id IN (
    SELECT DISTINCT card_id 
    FROM transactions 
    WHERE declined = 0
)
AND card_id IN (
    SELECT card_id 
    FROM transactions 
    GROUP BY card_id 
    HAVING COUNT(*) >= 3
);

-- =============================================
-- NIVEL 3 - PRODUCTOS Y TRANSACCIONES
-- =============================================

-- Crear tabla intermedia para relación muchos-a-muchos
CREATE TABLE transactions_products (
    transaction_id VARCHAR(50),
    product_id VARCHAR(20),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Poblar tabla intermedia (separar product_ids)
INSERT INTO transactions_products (transaction_id, product_id)
SELECT 
    t.id as transaction_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', n.n), ',', -1)) as product_id
FROM transactions t
JOIN (
    SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
) n
ON CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')) >= n.n - 1;

-- Exercici 1: Número de veces vendido cada producto
SELECT 
    p.id as producto_id,
    p.product_name as nombre_producto,
    COUNT(tp.transaction_id) as veces_vendido
FROM products p
JOIN transactions_products tp ON p.id = tp.product_id
GROUP BY p.id, p.product_name
ORDER BY veces_vendido DESC;

