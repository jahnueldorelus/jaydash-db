DELIMITER $$
USE `dashboard`$$
DROP PROCEDURE IF EXISTS `update_user_external_app`$$

CREATE PROCEDURE `update_user_external_app` (IN param_userId INT UNSIGNED, param_externalAppId INT UNSIGNED,
											param_name VARCHAR(255), param_link VARCHAR(255), param_imgExt ENUM('jpg', 
											'jpeg', 'jfif', 'pjpeg', 'pjp', 'png', 'svg', 'webp'))
BEGIN
	SET @app_user_id = (SELECT user_id FROM ExternalApp WHERE id = param_externalAppId);

	-- If the external app doesn't exist
	IF (ISNULL(@app_user_id)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot update an external app that doesn't exist";
	END IF;

	-- If the external app doesn't belong to the user
	IF (@app_user_id != param_userId) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot update an external app you don't own";
	END IF;

	UPDATE ExternalApp SET name = param_name, link = param_link, img_ext = param_imgExt
						WHERE user_id = param_userId AND id = param_externalAppId;
	
	CALL get_external_app(param_externalAppId);
END$$
DELIMITER ;