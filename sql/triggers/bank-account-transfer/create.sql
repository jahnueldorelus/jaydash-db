DELIMITER $$
USE `dashboard`$$
DROP trigger IF EXISTS `create_bank_account_transfer`$$

-- Updates the associated bank accounts' amounts after the transfer is created
CREATE trigger `create_bank_account_transfer` AFTER INSERT ON BankAccountTransfer
	FOR EACH ROW	
		BEGIN
			DECLARE fromBankId INT UNSIGNED;
			DECLARE toBankId INT UNSIGNED;

			DECLARE fromBankOldAmount DECIMAL(10,2);
			DECLARE toBankOldAmount DECIMAL(10,2);

			DECLARE fromBankAccountType VARCHAR(50);
			DECLARE toBankAccountType VARCHAR(50);

			DECLARE creditCardBankAccount VARCHAR(11);
			SET creditCardBankAccount = "Credit Card";

			-- Gets the "from" bank account info
			SELECT BankAccount.bank_id, BankAccount.amount, BankAccountType.type 
				INTO fromBankId, fromBankOldAmount, fromBankAccountType
				FROM BankAccount
					LEFT JOIN BankAccountType ON BankAccountType.id = BankAccount.type_id
				WHERE BankAccount.id = NEW.from_bank_account_id;

			-- Gets the "to" bank account info
			SELECT BankAccount.bank_id, BankAccount.amount, BankAccountType.type 
				INTO toBankId, toBankOldAmount, toBankAccountType
				FROM BankAccount
					LEFT JOIN BankAccountType ON BankAccountType.id = BankAccount.type_id
				WHERE BankAccount.id = NEW.to_bank_account_id;
				
			-- If the bank accounts belong to seperate banks
			IF fromBankId != toBankId THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Can't create a transfer between accounts that are not from the same bank";
			END IF;

			-- Sets the new updated "from" bank account balance
			IF fromBankAccountType = creditCardBankAccount THEN 
				UPDATE BankAccount SET amount = fromBankOldAmount + NEW.amount WHERE id = NEW.from_bank_account_id;
			ELSE
				UPDATE BankAccount SET amount = fromBankOldAmount - NEW.amount WHERE id = NEW.from_bank_account_id;
			END IF;

			-- Sets the new updated "to" bank account balance
			IF toBankAccountType = creditCardBankAccount THEN 
				UPDATE BankAccount SET amount = toBankOldAmount - NEW.amount WHERE id = NEW.to_bank_account_id;
			ELSE
				UPDATE BankAccount SET amount = toBankOldAmount + NEW.amount WHERE id = NEW.to_bank_account_id;
			END IF;
		END$$
DELIMITER ;
