DELIMITER $$

DROP PROCEDURE IF EXISTS apply_scd_type_0$$

CREATE PROCEDURE apply_scd_type_0()
BEGIN
    DELETE FROM stg_customer
    WHERE EXISTS (
        SELECT 1
        FROM dim_customer d
        WHERE d.customer_id = stg_customer.customer_id
          AND (
              d.customer_name <> stg_customer.customer_name OR
              d.email <> stg_customer.email OR
              d.phone <> stg_customer.phone
          )
    );
END$$

DELIMITER ;
