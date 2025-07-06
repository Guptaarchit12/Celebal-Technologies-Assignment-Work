
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20)
);


DROP TABLE IF EXISTS stg_customer;
CREATE TABLE stg_customer (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20)
);


DROP TABLE IF EXISTS hist_customer;
CREATE TABLE hist_customer (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    changed_date DATE
);


INSERT INTO dim_customer (customer_id, customer_name, email, phone)
VALUES 
(1, 'Alice', 'alice@example.com', '1234567890'),
(2, 'Bob', 'bob@example.com', '9876543210'),
(3, 'Charlie', 'charlie@example.com', '1112223333');


INSERT INTO stg_customer (customer_id, customer_name, email, phone)
VALUES 
(1, 'Alice', 'alice_new@example.com', '1234567890'), -- email changed
(2, 'Bob', 'bob@example.com', '9876543210'),         -- no change
(3, 'Charlie X', 'charlie@example.com', '0001112222'); -- name and phone changed


DROP PROCEDURE IF EXISTS apply_scd_type_4;


DELIMITER //
CREATE PROCEDURE apply_scd_type_4()
BEGIN
    -- Step A: Insert old records to history before update
    INSERT INTO hist_customer (customer_id, customer_name, email, phone, changed_date)
    SELECT d.customer_id, d.customer_name, d.email, d.phone, CURDATE()
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.customer_name <> s.customer_name
       OR d.email <> s.email
       OR d.phone <> s.phone;

    
    UPDATE dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    SET
        d.customer_name = s.customer_name,
        d.email = s.email,
        d.phone = s.phone
    WHERE d.customer_name <> s.customer_name
       OR d.email <> s.email
       OR d.phone <> s.phone;
END;
//
DELIMITER ;


SET SQL_SAFE_UPDATES = 0;


CALL apply_scd_type_4();


SELECT * FROM dim_customer;


SELECT * FROM hist_customer;
