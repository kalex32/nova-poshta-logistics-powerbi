-- =====================================================
-- Project : Nova Poshta Analytics
-- File    : 03_create_dimensions.sql
-- Purpose : Populate business sender dimension
-- Author  : Olexiy Koval
-- =====================================================

TRUNCATE TABLE np.dim_business_sender RESTART IDENTITY;

INSERT INTO np.dim_business_sender
(
    sender_contact,
    sender_city
)
SELECT DISTINCT ON (sender_contact)
    sender_contact,
    sender_city
FROM np.shipments_final
WHERE shipment_type = 'business'
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
count(*) AS business_senders
FROM np.dim_business_sender;