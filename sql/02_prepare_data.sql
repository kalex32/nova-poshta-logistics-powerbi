-- =====================================================
-- Project : Nova Poshta Analytics
-- File    : 02_prepare_data.sql
-- Purpose : Prepare shipment data for analytics
-- Author  : Olexiy Koval
-- =====================================================

-- =====================================================
-- Step 1. Remove duplicate shipment numbers
-- Source: shipments_raw
-- Target: shipments_clean
--
-- Nova Poshta exports from different dates may contain
-- the same shipment multiple times.
-- One record is kept for each shipment number.
-- =====================================================

TRUNCATE TABLE np.shipments_clean;

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
FROM np.shipments_raw;

-- =====================================================
-- Step 2. Build shipments_final
-- Source : shipments_clean
-- Target : shipments_final
-- =====================================================

TRUNCATE TABLE np.shipments_final;

INSERT INTO np.shipments_final (
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
FROM np.shipments_clean; 
-- TODO:
-- Shipment classification is currently based on receiver address patterns.
-- Replace address-based classification with a unique business identifier when available.


-- ========================================
-- Validation
-- ========================================

SELECT 
count(*) AS shipments_clean
FROM np.shipments_clean;

SELECT 
count(*) AS shipments_final
FROM np.shipments_final;