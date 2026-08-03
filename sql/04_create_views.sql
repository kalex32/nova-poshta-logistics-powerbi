-- =====================================================
-- Project : Nova Poshta Analytics
-- File    : 04_create_views.sql
-- Purpose : Create business shipment and business sender views for Power BI
-- Author  : Olexiy Koval

-- NOTE:
-- Internal views are used by the customer report.
-- Views with the '_public' suffix expose anonymized data for the public portfolio.
-- =====================================================

CREATE OR REPLACE VIEW np.v_business_sender AS
SELECT
	sender_id,
    sender_contact,
    sender_phone,
    sender_city,
    split_part(sender_contact, ' ', 1) AS sender_last_name
   FROM np.dim_business_sender;

CREATE OR REPLACE VIEW np.v_business_sender_public AS
SELECT
	sender_id,
	'BS' || LPAD(sender_id::text, 3, '0') AS sender_public,
	sender_city
FROM np.v_business_sender;


CREATE OR REPLACE VIEW np.v_shipments_business AS
SELECT
	f.shipment_number,
	f.created_at,
	f.received_at,
	f.sender_contact,
	s.sender_id,
	f.sender_city,
	f.sender_address,
	f.shipment_description,
	f.receiver_address,
	f.weight_kg,
	f.places_count,
	f.declared_value,
	f.delivery_cost
FROM np.shipments_final f
JOIN np.dim_business_sender s
ON f.sender_contact = s.sender_contact
WHERE shipment_type = 'business';

CREATE OR REPLACE VIEW np.v_shipments_business_public AS
SELECT
	'TTN-' || RIGHT(shipment_number, 4) AS shipment_number,
	created_at,
	received_at,
	sender_id,
	weight_kg,
	places_count,
	declared_value,
	delivery_cost
FROM np.v_shipments_business;


-- ========================================
-- Validation
-- ========================================

SELECT COUNT(*) AS v_business_sender
FROM np.v_business_sender;

SELECT COUNT(*) AS v_business_sender_public
FROM np.v_business_sender_public;

SELECT COUNT(*) AS v_shipments_business
FROM np.v_shipments_business;

SELECT COUNT(*) AS v_shipments_business_public
FROM np.v_shipments_business_public;