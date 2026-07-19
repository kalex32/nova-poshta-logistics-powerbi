-- =====================================================
-- Project : Nova Poshta Analytics
-- File    : 05_update_database.sql
-- Purpose : Incremental database update when a new CSV file is available
-- Author  : Olexiy Koval
-- =====================================================

-- =====================================================
-- Incremental update
--
-- Workflow:
-- 1. Import new Nova Poshta CSV into np.shipments_raw.
-- 2. Run this script.
--
-- The script:
-- - adds new shipments to shipments_clean;
-- - transforms new records into shipments_final;
-- - updates the business sender dimension.
-- =====================================================

-- =====================================================
-- Step 0. Clear shipments_raw before importing a new CSV
-- (either run TRUNCATE below or enable "Truncate target table"
-- in the DBeaver Import Wizard).
-- =====================================================

-- TRUNCATE TABLE np.shipments_raw;

-- =====================================================
-- Step 1. Load new shipments into shipments_clean.
--
-- Inserts only new shipment numbers.
-- DISTINCT ON removes duplicate shipment numbers
-- from the current import.
-- NOT EXISTS prevents inserting shipments that
-- already exist in the historical dataset.
-- =====================================================

-- TRUNCATE shipments_raw
-- ↓
-- Import NEW csv
-- ↓
-- Run update_database.sql

INSERT INTO np.shipments_clean
(
    "Номер",
    "Дата створення",
    "Плановий час доставки",
    "Оголошена цінність",
    "Валюта оголошеної цінності",
    "Вартість доставки",
    "Валюта вартості доставки",
    "Вартість адресного забору зі зниж",
    "Вага, кг",
    "Кількість місць",
    "Внутрішній номер",
    "Номер реєстру",
    "Легке повернення посилки",
    "Опис відправлення",
    "Картка для зарахування",
    "Післяплата, грн",
    "Контроль оплати, грн",
    "Відправник",
    "Контакт відправника",
    "Телефон відправника",
    "Місто відправлення",
    "Адреса відправлення",
    "Отримувач",
    "Контакт отримувача",
    "Телефон отримувача",
    "Місто отримання",
    "Адреса отримання",
    "Платник за доставку",
    "Статус",
    "Дата отримання",
    "Додаткова інформація"
)
SELECT DISTINCT ON ("Номер")
    "Номер",
    "Дата створення",
    "Плановий час доставки",
    "Оголошена цінність",
	"Валюта оголошеної цінності",
	"Вартість доставки",
	"Валюта вартості доставки",
	"Вартість адресного забору зі зниж",
	"Вага, кг",
	"Кількість місць",
	"Внутрішній номер",
	"Номер реєстру",
	"Легке повернення посилки",
	"Опис відправлення",
	"Картка для зарахування",
	"Післяплата, грн",
	"Контроль оплати, грн",
	"Відправник",
	"Контакт відправника",
	"Телефон відправника",
	"Місто відправлення",
	"Адреса відправлення",
	"Отримувач",
	"Контакт отримувача",
	"Телефон отримувача",
	"Місто отримання",
	"Адреса отримання",
	"Платник за доставку",
	"Статус",
	"Дата отримання",
	"Додаткова інформація"
FROM np.shipments_raw r
WHERE NOT EXISTS
(
    SELECT 1
    FROM np.shipments_clean c
    WHERE c."Номер" = r."Номер"
);

-- =================================================================
-- Step 2. Transform only newly added shipments into shipments_final.
-- =================================================================

INSERT INTO np.shipments_final 
(
    shipment_number,
    created_at,
    received_at,
    sender_contact,
    sender_city,
    shipment_description,
    receiver_address,
    shipment_type,
    weight_kg,
    places_count,
    declared_value,
    delivery_cost,
    sender_address
)
SELECT
"Номер",
to_timestamp("Дата створення", 'DD.MM.YYYY HH24:MI:SS'),
to_timestamp("Дата отримання", 'DD.MM.YYYY HH24:MI:SS'),
"Контакт відправника",
"Місто відправлення",
"Опис відправлення",
"Адреса отримання",
CASE
	WHEN "Контакт відправника" LIKE '%Коваль%'
	AND "Контакт отримувача" LIKE '%Коваль%'
	THEN 'other'
	WHEN "Адреса отримання" LIKE '%Відділення №2%'
	OR "Адреса отримання" LIKE '%Відділення №3%'
	OR "Адреса отримання" LIKE '%58933%'
	THEN 'business'
	WHEN "Адреса отримання" LIKE '%5002%'
	THEN 'personal'
	ELSE 'outgoing'
END,
"Вага, кг",
"Кількість місць",
"Оголошена цінність",
"Вартість доставки",
"Адреса відправлення"
FROM np.shipments_clean c
WHERE NOT EXISTS
(
	SELECT 1
	FROM np.shipments_final f
	WHERE f.shipment_number = c."Номер"
); 

-- =========================================
-- Step 3. Update business sender dimension.
-- =========================================

INSERT INTO np.dim_business_sender
(
    sender_contact,
    sender_city
)
SELECT DISTINCT ON (sender_contact)
    sender_contact,
    sender_city
FROM np.shipments_final f
WHERE f.shipment_type = 'business' AND 
NOT EXISTS (
		SELECT 1
		FROM np.dim_business_sender s
		WHERE s.sender_contact = f.sender_contact 
)
ORDER BY sender_contact, created_at DESC;


UPDATE np.dim_business_sender b
SET sender_phone = s.sender_phone
FROM (
	SELECT DISTINCT ON ("Контакт відправника")
	    "Контакт відправника" AS sender_contact,
	    "Телефон відправника" AS sender_phone
	FROM np.shipments_clean 
	) s
WHERE b.sender_contact = s.sender_contact;


-- ========================================
-- Validation
-- ========================================

SELECT 
count(*) AS shipments_clean
FROM np.shipments_clean;

SELECT 
count(*) AS shipments_final
FROM np.shipments_final;

SELECT 
count(*) AS business_senders
FROM np.dim_business_sender;