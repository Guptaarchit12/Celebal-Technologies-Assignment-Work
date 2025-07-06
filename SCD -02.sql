DELIMITER $$

CREATE PROCEDURE apply_scd_type_2()
BEGIN
    DECLARE v_today DATE;
    SET v_today = CURDATE();

    -- Step 1: Expire the old records
    UPDATE dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    SET d.valid_to = DATE_SUB(v_today, INTERVAL 1 DAY),
        d.is_current = FALSE
    WHERE d.is_current = TRUE
      AND (d.customer_name <> s.customer_name
           OR d.email <> s.email
           OR d.phone <> s.phone);

    -- Step 2: Insert new updated records
    INSERT INTO dim_customer (
        customer_id, customer_name, email, phone, valid_from, valid_to, is_current
    )
    SELECT
        s.customer_id, s.customer_name, s.email, s.phone,
        v_today, '9999-12-31', TRUE
    FROM stg_customer s
    LEFT JOIN dim_customer d ON s.customer_id = d.customer_id AND d.is_current = TRUE
    WHERE d.customer_id IS NULL
       OR d.customer_name <> s.customer_name
       OR d.email <> s.email
       OR d.phone <> s.phone;
END $$

DELIMITER ;
