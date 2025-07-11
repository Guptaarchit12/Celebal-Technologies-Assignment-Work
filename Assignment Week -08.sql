DROP TABLE IF EXISTS CalendarDimension;

CREATE TABLE CalendarDimension (
    SKDate INT PRIMARY KEY,
    KeyDate DATE,
    Date DATE,
    CalendarDay INT,
    CalendarMonth INT,
    CalendarQuarter INT,
    CalendarYear INT,
    DayNameLong VARCHAR(20),
    DayNameShort VARCHAR(10),
    DayNumberOfWeek INT,
    DayNumberOfYear INT,
    DaySuffix VARCHAR(5),
    FiscalWeek INT,
    FiscalPeriod INT,
    FiscalQuarter VARCHAR(10),
    FiscalYear INT,
    FiscalYearPeriod VARCHAR(10),
    IsWeekend BOOLEAN,
    WeekOfMonth INT,
    IsLeapYear BOOLEAN
);

DELIMITER //

DROP PROCEDURE IF EXISTS PopulateCalendar //

CREATE PROCEDURE PopulateCalendar(IN input_date DATE)
BEGIN
    DECLARE start_date DATE;
    DECLARE end_date DATE;

    SET start_date = DATE(CONCAT(YEAR(input_date), '-01-01'));
    SET end_date = DATE(CONCAT(YEAR(input_date), '-12-31'));

    INSERT INTO CalendarDimension (
        SKDate, KeyDate, Date, CalendarDay, CalendarMonth, CalendarQuarter,
        CalendarYear, DayNameLong, DayNameShort, DayNumberOfWeek, DayNumberOfYear,
        DaySuffix, FiscalWeek, FiscalPeriod, FiscalQuarter, FiscalYear, FiscalYearPeriod,
        IsWeekend, WeekOfMonth, IsLeapYear
    )
    SELECT
        DATE_FORMAT(dt, '%Y%m%d') + 0 AS SKDate,
        dt AS KeyDate,
        dt AS Date,
        DAY(dt) AS CalendarDay,
        MONTH(dt) AS CalendarMonth,
        QUARTER(dt) AS CalendarQuarter,
        YEAR(dt) AS CalendarYear,
        DAYNAME(dt) AS DayNameLong,
        DATE_FORMAT(dt, '%a') AS DayNameShort,
        DAYOFWEEK(dt) AS DayNumberOfWeek,
        DAYOFYEAR(dt) AS DayNumberOfYear,
        CASE
            WHEN DAY(dt) IN (1,21,31) THEN CONCAT(DAY(dt), 'st')
            WHEN DAY(dt) IN (2,22) THEN CONCAT(DAY(dt), 'nd')
            WHEN DAY(dt) IN (3,23) THEN CONCAT(DAY(dt), 'rd')
            ELSE CONCAT(DAY(dt), 'th')
        END AS DaySuffix,
        WEEK(dt, 3) + 1 AS FiscalWeek,
        MONTH(dt) AS FiscalPeriod,
        CONCAT('Q', QUARTER(dt)) AS FiscalQuarter,
        YEAR(dt) AS FiscalYear,
        CONCAT(YEAR(dt), LPAD(MONTH(dt), 2, '0')) AS FiscalYearPeriod,
        IF(DAYOFWEEK(dt) IN (1,7), 1, 0) AS IsWeekend,
        CEIL(DAY(dt)/7) AS WeekOfMonth,
        IF((MOD(YEAR(dt), 4) = 0 AND MOD(YEAR(dt), 100) != 0) OR MOD(YEAR(dt), 400) = 0, 1, 0) AS IsLeapYear
    FROM (
        SELECT ADDDATE(start_date, INTERVAL t4.num*1000 + t3.num*100 + t2.num*10 + t1.num DAY) AS dt
        FROM
            (SELECT 0 AS num UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
            (SELECT 0 AS num UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
            (SELECT 0 AS num UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
            (SELECT 0 AS num UNION SELECT 1) t4
        WHERE ADDDATE(start_date, INTERVAL t4.num*1000 + t3.num*100 + t2.num*10 + t1.num DAY) <= end_date
    ) AS dates;
END //

CALL PopulateCalendar('2020-07-14') //
SELECT * FROM CalendarDimension LIMIT 10;

DELIMITER ;
