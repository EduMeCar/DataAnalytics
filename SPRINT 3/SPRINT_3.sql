-- SPRINT 3 - EDUARDO MEJIA CARBALLO

-- ===========================================
-- NIVEL 1 - EJERCICIO 1 
-- Crear tabla credit_card y establecer relaciones
-- ===========================================

-- Crear tabla credit_card
CREATE TABLE credit_card (
    id VARCHAR(20) PRIMARY KEY,
    iban VARCHAR(50),
    pan CHAR(30),
    pin CHAR(4),
    cvv INT,
    expiring_date VARCHAR(20)
);

-- Insertar datos de tarjetas del archivo dades_introduir_credit

-- Insertar tarjeta CcU-9999 para uso en transacciones
INSERT INTO credit_card(id) VALUES ("CcU-9999");

-- Establecer relación con tabla transaction
ALTER TABLE transaction ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Verificar datos insertados
SELECT COUNT(*) as total_tarjetas FROM credit_card;

-- ===========================================
-- NIVEL 1 - EJERCICIO 2
-- Corregir IBAN de tarjeta específica
-- ===========================================

-- Mostrar tarjeta antes del cambio
SELECT id, iban FROM credit_card WHERE id = 'CcU-2938';

-- Actualizar IBAN
UPDATE credit_card SET iban = 'TR323456312213576817699999' WHERE id = 'CcU-2938';

-- Verificar cambio
SELECT id, iban FROM credit_card WHERE id = 'CcU-2938';

-- ===========================================
-- NIVEL 1 - EJERCICIO 3
-- Insertar nueva transacción
-- ===========================================

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- Verificar transacción insertada
SELECT * FROM transaction WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- ===========================================
-- NIVEL 1 - EJERCICIO 4
-- Eliminar columna pan de credit_card
-- ===========================================

-- Mostrar estructura antes
DESCRIBE credit_card;

-- Eliminar columna pan
ALTER TABLE credit_card DROP COLUMN pan;

-- Mostrar estructura después
DESCRIBE credit_card;

-- ===========================================
-- NIVEL 2 - EJERCICIO 1
-- Eliminar transacción específica
-- ===========================================

DELETE FROM transaction WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Verificar eliminación
SELECT * FROM transaction WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- ===========================================
-- NIVEL 2 - EJERCICIO 2
-- Crear vista de marketing
-- ===========================================

CREATE VIEW VistaMarketing AS
SELECT 
    c.company_name AS Nom_companyia,
    c.phone AS Telefon_contacte,
    c.country AS Pais_residencia,
    AVG(t.amount) AS Mitjana_compra
FROM company c 
JOIN transaction t ON c.id = t.company_id
WHERE t.amount IS NOT NULL
GROUP BY c.id
ORDER BY Mitjana_compra DESC;

-- Mostrar vista completa
SELECT * FROM VistaMarketing;

-- ===========================================
-- NIVEL 2 - EJERCICIO 3
-- Filtrar vista por Alemania
-- ===========================================

SELECT * FROM VistaMarketing WHERE Pais_residencia = 'Germany';

-- ===========================================
-- NIVEL 3 - EJERCICIO 1
-- Modificaciones en la base de datos
-- ===========================================

-- Renombrar tabla user a data_user
RENAME TABLE user TO data_user;

-- Insertar usuario 9999 para uso en transacciones
INSERT INTO data_user(id) VALUES("9999");

-- Asegurar compatibilidad de tipos de datos
ALTER TABLE data_user MODIFY id INT;

-- Agregar fecha_actual a credit_card
ALTER TABLE credit_card ADD COLUMN fecha_actual DATE;

-- Poblar fecha_actual con fecha actual
UPDATE credit_card SET fecha_actual = CURDATE();

-- Establecer relación entre transaction y data_user
ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES data_user(id);

-- Verificar cambios
SHOW TABLES LIKE 'data_user';
DESCRIBE data_user;
DESCRIBE credit_card;
SELECT COUNT(*) AS total_usuarios FROM data_user;

-- ===========================================
-- NIVEL 3 - EJERCICIO 2
-- Crear vista InformeTecnico
-- ===========================================

CREATE VIEW InformeTecnico AS
SELECT 
    t.id AS ID_transaccio,
    u.name AS Nom_usuari,
    u.surname AS Cognom_usuari,
    cc.iban AS IBAN_targeta,
    c.company_name AS Nom_companyia
FROM transaction t
JOIN data_user u ON t.user_id = u.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id
ORDER BY t.id DESC;

-- Mostrar resultados de la vista ordenados
SELECT * FROM InformeTecnico;

-- Verificar creación de la vista
SHOW CREATE VIEW InformeTecnico;

-- ===========================================
-- FIN DEL SPRINT 
-- EMC
-- ===========================================