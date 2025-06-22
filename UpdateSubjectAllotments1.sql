DELIMITER $$

DROP PROCEDURE IF EXISTS sp_UpdateSubjectAllotments$$
DROP PROCEDURE IF EXISTS sp_UpdateSubjectAllotments;

CREATE PROCEDURE sp_UpdateSubjectAllotments()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_StudentId VARCHAR(50);
    DECLARE v_NewSubjectId VARCHAR(50);
    DECLARE v_CurrentSubjectId VARCHAR(50);

    DECLARE cur CURSOR FOR
        SELECT StudentId, SubjectId FROM SubjectRequest;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_StudentId, v_NewSubjectId;
        IF done THEN
            LEAVE read_loop;
        END IF;

       
        SELECT SubjectId INTO v_CurrentSubjectId
        FROM SubjectAllotments
        WHERE StudentId = v_StudentId AND Is_Valid = 1
        LIMIT 1;

       
        IF v_CurrentSubjectId IS NULL OR v_CurrentSubjectId != v_NewSubjectId THEN
            
            UPDATE SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentId = v_StudentId AND Is_Valid = 1;

          
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (v_StudentId, v_NewSubjectId, 1);
        END IF;

        
        DELETE FROM SubjectRequest
        WHERE StudentId = v_StudentId AND SubjectId = v_NewSubjectId;

       
        SET v_CurrentSubjectId = NULL;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;
CALL sp_UpdateSubjectAllotments();

