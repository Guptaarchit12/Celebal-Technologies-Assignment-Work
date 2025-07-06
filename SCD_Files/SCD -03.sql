
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    prev_email VARCHAR(100)
);


DROP TABLE IF EXISTS stg_customer;
CREATE TABLE stg_customer (
    customer_id INT,
    name VARCHAR(100),
    email VARCHAR(100)
);


INSERT INTO dim_customer (customer_id, name, email, prev_email)
VALUES 
(1, 'Alice', 'alice@example.com', NULL),
(2, 'Bob', 'bob@example.com', NULL),
(3, 'Charlie', 'charlie@example.com', NULL);

-- Step 4: Insert updated data into stg_customer
INSERT INTO stg_customer (customer_id, name, email)
VALUES 
(1, 'Alice', 'alice_new@example.com'),  -- Email changed
(2, 'Bob', 'bob@example.com'),          -- No change
(3, 'Charlie', 'charlie_new@example.com'); -- Email changed


ALTER TABLE dim_customer ADD INDEX (customer_id);


DROP PROCEDURE IF EXISTS apply_scd_type_3;


DELIMITER //
CREATE PROCEDURE apply_scd_type_3()
BEGIN
    UPDATE dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    SET 
        d.prev_email = d.email,
        d.email = s.email
    WHERE d.email <> s.email;
END;
//
DELIMITER ;


SET SQL_SAFE_UPDATES = 0;


CALL apply_scd_type_3();


SET SQL_SAFE_UPDATES = 1;


SELECT * FROM dim_customer;
