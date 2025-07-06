
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
    customer_sk INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    prev_email VARCHAR(100),
    phone VARCHAR(20),
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN
);


DROP TABLE IF EXISTS stg_customer;
CREATE TABLE stg_customer (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20)
);


INSERT INTO dim_customer (customer_id, customer_name, email, prev_email, phone, start_date, end_date, is_current)
VALUES
(1, 'Alice', 'alice@example.com', NULL, '1234567890', '2024-01-01', NULL, TRUE),
(2, 'Bob', 'bob@example.com', NULL, '9876543210', '2024-01-01', NULL, TRUE);


INSERT INTO stg_customer (customer_id, customer_name, email, phone)
VALUES
(1, 'Alice', 'alice_new@example.com', '1234567890'),  -- email changed
(2, 'Bob', 'bob@example.com', '9876543210');          -- no change


DROP PROCEDURE IF EXISTS apply_scd_type_6;

DELIMITER //
CREATE PROCEDURE apply_scd_type_6()
BEGIN
   
    UPDATE dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    SET d.end_date = CURDATE(),
        d.is_current = FALSE
    WHERE d.is_current = TRUE AND (
        d.customer_name <> s.customer_name OR
        d.email <> s.email OR
        d.phone <> s.phone
    );

  
    INSERT INTO dim_customer (customer_id, customer_name, email, prev_email, phone, start_date, end_date, is_current)
    SELECT
        s.customer_id,
        s.customer_name,
        s.email,
        d.email,
        s.phone,
        CURDATE(),
        NULL,
        TRUE
    FROM stg_customer s
    JOIN dim_customer d ON s.customer_id = d.customer_id
    WHERE d.is_current = FALSE AND (
        d.customer_name <> s.customer_name OR
        d.email <> s.email OR
        d.phone <> s.phone
    );
END;
//
DELIMITER ;


SET SQL_SAFE_UPDATES = 0;


CALL apply_scd_type_6();


SELECT * FROM dim_customer;
