delimiter ';'

-- use kavalok;

delete from RobotItem;
delete from Robot;
delete from RobotType;


-- find
-- (\S+)\s(\S*)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)
-- replace
-- ('$1', '$2', $3, '$4', '$5', $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, '$16', $17),

-- delimiter '//'
-- CREATE PROCEDURE dropColumn() BEGIN
-- IF EXISTS(
--   SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE COLUMN_NAME='useCount' AND TABLE_NAME='RobotItem' AND TABLE_SCHEMA='kavalok'
--     )
-- THEN
--   alter table RobotItem drop column useCount;
-- END IF;
-- END;
-- //
-- 
-- delimiter ';'
-- CALL dropColumn();
-- DROP PROCEDURE dropColumn;  

insert into RobotType (name,	info,	level,	catalog,	placement,	price,
  hasColor,	premium,	attack,	defence,	 accuracy,	mobility, 	lifeTime,	useCount,	energy,	robotName,	percent)
values
('vbot', 'super=MB;superMult=6', 1, 'robots', '#', 3000, TRUE, FALSE, 6, 3, 4, 2, 0, -1, 20, '#', 0),
('vbotHelmet1', '', 1, 'robotStuffs', 'H', 300, TRUE, FALSE, 1, 1, 1, 0, 0, -1, 0, 'vbot', 0),
('vbotHelmet2', '', 10, 'robotStuffs', 'H', 900, TRUE, FALSE, 2, 2, 2, 3, 0, -1, 0, 'vbot', 0),
('vbotHelmet3', '', 18, 'robotStuffs', 'H', 1400, TRUE, FALSE, 3, 4, 3, -1, 0, -1, 0, 'vbot', 0),
('vbotArmor1', '', 4, 'robotStuffs', 'S', 600, TRUE, FALSE, 1, 2, 0, 0, 0, -1, 0, 'vbot', 0),
('vbotArmor2', '', 12, 'robotStuffs', 'S', 1300, TRUE, FALSE, 3, 5, 4, 0, 0, -1, 0, 'vbot', 0),
('vbotArmor3', '', 20, 'robotStuffs', 'S', 2000, TRUE, FALSE, 5, 5, 1, 2, 0, -1, 0, 'vbot', 0),
('vbotChassis1', '', 6, 'robotStuffs', 'R', 900, TRUE, FALSE, 2, 2, 0, 1, 0, -1, 0, 'vbot', 0),
('vbotChassis2', '', 14, 'robotStuffs', 'R', 1700, TRUE, FALSE, 3, 3, -1, 3, 0, -1, 0, 'vbot', 0),
('vbotChassis3', '', 22, 'robotStuffs', 'R', 2500, TRUE, FALSE, 5, 6, 3, 3, 0, -1, 0, 'vbot', 0),
('vbotWeapon1', '', 8, 'robotStuffs', 'W', 1200, TRUE, FALSE, 5, 0, 2, 2, 0, -1, 0, 'vbot', 0),
('vbotWeapon2', '', 16, 'robotStuffs', 'W', 2100, TRUE, FALSE, 10, 3, 4, 3, 0, -1, 0, 'vbot', 0),
('vbotWeapon3', '', 24, 'robotStuffs', 'W', 3190, TRUE, FALSE, 20, 5, 6, 4, 0, -1, 0, '*', 0),
('lighting', '', 7, 'robotItems', 'I', 2000, FALSE, FALSE, 40, 0, 0, 0, 0, -1, 0, '*', 0),
('rocket', '', 3, 'robotItems', 'I', 0, FALSE, FALSE, 65, 0, 0, 0, 0, 10, 0, '*', 0),
('rocket2', '', 10, 'robotItems', 'I', 0, FALSE, FALSE, 75, 0, 0, 0, 0, 10, 0, '*', 1),
('defencePlus', '', 5, 'robotItems', 'A', 0, FALSE, FALSE, 0, 75, 0, 0, 14, -1, 0, '*', 1),
('attackPlus', '', 9, 'robotItems', 'A', 0, FALSE, FALSE, 50, 0, 0, 0, 14, -1, 0, '*', 1),
('allPlus', '', 3, 'robotItems', 'A', 0, FALSE, FALSE, 25, 25, 25, 25, 14, -1, 0, '*', 1),
('energyRepair1', '', 3, 'robotItems', 'I', 1000, FALSE, FALSE, 0, 0, 0, 0, 0, 3, 30, '*', 0),
('energyRepair2', '', 5, 'robotItems', 'I', 1500, FALSE, FALSE, 0, 0, 0, 0, 0, 3, 60, '*', 0),
('energyRepair3', '', 7, 'robotItems', 'I', 0, FALSE, FALSE, 0, 0, 0, 0, 0, 10, 100, '*', 1),
('attack1', '', 5, 'robotItems', 'A', 2000, FALSE, FALSE, 1, 0, 0, 0, 5, -1, 0, '*', 0),
('defence1', '', 3, 'robotItems', 'A', 2000, FALSE, FALSE, 0, 2, 0, 0, 5, -1, 0, '*', 0),
('accuracy1', '', 2, 'robotItems', 'A', 1000, FALSE, FALSE, 0, 0, 2, 0, 5, -1, 0, '*', 0),
('mobility1', '', 5, 'robotItems', 'A', 1000, FALSE, FALSE, 0, 0, 0, 2, 5, -1, 0, '*', 0),
('attack5', '', 1, 'robotItems', 'A', 0, FALSE, FALSE, 5, 0, 0, 0, 14, -1, 0, '*', 0);
