DELIMITER $$
USE `dashboard`$$
DROP PROCEDURE IF EXISTS `get_external_app`$$

CREATE PROCEDURE `get_external_app` (IN param_externalAppId INT UNSIGNED)
BEGIN
	SELECT id, name, link, img_ext as imgExt
		FROM ExternalApp
		WHERE id = param_externalAppId;
END$$
DELIMITER ;