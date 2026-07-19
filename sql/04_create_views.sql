-- =====================================================
-- Project : Nova Poshta Analytics
-- File    : 04_create_views.sql
-- Purpose : Create business shipment view for Power BI
-- Author  : Olexiy Koval
-- =====================================================

CREATE OR REPLACE VIEW np.v_shipments_business AS
SELECT
shipment_number,
created_at,
received_at,
sender_contact,
sender_city,
sender_address,
shipment_description,
receiver_address,
weight_kg,
places_count,
declared_value,
delivery_cost
FROM np.shipments_final
WHERE shipment_type = 'business';


-- ========================================
-- Validation
-- ========================================

SELECT 
count(*) AS v_shipments_business
FROM np.v_shipments_business;