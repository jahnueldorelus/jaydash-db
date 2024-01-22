DELIMITER $$
USE `dashboard`$$
DROP PROCEDURE IF EXISTS `get_user_network_switch_vlans`$$

CREATE PROCEDURE `get_user_network_switch_vlans` (IN param_userId INT UNSIGNED, param_switchId INT UNSIGNED)
BEGIN
	SET @errorMessage = "Cannot retrieve vlans for a network switch the user doesn't have";
	SET @switchUserId = (SELECT user_id FROM NetworkSwitch  
							WHERE NetworkSwitch.id = param_switchId);

	-- If the network switch doesn't exist
	IF ISNULL(@switchUserId) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @errorMessage;
	END IF;

	-- If the network switch doesn't belong to the user
	IF @switchUserId != param_userId THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @errorMessage;
	END IF;

	SELECT id, switch_id as switchId, name, vid
		FROM NetworkSwitchVlan
		WHERE switch_id = param_switchId
		ORDER BY vid DESC;
END$$
DELIMITER ;