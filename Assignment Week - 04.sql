CREATE TABLE StudentDetails (
    StudentId VARCHAR(20) PRIMARY KEY,
    GPA DECIMAL(3,2)
);

CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(20) PRIMARY KEY,
    RemainingSeats INT
);

CREATE TABLE StudentPreference (
    StudentId VARCHAR(20),
    SubjectId VARCHAR(20),
    Preference INT
);

CREATE TABLE Allotments (
    SubjectId VARCHAR(20),
    StudentId VARCHAR(20)
);

CREATE TABLE UnallotedStudents (
    StudentId VARCHAR(20)
);

INSERT INTO StudentDetails VALUES 
('S1', 9.1),
('S2', 8.5),
('S3', 7.9);

INSERT INTO SubjectDetails VALUES 
('OE1', 1),
('OE2', 1),
('OE3', 1);

INSERT INTO StudentPreference VALUES 
('S1', 'OE1', 1), ('S1', 'OE2', 2), ('S1', 'OE3', 3),
('S2', 'OE1', 1), ('S2', 'OE3', 2), ('S2', 'OE2', 3),
('S3', 'OE2', 1), ('S3', 'OE1', 2), ('S3', 'OE3', 3);

DELIMITER //
DROP PROCEDURE IF EXISTS AllocateOpenElectives;
CREATE PROCEDURE AllocateOpenElectives()
BEGIN
    DECLARE done_students INT DEFAULT FALSE;
    DECLARE v_studentId VARCHAR(20);
    DECLARE v_subjectId VARCHAR(20);
    DECLARE v_pref_studentId VARCHAR(20);
    DECLARE v_preference INT;
    DECLARE subject_allotted INT DEFAULT 0;

    DECLARE student_cursor CURSOR FOR
        SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_students = TRUE;

    DELETE FROM Allotments;
    DELETE FROM UnallotedStudents;

    OPEN student_cursor;

    student_loop: LOOP
        FETCH student_cursor INTO v_studentId;
        IF done_students THEN
            LEAVE student_loop;
        END IF;

        SET subject_allotted = 0;

        BEGIN
            DECLARE done_prefs_local INT DEFAULT FALSE;
            DECLARE pref_cursor CURSOR FOR
                SELECT StudentId, SubjectId, Preference
                FROM StudentPreference
                WHERE StudentId = v_studentId
                ORDER BY Preference ASC;

            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_prefs_local = TRUE;

            OPEN pref_cursor;

            pref_loop: LOOP
                FETCH pref_cursor INTO v_pref_studentId, v_subjectId, v_preference;
                IF done_prefs_local THEN
                    LEAVE pref_loop;
                END IF;

                IF (SELECT RemainingSeats FROM SubjectDetails WHERE SubjectId = v_subjectId) > 0 THEN
                    INSERT INTO Allotments (SubjectId, StudentId)
                    VALUES (v_subjectId, v_studentId);

                    UPDATE SubjectDetails
                    SET RemainingSeats = RemainingSeats - 1
                    WHERE SubjectId = v_subjectId;

                    SET subject_allotted = 1;
                    LEAVE pref_loop;
                END IF;
            END LOOP;

            CLOSE pref_cursor;
        END;

        IF subject_allotted = 0 THEN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (v_studentId);
        END IF;
    END LOOP;

    CLOSE student_cursor;
END //

DELIMITER ;

