-- =====================================================
-- Project : Nova Poshta Analytics
-- File    : 01_create_schema.sql
-- Purpose : Create database schema and tables
-- Author  : Olexiy Koval
-- =====================================================

CREATE SCHEMA IF NOT EXISTS np;

-- =====================================================
-- Table: shipments_raw
-- Purpose: Stores raw data imported from Nova Poshta CSV files.
-- No transformations are applied at this stage.
-- =====================================================

CREATE TABLE IF NOT EXISTS np.shipments_raw (
    "Номер" text,
    "Дата створення" text,
	"Плановий час доставки" text,
	"Оголошена цінність" float4 NULL,
	"Валюта оголошеної цінності" text NULL,
	"Вартість доставки" float4 NULL,
	"Валюта вартості доставки" text NULL,
	"Вартість адресного забору зі зниж" text NULL,
	"Вага, кг" float4 NULL,
	"Кількість місць" int4 NULL,
	"Внутрішній номер" text NULL,
	"Номер реєстру" text NULL,
	"Легке повернення посилки" text NULL,
	"Опис відправлення" text NULL,
	"Картка для зарахування" text NULL,
	"Післяплата, грн" text NULL,
	"Контроль оплати, грн" text NULL,
	"Відправник" text NULL,
	"Контакт відправника" text NULL,
	"Телефон відправника" text NULL,
	"Місто відправлення" text NULL,
	"Адреса відправлення" text NULL,
	"Отримувач" text NULL,
	"Контакт отримувача" text NULL,
	"Телефон отримувача" text NULL,
	"Місто отримання" text NULL,
	"Адреса отримання" text NULL,
	"Платник за доставку" text NULL,
	"Статус" text NULL,
	"Дата отримання" text NULL,
	"Додаткова інформація" text NULL
);

-- =====================================================
-- Table: shipments_clean
-- Purpose: Stores cleaned shipment data before type conversion.
-- =====================================================

CREATE TABLE IF NOT EXISTS np.shipments_clean (
    "Номер" text NULL,
	"Дата створення" text NULL,
	"Плановий час доставки" text NULL,
	"Оголошена цінність" float4 NULL,
	"Валюта оголошеної цінності" text NULL,
	"Вартість доставки" float4 NULL,
	"Валюта вартості доставки" text NULL,
	"Вартість адресного забору зі зниж" text NULL,
	"Вага, кг" float4 NULL,
	"Кількість місць" int4 NULL,
	"Внутрішній номер" text NULL,
	"Номер реєстру" text NULL,
	"Легке повернення посилки" text NULL,
	"Опис відправлення" text NULL,
	"Картка для зарахування" text NULL,
	"Післяплата, грн" text NULL,
	"Контроль оплати, грн" text NULL,
	"Відправник" text NULL,
	"Контакт відправника" text NULL,
	"Телефон відправника" text NULL,
	"Місто відправлення" text NULL,
	"Адреса відправлення" text NULL,
	"Отримувач" text NULL,
	"Контакт отримувача" text NULL,
	"Телефон отримувача" text NULL,
	"Місто отримання" text NULL,
	"Адреса отримання" text NULL,
	"Платник за доставку" text NULL,
	"Статус" text NULL,
	"Дата отримання" text NULL,
	"Додаткова інформація" text NULL
);

-- =====================================================
-- Table: shipments_final
-- Purpose: Stores transformed shipment data for reporting and analysis.
-- =====================================================

CREATE TABLE IF NOT EXISTS np.shipments_final (
	shipment_number text NULL,
	created_at timestamp NULL,
	received_at timestamp NULL,
	sender_contact text NULL,
	sender_city text NULL,
	shipment_description text NULL,
	receiver_address text NULL,
	shipment_type text NULL,
	weight_kg numeric(10, 2) NULL,
	places_count int4 NULL,
	declared_value numeric(12, 2) NULL,
	delivery_cost numeric(12, 2) NULL,
	sender_address text NULL
);

-- =====================================================
-- Table: dim_business_sender
-- Purpose: Stores unique business sender information.
-- =====================================================

CREATE TABLE IF NOT EXISTS np.dim_business_sender (
	sender_id serial4 NOT NULL,
	sender_contact text NOT NULL,
	sender_phone text NULL,
	sender_city text NULL,
	notes text NULL,
	CONSTRAINT dim_business_sender_pkey PRIMARY KEY (sender_id),
	CONSTRAINT dim_business_sender_sender_contact_key UNIQUE (sender_contact)
);