DELIMITER $$
USE `dashboard`$$
DROP trigger IF EXISTS `create_user`$$

-- Makes sure the mongo id given is exactly 24 characters
CREATE trigger `create_user` BEFORE INSERT ON User
	FOR EACH ROW	
		BEGIN
			IF LENGTH(NEW.mongo_id) != 24 THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The new user's mongo id must be exactly 24 characters";
			END IF;
		END$$
DELIMITER ;
