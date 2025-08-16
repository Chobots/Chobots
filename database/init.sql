/*!40101 SET @OLD_CHARACTER_SET_CLIENT = @@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS = @@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION = @@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE = @@TIME_ZONE */;
/*!40103 SET TIME_ZONE = '+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0 */;
/*!40101 SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES = @@SQL_NOTES, SQL_NOTES = 0 */;

--
-- Table structure for table `Admin`
--

DROP TABLE IF EXISTS `Admin`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Admin`
(
    `id`              bigint(20) NOT NULL AUTO_INCREMENT,
    `created`         datetime     DEFAULT NULL,
    `login`           varchar(255) DEFAULT NULL,
    `password`        varchar(255) DEFAULT NULL,
    `permissionLevel` int(11)      DEFAULT NULL,
    `salt`            varchar(64)  DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `login` (`login`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 2
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Admin`
--

LOCK TABLES `Admin` WRITE;
/*!40000 ALTER TABLE `Admin`
    DISABLE KEYS */;

INSERT INTO `Admin` (`id`, `created`, `login`, `password`, `permissionLevel`, `salt`)
VALUES (1, '2025-01-01 00:00:00', 'admin', '59bb1d5ccc384c90f50cea164abec2bbd069e1a78ed35b80c79bbdd1248dbf8a', 5,
        'vNkshlQFOHkDkdlBGiGosBHXoYeTswja');
/*!40000 ALTER TABLE `Admin`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AllowedWord`
--

DROP TABLE IF EXISTS `AllowedWord`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `AllowedWord`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `word`    varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `word` (`word`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AllowedWord`
--

LOCK TABLES `AllowedWord` WRITE;
/*!40000 ALTER TABLE `AllowedWord`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `AllowedWord`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Ban`
--

DROP TABLE IF EXISTS `Ban`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Ban`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT,
    `created`     datetime   DEFAULT NULL,
    `banCount`    int(11)    NOT NULL,
    `banDate`     datetime   DEFAULT NULL,
    `chatEnabled` tinyint(1) DEFAULT 1,
    `userId`      bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK103EF248B7D4D` (`userId`),
    CONSTRAINT `FK103EF248B7D4D` FOREIGN KEY (`userId`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Ban`
--

LOCK TABLES `Ban` WRITE;
/*!40000 ALTER TABLE `Ban`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `Ban`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `BlackIP`
--

DROP TABLE IF EXISTS `BlackIP`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BlackIP`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `baned`   tinyint(1)   DEFAULT 1,
    `ip`      varchar(15)  DEFAULT NULL,
    `reason`  varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `ip` (`ip`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BlackIP`
--

LOCK TABLES `BlackIP` WRITE;
/*!40000 ALTER TABLE `BlackIP`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `BlackIP`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `BlockWord`
--

DROP TABLE IF EXISTS `BlockWord`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BlockWord`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `word`    varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `word` (`word`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BlockWord`
--

LOCK TABLES `BlockWord` WRITE;
/*!40000 ALTER TABLE `BlockWord`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `BlockWord`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CharQuest`
--

DROP TABLE IF EXISTS `CharQuest`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CharQuest`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT,
    `created`     datetime     DEFAULT NULL,
    `state`       varchar(255) DEFAULT NULL,
    `gameChar_id` bigint(20)   DEFAULT NULL,
    `quest_id`    bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FKD3D45B0C2FF3BA9E` (`quest_id`),
    KEY `FKD3D45B0CB0D63236` (`gameChar_id`),
    CONSTRAINT `FKD3D45B0C2FF3BA9E` FOREIGN KEY (`quest_id`) REFERENCES `Quest` (`id`),
    CONSTRAINT `FKD3D45B0CB0D63236` FOREIGN KEY (`gameChar_id`) REFERENCES `GameChar` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CharQuest`
--

LOCK TABLES `CharQuest` WRITE;
/*!40000 ALTER TABLE `CharQuest`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `CharQuest`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ClientError`
--

DROP TABLE IF EXISTS `ClientError`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ClientError`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime DEFAULT NULL,
    `count`   int(11)  DEFAULT NULL,
    `message` longtext DEFAULT NULL,
    `updated` datetime DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ClientError`
--

LOCK TABLES `ClientError` WRITE;
/*!40000 ALTER TABLE `ClientError`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `ClientError`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Competition`
--

DROP TABLE IF EXISTS `Competition`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Competition`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `finish`  datetime     DEFAULT NULL,
    `name`    varchar(255) DEFAULT NULL,
    `start`   datetime     DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Competition`
--

LOCK TABLES `Competition` WRITE;
/*!40000 ALTER TABLE `Competition`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `Competition`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CompetitionResult`
--

DROP TABLE IF EXISTS `CompetitionResult`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CompetitionResult`
(
    `id`             bigint(20) NOT NULL AUTO_INCREMENT,
    `created`        datetime     DEFAULT NULL,
    `login`          varchar(255) DEFAULT NULL,
    `score`          double       DEFAULT NULL,
    `user_id`        bigint(20)   DEFAULT NULL,
    `competition_id` bigint(20)   DEFAULT NULL,
    `competitor_id`  bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK7EC1FA9C3E4E2815` (`competitor_id`),
    KEY `FK7EC1FA9C4D9B3936` (`user_id`),
    KEY `FK7EC1FA9CC86C867E` (`competition_id`),
    CONSTRAINT `FK7EC1FA9C3E4E2815` FOREIGN KEY (`competitor_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FK7EC1FA9C4D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FK7EC1FA9CC86C867E` FOREIGN KEY (`competition_id`) REFERENCES `Competition` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CompetitionResult`
--

LOCK TABLES `CompetitionResult` WRITE;
/*!40000 ALTER TABLE `CompetitionResult`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `CompetitionResult`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Config`
--

DROP TABLE IF EXISTS `Config`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Config`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `name`    varchar(255) DEFAULT NULL,
    `value`   tinyblob     DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 5
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Config`
--

LOCK TABLES `Config` WRITE;
/*!40000 ALTER TABLE `Config`
    DISABLE KEYS */;
INSERT INTO `Config` (`id`, `created`, `name`, `value`)
VALUES (1, '2025-01-01 00:00:00', 'registrationEnabled',
        X'ACED0005737200116A6176612E6C616E672E426F6F6C65616ECD207280D59CFAEE0200015A000576616C7565787001');
INSERT INTO `Config` (`id`, `created`, `name`, `value`)
VALUES (2, '2025-01-01 00:00:00', 'guestEnabled',
        X'ACED0005737200116A6176612E6C616E672E426F6F6C65616ECD207280D59CFAEE0200015A000576616C7565787000');
INSERT INTO `Config` (`id`, `created`, `name`, `value`)
VALUES (3, '2025-01-01 00:00:00', 'spamMessagesCount',
        X'ACED0005737200116A6176612E6C616E672E496E746567657212E2A0A4F781873802000149000576616C7565787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B020000787000000014');
INSERT INTO `Config` (`id`, `created`, `name`, `value`)
VALUES (4, '2025-01-01 00:00:00', 'serverLimit',
        X'ACED0005737200116A6176612E6C616E672E496E746567657212E2A0A4F781873802000149000576616C7565787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870000000C8');
/*!40000 ALTER TABLE `Config`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EmailExtraInfo`
--

DROP TABLE IF EXISTS `EmailExtraInfo`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EmailExtraInfo`
(
    `id`                     bigint(20) NOT NULL AUTO_INCREMENT,
    `created`                datetime     DEFAULT NULL,
    `email`                  varchar(255) DEFAULT NULL,
    `lastRemindPasswordDate` varchar(255) DEFAULT NULL,
    `remindPasswordCount`    int(11)      DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `email` (`email`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EmailExtraInfo`
--

LOCK TABLES `EmailExtraInfo` WRITE;
/*!40000 ALTER TABLE `EmailExtraInfo`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `EmailExtraInfo`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GAMECHAR_IGNORE_LIST`
--

DROP TABLE IF EXISTS `GAMECHAR_IGNORE_LIST`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GAMECHAR_IGNORE_LIST`
(
    `GameChar_id`   bigint(20) NOT NULL,
    `ignoreList_id` bigint(20) NOT NULL,
    KEY `FK1AAE7B74CF74220E` (`ignoreList_id`),
    KEY `FK1AAE7B74B0D63236` (`GameChar_id`),
    CONSTRAINT `FK1AAE7B74B0D63236` FOREIGN KEY (`GameChar_id`) REFERENCES `GameChar` (`id`),
    CONSTRAINT `FK1AAE7B74CF74220E` FOREIGN KEY (`ignoreList_id`) REFERENCES `GameChar` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GAMECHAR_IGNORE_LIST`
--

LOCK TABLES `GAMECHAR_IGNORE_LIST` WRITE;
/*!40000 ALTER TABLE `GAMECHAR_IGNORE_LIST`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `GAMECHAR_IGNORE_LIST`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GameChar`
--

DROP TABLE IF EXISTS `GameChar`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GameChar`
(
    `id`                        bigint(20) NOT NULL AUTO_INCREMENT,
    `created`                   datetime     DEFAULT NULL,
    `body`                      varchar(255) DEFAULT NULL,
    `color`                     int(11)      DEFAULT NULL,
    `firstLogin`                tinyint(1)   DEFAULT 1,
    `magicDate`                 datetime     DEFAULT NULL,
    `money`                     double       DEFAULT NULL,
    `showCharNames`             bit(1)       DEFAULT NULL,
    `totalBonusMoney`           double       DEFAULT NULL,
    `totalMoneyEarned`          double       DEFAULT NULL,
    `totalMoneyEarnedByInvites` double       DEFAULT NULL,
    `userId`                    bigint(20)   DEFAULT NULL,
    `playerCard_id`             bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK9A5F6E88BE92AFF4` (`playerCard_id`),
    CONSTRAINT `FK9A5F6E88BE92AFF4` FOREIGN KEY (`playerCard_id`) REFERENCES `StuffItem` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GameChar`
--

LOCK TABLES `GameChar` WRITE;
/*!40000 ALTER TABLE `GameChar`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `GameChar`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GuestMarketingInfo`
--

DROP TABLE IF EXISTS `GuestMarketingInfo`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GuestMarketingInfo`
(
    `id`              bigint(20) NOT NULL AUTO_INCREMENT,
    `created`         datetime   DEFAULT NULL,
    `marketingInfoId` bigint(20) DEFAULT NULL,
    `userId`          bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK2BF11D1C248B7D4D` (`userId`),
    KEY `FK2BF11D1CA2635C07` (`marketingInfoId`),
    CONSTRAINT `FK2BF11D1C248B7D4D` FOREIGN KEY (`userId`) REFERENCES `User` (`id`),
    CONSTRAINT `FK2BF11D1CA2635C07` FOREIGN KEY (`marketingInfoId`) REFERENCES `MarketingInfo` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GuestMarketingInfo`
--

LOCK TABLES `GuestMarketingInfo` WRITE;
/*!40000 ALTER TABLE `GuestMarketingInfo`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `GuestMarketingInfo`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `InfoPanel`
--

DROP TABLE IF EXISTS `InfoPanel`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `InfoPanel`
(
    `id`      bigint(20)                                               NOT NULL AUTO_INCREMENT,
    `created` datetime                                                          DEFAULT NULL,
    `caption` varchar(255)                                                      DEFAULT NULL,
    `data`    text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    `enabled` bit(1)                                                   NOT NULL DEFAULT b'0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `caption` (`caption`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `InfoPanel`
--

LOCK TABLES `InfoPanel` WRITE;
/*!40000 ALTER TABLE `InfoPanel`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `InfoPanel`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `LoginFromPartner`
--

DROP TABLE IF EXISTS `LoginFromPartner`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LoginFromPartner`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `uid`     varchar(255) DEFAULT NULL,
    `user_id` bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK277EBAB54D9B3936` (`user_id`),
    CONSTRAINT `FK277EBAB54D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `LoginFromPartner`
--

LOCK TABLES `LoginFromPartner` WRITE;
/*!40000 ALTER TABLE `LoginFromPartner`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `LoginFromPartner`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `LoginStatistics`
--

DROP TABLE IF EXISTS `LoginStatistics`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LoginStatistics`
(
    `id`         bigint(20) NOT NULL AUTO_INCREMENT,
    `loginDate`  datetime   DEFAULT NULL,
    `logoutDate` datetime   DEFAULT NULL,
    `user_id`    bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK2655C54C4D9B3936` (`user_id`),
    CONSTRAINT `FK2655C54C4D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `LoginStatistics`
--

LOCK TABLES `LoginStatistics` WRITE;
/*!40000 ALTER TABLE `LoginStatistics`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `LoginStatistics`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MailServer`
--

DROP TABLE IF EXISTS `MailServer`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MailServer`
(
    `id`            bigint(20) NOT NULL AUTO_INCREMENT,
    `created`       datetime     DEFAULT NULL,
    `available`     bit(1)       DEFAULT NULL,
    `lastUsageDate` datetime     DEFAULT NULL,
    `login`         varchar(255) DEFAULT NULL,
    `pass`          varchar(255) DEFAULT NULL,
    `port`          int(11)      DEFAULT NULL,
    `sentLastDay`   int(11)      DEFAULT NULL,
    `url`           varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MailServer`
--

LOCK TABLES `MailServer` WRITE;
/*!40000 ALTER TABLE `MailServer`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `MailServer`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MarketingInfo`
--

DROP TABLE IF EXISTS `MarketingInfo`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MarketingInfo`
(
    `id`            bigint(20) NOT NULL AUTO_INCREMENT,
    `created`       datetime     DEFAULT NULL,
    `activationUrl` varchar(255) DEFAULT NULL,
    `campaign`      varchar(255) DEFAULT NULL,
    `keywords`      varchar(255) DEFAULT NULL,
    `referrer`      varchar(255) DEFAULT NULL,
    `source`        varchar(255) DEFAULT NULL,
    `partner_id`    bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK153C4FD4936EEFDE` (`partner_id`),
    CONSTRAINT `FK153C4FD4936EEFDE` FOREIGN KEY (`partner_id`) REFERENCES `Partner` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MarketingInfo`
--

LOCK TABLES `MarketingInfo` WRITE;
/*!40000 ALTER TABLE `MarketingInfo`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `MarketingInfo`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MembershipHistory`
--

DROP TABLE IF EXISTS `MembershipHistory`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MembershipHistory`
(
    `id`             bigint(20) NOT NULL AUTO_INCREMENT,
    `created`        datetime     DEFAULT NULL,
    `endDate`        datetime     DEFAULT NULL,
    `periodDays`     tinyint(4)   DEFAULT NULL,
    `periodMonths`   tinyint(4)   DEFAULT NULL,
    `reason`         varchar(255) DEFAULT NULL,
    `transaction_id` bigint(20)   DEFAULT NULL,
    `user_id`        bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK7F64D7BEBA26FE1E` (`transaction_id`),
    KEY `FK7F64D7BE4D9B3936` (`user_id`),
    CONSTRAINT `FK7F64D7BE4D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FK7F64D7BEBA26FE1E` FOREIGN KEY (`transaction_id`) REFERENCES `Transaction` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MembershipHistory`
--

LOCK TABLES `MembershipHistory` WRITE;
/*!40000 ALTER TABLE `MembershipHistory`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `MembershipHistory`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MembershipInfo`
--

DROP TABLE IF EXISTS `MembershipInfo`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MembershipInfo`
(
    `id`                          bigint(20) NOT NULL AUTO_INCREMENT,
    `created`                     datetime   DEFAULT NULL,
    `finishedNotificationShowed`  tinyint(1) DEFAULT 0,
    `finishingNotificationShowed` tinyint(1) DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MembershipInfo`
--

LOCK TABLES `MembershipInfo` WRITE;
/*!40000 ALTER TABLE `MembershipInfo`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `MembershipInfo`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Message`
--

DROP TABLE IF EXISTS `Message`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Message`
(
    `id`           bigint(20) NOT NULL AUTO_INCREMENT,
    `created`      datetime   DEFAULT NULL,
    `dateTime`     datetime   DEFAULT NULL,
    `serialized`   blob       DEFAULT NULL,
    `recipient_id` bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK9C2397E73B5578C5` (`recipient_id`),
    CONSTRAINT `FK9C2397E73B5578C5` FOREIGN KEY (`recipient_id`) REFERENCES `GameChar` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Message`
--

LOCK TABLES `Message` WRITE;
/*!40000 ALTER TABLE `Message`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `Message`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MoneyStatistics`
--

DROP TABLE IF EXISTS `MoneyStatistics`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MoneyStatistics`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `date`    datetime     DEFAULT NULL,
    `money`   bigint(20)   DEFAULT NULL,
    `reason`  varchar(255) DEFAULT NULL,
    `user_id` bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK4CD375E34D9B3936` (`user_id`),
    CONSTRAINT `FK4CD375E34D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MoneyStatistics`
--

LOCK TABLES `MoneyStatistics` WRITE;
/*!40000 ALTER TABLE `MoneyStatistics`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `MoneyStatistics`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PaperMessage`
--

DROP TABLE IF EXISTS `PaperMessage`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PaperMessage`
(
    `id`              bigint(20) NOT NULL AUTO_INCREMENT,
    `created`         datetime     DEFAULT NULL,
    `content`         varchar(255) DEFAULT NULL,
    `imagePath`       varchar(255) DEFAULT NULL,
    `locale`          varchar(4)   DEFAULT NULL,
    `publicationDate` datetime     DEFAULT NULL,
    `title`           varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PaperMessage`
--

LOCK TABLES `PaperMessage` WRITE;
/*!40000 ALTER TABLE `PaperMessage`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `PaperMessage`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Partner`
--

DROP TABLE IF EXISTS `Partner`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Partner`
(
    `id`        bigint(20) NOT NULL AUTO_INCREMENT,
    `created`   datetime     DEFAULT NULL,
    `login`     varchar(255) DEFAULT NULL,
    `password`  varchar(255) DEFAULT NULL,
    `portalUrl` varchar(255) DEFAULT NULL,
    `stuff_id`  bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `login` (`login`),
    KEY `FK33F574A8D29900B8` (`stuff_id`),
    CONSTRAINT `FK33F574A8D29900B8` FOREIGN KEY (`stuff_id`) REFERENCES `StuffType` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Partner`
--

LOCK TABLES `Partner` WRITE;
/*!40000 ALTER TABLE `Partner`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `Partner`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Pet`
--

DROP TABLE IF EXISTS `Pet`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Pet`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT,
    `created`     datetime    DEFAULT NULL,
    `atHome`      tinyint(1)  DEFAULT 1,
    `bodyColor`   int(11)    NOT NULL,
    `bottomColor` int(11)    NOT NULL,
    `enabled`     tinyint(1)  DEFAULT 1,
    `faceColor`   int(11)    NOT NULL,
    `food`        int(11)    NOT NULL,
    `health`      int(11)    NOT NULL,
    `loyality`    int(11)    NOT NULL,
    `name`        varchar(15) DEFAULT NULL,
    `sideColor`   int(11)    NOT NULL,
    `topColor`    int(11)    NOT NULL,
    `body_id`     bigint(20)  DEFAULT NULL,
    `bottom_id`   bigint(20)  DEFAULT NULL,
    `face_id`     bigint(20)  DEFAULT NULL,
    `gameChar_id` bigint(20)  DEFAULT NULL,
    `side_id`     bigint(20)  DEFAULT NULL,
    `top_id`      bigint(20)  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK138FF21922FA5` (`bottom_id`),
    KEY `FK138FF5C6BC03B` (`top_id`),
    KEY `FK138FF4F0D2E33` (`face_id`),
    KEY `FK138FFC730CF9` (`side_id`),
    KEY `FK138FFB0D63236` (`gameChar_id`),
    KEY `FK138FF936F48CE` (`body_id`),
    CONSTRAINT `FK138FF21922FA5` FOREIGN KEY (`bottom_id`) REFERENCES `PetItem` (`id`),
    CONSTRAINT `FK138FF4F0D2E33` FOREIGN KEY (`face_id`) REFERENCES `PetItem` (`id`),
    CONSTRAINT `FK138FF5C6BC03B` FOREIGN KEY (`top_id`) REFERENCES `PetItem` (`id`),
    CONSTRAINT `FK138FF936F48CE` FOREIGN KEY (`body_id`) REFERENCES `PetItem` (`id`),
    CONSTRAINT `FK138FFB0D63236` FOREIGN KEY (`gameChar_id`) REFERENCES `GameChar` (`id`),
    CONSTRAINT `FK138FFC730CF9` FOREIGN KEY (`side_id`) REFERENCES `PetItem` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Pet`
--

LOCK TABLES `Pet` WRITE;
/*!40000 ALTER TABLE `Pet`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `Pet`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PetItem`
--

DROP TABLE IF EXISTS `PetItem`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PetItem`
(
    `id`        bigint(20)  NOT NULL AUTO_INCREMENT,
    `created`   datetime     DEFAULT NULL,
    `name`      varchar(255) DEFAULT NULL,
    `placement` varchar(10) NOT NULL,
    `price`     int(11)     NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PetItem`
--

LOCK TABLES `PetItem` WRITE;
/*!40000 ALTER TABLE `PetItem`
    DISABLE KEYS */;
INSERT INTO `PetItem` (`id`, `created`, `name`, `placement`, `price`) VALUES
    (2, '2015-01-01 00:00', 'body1', 'body', 300),
    (3, '2015-01-01 00:00', 'body2', 'body', 300),
    (4, '2015-01-01 00:00', 'body3', 'body', 300),
    (5, '2015-01-01 00:00', 'body4', 'body', 300),
    (6, '2015-01-01 00:00', 'body5', 'body', 300),
    (7, '2015-01-01 00:00', 'body6', 'body', 300),
    (8, '2015-01-01 00:00', 'body7', 'body', 300),
    (9, '2015-01-01 00:00', 'body8', 'body', 300),
    (10, '2015-01-01 00:00', 'body9', 'body', 300),
    (11, '2015-01-01 00:00', 'body10', 'body', 300),
    (12, '2015-01-01 00:00', 'body11', 'body', 300),
    (13, '2015-01-01 00:00', 'body12', 'body', 300),
    (14, '2015-01-01 00:00', 'body13', 'body', 300),
    (15, '2015-01-01 00:00', 'body14', 'body', 300),
    (16, '2015-01-01 00:00', 'body15', 'body', 300),
    (100, '2015-01-01 00:00', 'bottom0', 'bottom', 300),
    (101, '2015-01-01 00:00', 'bottom1', 'bottom', 300),
    (102, '2015-01-01 00:00', 'bottom2', 'bottom', 300),
    (103, '2015-01-01 00:00', 'bottom3', 'bottom', 300),
    (104, '2015-01-01 00:00', 'bottom4', 'bottom', 300),
    (105, '2015-01-01 00:00', 'bottom5', 'bottom', 300),
    (106, '2015-01-01 00:00', 'bottom6', 'bottom', 300),
    (107, '2015-01-01 00:00', 'bottom7', 'bottom', 300),
    (108, '2015-01-01 00:00', 'bottom8', 'bottom', 300),
    (109, '2015-01-01 00:00', 'bottom9', 'bottom', 300),
    (110, '2015-01-01 00:00', 'bottom10', 'bottom', 300),
    (111, '2015-01-01 00:00', 'bottom11', 'bottom', 300),
    (112, '2015-01-01 00:00', 'bottom12', 'bottom', 300),
    (113, '2015-01-01 00:00', 'bottom13', 'bottom', 300),
    (114, '2015-01-01 00:00', 'bottom14', 'bottom', 300),
    (200, '2015-01-01 00:00', 'face0', 'face', 300),
    (201, '2015-01-01 00:00', 'face1', 'face', 300),
    (202, '2015-01-01 00:00', 'face2', 'face', 300),
    (203, '2015-01-01 00:00', 'face3', 'face', 300),
    (204, '2015-01-01 00:00', 'face4', 'face', 300),
    (205, '2015-01-01 00:00', 'face5', 'face', 300),
    (206, '2015-01-01 00:00', 'face6', 'face', 300),
    (207, '2015-01-01 00:00', 'face7', 'face', 300),
    (208, '2015-01-01 00:00', 'face8', 'face', 300),
    (209, '2015-01-01 00:00', 'face9', 'face', 300),
    (210, '2015-01-01 00:00', 'face10', 'face', 300),
    (211, '2015-01-01 00:00', 'face11', 'face', 300),
    (212, '2015-01-01 00:00', 'face12', 'face', 300),
    (214, '2015-01-01 00:00', 'face14', 'face', 300),
    (215, '2015-01-01 00:00', 'face15', 'face', 300),
    (300, '2015-01-01 00:00', 'side0', 'side', 300),
    (301, '2015-01-01 00:00', 'side1', 'side', 300),
    (302, '2015-01-01 00:00', 'side2', 'side', 300),
    (303, '2015-01-01 00:00', 'side3', 'side', 300),
    (304, '2015-01-01 00:00', 'side4', 'side', 300),
    (305, '2015-01-01 00:00', 'side5', 'side', 300),
    (306, '2015-01-01 00:00', 'side6', 'side', 300),
    (307, '2015-01-01 00:00', 'side7', 'side', 300),
    (308, '2015-01-01 00:00', 'side8', 'side', 300),
    (309, '2015-01-01 00:00', 'side9', 'side', 300),
    (310, '2015-01-01 00:00', 'side10', 'side', 300),
    (311, '2015-01-01 00:00', 'side11', 'side', 300),
    (312, '2015-01-01 00:00', 'side12', 'side', 300),
    (313, '2015-01-01 00:00', 'side13', 'side', 300),
    (314, '2015-01-01 00:00', 'side14', 'side', 300),
    (400, '2015-01-01 00:00', 'top0', 'top', 300),
    (401, '2015-01-01 00:00', 'top1', 'top', 300),
    (402, '2015-01-01 00:00', 'top2', 'top', 300),
    (403, '2015-01-01 00:00', 'top3', 'top', 300),
    (404, '2015-01-01 00:00', 'top4', 'top', 300),
    (405, '2015-01-01 00:00', 'top5', 'top', 300),
    (406, '2015-01-01 00:00', 'top6', 'top', 300),
    (407, '2015-01-01 00:00', 'top7', 'top', 300),
    (408, '2015-01-01 00:00', 'top8', 'top', 300),
    (409, '2015-01-01 00:00', 'top9', 'top', 300),
    (410, '2015-01-01 00:00', 'top10', 'top', 300),
    (411, '2015-01-01 00:00', 'top11', 'top', 300),
    (412, '2015-01-01 00:00', 'top12', 'top', 300),
    (413, '2015-01-01 00:00', 'top13', 'top', 300),
    (414, '2015-01-01 00:00', 'top14', 'top', 300);
/*!40000 ALTER TABLE `PetItem`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Quest`
--

DROP TABLE IF EXISTS `Quest`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Quest`
(
    `id`        bigint(20) NOT NULL AUTO_INCREMENT,
    `created`   datetime     DEFAULT NULL,
    `enabled`   tinyint(1)   DEFAULT 1,
    `name`      varchar(255) DEFAULT NULL,
    `server_id` bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`),
    KEY `FK4AC28C22F8C7F36` (`server_id`),
    CONSTRAINT `FK4AC28C22F8C7F36` FOREIGN KEY (`server_id`) REFERENCES `Server` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Quest`
--

LOCK TABLES `Quest` WRITE;
/*!40000 ALTER TABLE `Quest` DISABLE KEYS */;
INSERT INTO `Quest` (id, created, name, enabled, server_id) VALUES (2,NULL,'questChopix',1,NULL),(3,NULL,'questAcademy',1,NULL),(4,NULL,'questNichos',1,NULL),(5,NULL,'questHoover',1,NULL),(8,NULL,'questMusic',0,NULL),(15,NULL,'betaNPC',0,NULL),(16,NULL,'questPatrick',0,NULL),(17,NULL,'questPets',0,NULL),(18,NULL,'questCowboy',0,NULL),(19,NULL,'santaNPC',0,NULL),(20,NULL,'questHalloween',0,NULL);
/*!40000 ALTER TABLE `Quest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ReviewWord`
--

DROP TABLE IF EXISTS `ReviewWord`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ReviewWord`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `word`    varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `word` (`word`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ReviewWord`
--

LOCK TABLES `ReviewWord` WRITE;
/*!40000 ALTER TABLE `ReviewWord`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `ReviewWord`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Robot`
--

DROP TABLE IF EXISTS `Robot`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Robot`
(
    `id`               bigint(20) NOT NULL AUTO_INCREMENT,
    `created`          datetime            DEFAULT NULL,
    `active`           bit(1)              DEFAULT NULL,
    `energy`           int(11)             DEFAULT NULL,
    `experience`       int(11)             DEFAULT NULL,
    `level`            int(11)             DEFAULT NULL,
    `name`             varchar(15)         DEFAULT NULL,
    `numCombats`       int(11)    NOT NULL DEFAULT 0,
    `numWin`           int(11)    NOT NULL DEFAULT 0,
    `superCombination` varchar(5)          DEFAULT NULL,
    `userLogin`        varchar(255)        DEFAULT NULL,
    `user_id`          bigint(20)          DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK4B77A4A4D9B3936` (`user_id`),
    CONSTRAINT `FK4B77A4A4D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Robot`
--

LOCK TABLES `Robot` WRITE;
/*!40000 ALTER TABLE `Robot`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `Robot`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RobotItem`
--

DROP TABLE IF EXISTS `RobotItem`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RobotItem`
(
    `id`             bigint(20) NOT NULL AUTO_INCREMENT,
    `created`        datetime            DEFAULT NULL,
    `color`          int(11)             DEFAULT NULL,
    `expirationDate` datetime            DEFAULT NULL,
    `position`       int(11)    NOT NULL DEFAULT 0,
    `remains`        int(11)    NOT NULL DEFAULT 0,
    `robot_id`       bigint(20)          DEFAULT NULL,
    `type_id`        bigint(20)          DEFAULT NULL,
    `user_id`        bigint(20)          DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK8CA0347D4D9B3936` (`user_id`),
    KEY `FK8CA0347D5523ED9E` (`robot_id`),
    KEY `FK8CA0347DB731E328` (`type_id`),
    CONSTRAINT `FK8CA0347D4D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FK8CA0347D5523ED9E` FOREIGN KEY (`robot_id`) REFERENCES `Robot` (`id`),
    CONSTRAINT `FK8CA0347DB731E328` FOREIGN KEY (`type_id`) REFERENCES `RobotType` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RobotItem`
--

LOCK TABLES `RobotItem` WRITE;
/*!40000 ALTER TABLE `RobotItem`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `RobotItem`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RobotSKU`
--

DROP TABLE IF EXISTS `RobotSKU`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RobotSKU`
(
    `id`                bigint(20) NOT NULL AUTO_INCREMENT,
    `created`           datetime     DEFAULT NULL,
    `currency`          int(11)      DEFAULT NULL,
    `currencyCentsText` varchar(255) DEFAULT NULL,
    `currencyCode`      varchar(255) DEFAULT NULL,
    `currencySign`      varchar(10)  DEFAULT NULL,
    `currencyText`      varchar(5)   DEFAULT NULL,
    `endDate`           datetime     DEFAULT NULL,
    `name`              varchar(255) DEFAULT NULL,
    `price`             double       DEFAULT NULL,
    `productId`         varchar(255) DEFAULT NULL,
    `specialOffer`      tinyint(1)   DEFAULT 0,
    `specialOfferName`  varchar(255) DEFAULT NULL,
    `startDate`         datetime     DEFAULT NULL,
    `robotType_id`      bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FKE3812A739348CD7E` (`robotType_id`),
    CONSTRAINT `FKE3812A739348CD7E` FOREIGN KEY (`robotType_id`) REFERENCES `RobotType` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RobotSKU`
--

LOCK TABLES `RobotSKU` WRITE;
/*!40000 ALTER TABLE `RobotSKU`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `RobotSKU`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RobotTeam`
--

DROP TABLE IF EXISTS `RobotTeam`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RobotTeam`
(
    `id`         bigint(20) NOT NULL AUTO_INCREMENT,
    `created`    datetime     DEFAULT NULL,
    `color`      int(11)      DEFAULT NULL,
    `experience` int(11)      DEFAULT NULL,
    `numCombats` int(11)      DEFAULT NULL,
    `numWin`     int(11)      DEFAULT NULL,
    `userLogin`  varchar(255) DEFAULT NULL,
    `user_id`    bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `user_id` (`user_id`),
    KEY `FK8CA4FBC74D9B3936` (`user_id`),
    CONSTRAINT `FK8CA4FBC74D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RobotTeam`
--

LOCK TABLES `RobotTeam` WRITE;
/*!40000 ALTER TABLE `RobotTeam`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `RobotTeam`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RobotTransaction`
--

DROP TABLE IF EXISTS `RobotTransaction`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RobotTransaction`
(
    `id`                   bigint(20) NOT NULL AUTO_INCREMENT,
    `created`              datetime    DEFAULT NULL,
    `billingRequestParams` longtext    DEFAULT NULL,
    `source`               varchar(50) DEFAULT NULL,
    `state`                tinyint(4) NOT NULL,
    `robotSKU_id`          bigint(20)  DEFAULT NULL,
    `user_id`              bigint(20)  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK781C8E344D9B3936` (`user_id`),
    KEY `FK781C8E342484E16` (`robotSKU_id`),
    CONSTRAINT `FK781C8E342484E16` FOREIGN KEY (`robotSKU_id`) REFERENCES `RobotSKU` (`id`),
    CONSTRAINT `FK781C8E344D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RobotTransaction`
--

LOCK TABLES `RobotTransaction` WRITE;
/*!40000 ALTER TABLE `RobotTransaction`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `RobotTransaction`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RobotType`
--

DROP TABLE IF EXISTS `RobotType`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RobotType`
(
    `id`        bigint(20)  NOT NULL AUTO_INCREMENT,
    `created`   datetime             DEFAULT NULL,
    `accuracy`  int(11)              DEFAULT NULL,
    `attack`    int(11)              DEFAULT NULL,
    `catalog`   varchar(25) NOT NULL,
    `defence`   int(11)              DEFAULT NULL,
    `energy`    int(11)              DEFAULT NULL,
    `hasColor`  bit(1)               DEFAULT NULL,
    `info`      varchar(255)         DEFAULT NULL,
    `level`     int(11)              DEFAULT NULL,
    `lifeTime`  int(11)              DEFAULT NULL,
    `mobility`  int(11)              DEFAULT NULL,
    `name`      varchar(15) NOT NULL,
    `percent`   tinyint(1)  NOT NULL DEFAULT 0,
    `placement` varchar(3)  NOT NULL,
    `premium`   bit(1)               DEFAULT NULL,
    `price`     int(11)              DEFAULT NULL,
    `robotName` varchar(15) NOT NULL,
    `useCount`  int(11)              DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RobotType`
--

LOCK TABLES `RobotType` WRITE;
/*!40000 ALTER TABLE `RobotType`
    DISABLE KEYS */;
INSERT INTO `RobotType` (`id`, `created`, `accuracy`, `attack`, `catalog`, `defence`, `energy`, `hasColor`, `info`, `level`, `lifeTime`, `mobility`, `name`, `percent`, `placement`, `premium`, `price`, `robotName`, `useCount`) VALUES
(1, NULL, 4, 6, 'robots', 3, 20, 1, 'super=MB;superMult=6', 1, 0, 2, 'vbot', 0, '#', 0, 3000, '#', -1);
INSERT INTO `RobotType` (`id`, `created`, `accuracy`, `attack`, `catalog`, `defence`, `energy`, `hasColor`, `info`, `level`, `lifeTime`, `mobility`, `name`, `percent`, `placement`, `premium`, `price`, `robotName`, `useCount`) VALUES
(2, NULL, 1, 1, 'robotStuffs', 1, 0, 1, '', 1, 0, 0, 'vbotHelmet1', 0, 'H', 0, 300, 'vbot', -1);
INSERT INTO `RobotType` (`id`, `created`, `accuracy`, `attack`, `catalog`, `defence`, `energy`, `hasColor`, `info`, `level`, `lifeTime`, `mobility`, `name`, `percent`, `placement`, `premium`, `price`, `robotName`, `useCount`) VALUES
(3, NULL, 2, 2, 'robotStuffs', 2, 0, 1, '', 10, 0, 3, 'vbotHelmet2', 0, 'H', 0, 900, 'vbot', -1);
INSERT INTO `RobotType` (`id`, `created`, `accuracy`, `attack`, `catalog`, `defence`, `energy`, `hasColor`, `info`, `level`, `lifeTime`, `mobility`, `name`, `percent`, `placement`, `premium`, `price`, `robotName`, `useCount`) VALUES
(4, NULL, 3, 3, 'robotStuffs', 4, 0, 1, '', 18, 0, -1, 'vbotHelmet3', 0, 'H', 0, 1400, 'vbot', -1),
(5, NULL, 0, 1, 'robotStuffs', 2, 0, 1, '', 4, 0, 0, 'vbotArmor1', 0, 'S', 0, 600, 'vbot', -1),
(6, NULL, 4, 3, 'robotStuffs', 5, 0, 1, '', 12, 0, 0, 'vbotArmor2', 0, 'S', 0, 1300, 'vbot', -1),
(7, NULL, 1, 5, 'robotStuffs', 5, 0, 1, '', 20, 0, 2, 'vbotArmor3', 0, 'S', 0, 2000, 'vbot', -1),
(8, NULL, 0, 2, 'robotStuffs', 2, 0, 1, '', 6, 0, 1, 'vbotChassis1', 0, 'R', 0, 900, 'vbot', -1),
(9, NULL, -1, 3, 'robotStuffs', 3, 0, 1, '', 14, 0, 3, 'vbotChassis2', 0, 'R', 0, 1700, 'vbot', -1),
(10, NULL, 3, 5, 'robotStuffs', 6, 0, 1, '', 22, 0, 3, 'vbotChassis3', 0, 'R', 0, 2500, 'vbot', -1),
(11, NULL, 2, 5, 'robotStuffs', 0, 0, 1, '', 8, 0, 2, 'vbotWeapon1', 0, 'W', 0, 1200, 'vbot', -1),
(12, NULL, 4, 10, 'robotStuffs', 3, 0, 1, '', 16, 0, 3, 'vbotWeapon2', 0, 'W', 0, 2100, 'vbot', -1),
(13, NULL, 6, 20, 'robotStuffs', 5, 0, 1, '', 24, 0, 4, 'vbotWeapon3', 0, 'W', 0, 3190, '*', -1),
(14, NULL, 0, 40, 'robotItems', 0, 0, 0, '', 10, 0, 0, 'lighting', 0, 'I', 0, 6000, '*', 2),
(15, NULL, 0, 30, 'robotItems', 0, 0, 0, '', 8, 0, 0, 'rocket', 0, 'I', 0, 4800, '*', 2),
(16, NULL, 0, 50, 'robotItems', 0, 0, 0, 'invalid', 12, 0, 0, 'rocket2', 1, 'I', 0, 5000, '*', 2),
(17, NULL, 0, 0, 'robotItems', 75, 0, 0, '', 5, 2, 0, 'defencePlus', 1, 'A', 0, 4000, '*', -1),
(18, NULL, 0, 50, 'robotItems', 0, 0, 0, '', 4, 2, 0, 'attackPlus', 1, 'A', 0, 5000, '*', -1),
(19, NULL, 25, 25, 'robotItems', 25, 0, 0, '', 6, 3, 25, 'allPlus', 1, 'A', 0, 10000, '*', -1),
(20, NULL, 0, 0, 'robotItems', 0, 30, 0, '', 2, 0, 0, 'energyRepair1', 0, 'I', 0, 1000, '*', 1),
(21, NULL, 0, 0, 'robotItems', 0, 60, 0, '', 5, 0, 0, 'energyRepair2', 0, 'I', 0, 1800, '*', 1),
(22, NULL, 0, 0, 'robotItems', 0, 100, 0, '', 7, 0, 0, 'energyRepair3', 0, 'I', 0, 2000, '*', 1),
(23, NULL, 0, 1, 'robotItems', 0, 0, 0, '', 2, 5, 0, 'attack1', 0, 'A', 0, 2000, '*', -1),
(24, NULL, 0, 0, 'robotItems', 1, 0, 0, '', 2, 5, 0, 'defence1', 0, 'A', 0, 2000, '*', -1),
(25, NULL, 5, 0, 'robotItems', 0, 0, 0, '', 1, 5, 0, 'accuracy1', 0, 'A', 0, 1000, '*', -1),
(26, NULL, 0, 0, 'robotItems', 0, 0, 0, '', 1, 5, 1, 'mobility1', 0, 'A', 0, 1000, '*', -1),
(27, NULL, 0, 5, 'robotItems', 2, 0, 0, '', 3, 4, 0, 'attackPlus2', 0, 'A', 0, 1200, '*', -1);
/*!40000 ALTER TABLE `RobotType`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Server`
--

DROP TABLE IF EXISTS `Server`;
CREATE TABLE `Server` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created` datetime DEFAULT NULL,
  `available` tinyint(1) DEFAULT 0,
  `running` tinyint(1) DEFAULT 0,
  `remoteHost` varchar(255) DEFAULT NULL,
  `rtmpPort` int(11) DEFAULT 8935,
  `tls` tinyint(1) DEFAULT 0,
  `lanHost` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Server`
--

LOCK TABLES `Server` WRITE;
/*!40000 ALTER TABLE `Server`
    DISABLE KEYS */;
INSERT INTO `Server` (`id`, `created`, `available`, `running`, `remoteHost`, `rtmpPort`, `tls`, `lanHost`) VALUES
    (1, '2025-01-01 00:00:00', 1, 1, 'localhost', 8935, 0, 'server1');
INSERT INTO `Server` (`id`, `created`, `available`, `running`, `remoteHost`, `rtmpPort`, `tls`, `lanHost`) VALUES
    (2, '2025-01-01 00:00:00', 1, 1, 'localhost', 8936, 0, 'server2');
/*!40000 ALTER TABLE `Server`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ServerStatistics`
--

DROP TABLE IF EXISTS `ServerStatistics`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ServerStatistics`
(
    `id`         bigint(20) NOT NULL AUTO_INCREMENT,
    `created`    datetime   DEFAULT NULL,
    `usersCount` int(11)    DEFAULT NULL,
    `server_id`  bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FKE32108E62F8C7F36` (`server_id`),
    CONSTRAINT `FKE32108E62F8C7F36` FOREIGN KEY (`server_id`) REFERENCES `Server` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ServerStatistics`
--

LOCK TABLES `ServerStatistics` WRITE;
/*!40000 ALTER TABLE `ServerStatistics`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `ServerStatistics`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Shop`
--

DROP TABLE IF EXISTS `Shop`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Shop`
(
    `id`                    bigint(20) NOT NULL AUTO_INCREMENT,
    `created`               datetime     DEFAULT NULL,
    `name`                  varchar(255) DEFAULT NULL,
    `requiredPermission`    varchar(20)  DEFAULT 'PUBLIC',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Shop`
--

LOCK TABLES `Shop` WRITE;
/*!40000 ALTER TABLE `Shop`
    DISABLE KEYS */;
INSERT INTO `Shop` (`id`, `name`, `created`)
VALUES (2, 'magicShop', NULL),
       (3, 'cafe', NULL),
       (6, 'citizenMagicShop', NULL),
       (7, 'citizenAccessoriesShop', NULL),
       (8, 'citizenFurnitureShop', NULL),
       (9, 'citizenHousesShop', NULL),
       (10, 'petFoodShop', NULL),
       (11, 'petGameShop', NULL),
       (12, 'petRestShop', NULL),
       (15, 'air', NULL),
       (19, 'maska ', NULL),
       (20, 'head', NULL),
       (24, 'musicShop', NULL),
       (25, 'ItemOfTheMonth', NULL),
       (27, 'cardsShop', NULL),
       (31, 'locAccShopMasks', NULL),
       (32, 'agentsShop', NULL),
       (41, 'z_trash', NULL),
       (304, 'christmas', NULL),
       (305, 'accessories', NULL),
       (306, 'legs', NULL),
       (311, 'ComingSoon', NULL),
       (312, 'costume', NULL),
       (313, 'face', NULL),
       (314, 'body', NULL),
       (315, 'neck', NULL),
       (324, 'magic', NULL),
       (325, 'hand', NULL),
       (326, 'bodyStaff', NULL),
       (329, 'ShopItems', NULL);
/*!40000 ALTER TABLE `Shop`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SkipWord`
--

DROP TABLE IF EXISTS `SkipWord`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SkipWord`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime     DEFAULT NULL,
    `word`    varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `word` (`word`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SkipWord`
--

LOCK TABLES `SkipWord` WRITE;
/*!40000 ALTER TABLE `SkipWord`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `SkipWord`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `StuffItem`
--

DROP TABLE IF EXISTS `StuffItem`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StuffItem`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT,
    `created`     datetime   DEFAULT NULL,
    `color`       int(11)    DEFAULT NULL,
    `level`       int(11)    DEFAULT NULL,
    `rotation`    int(11)    DEFAULT NULL,
    `type_id`     bigint(20) DEFAULT NULL,
    `used`        bit(1)     NOT NULL,
    `x`           int(11)    DEFAULT NULL,
    `y`           int(11)    DEFAULT NULL,
    `gameChar_id` bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK54003072FD1B1B2` (`type_id`),
    KEY `FK5400307B0D63236` (`gameChar_id`),
    CONSTRAINT `FK54003072FD1B1B2` FOREIGN KEY (`type_id`) REFERENCES `StuffType` (`id`),
    CONSTRAINT `FK5400307B0D63236` FOREIGN KEY (`gameChar_id`) REFERENCES `GameChar` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `StuffItem`
--

LOCK TABLES `StuffItem` WRITE;
/*!40000 ALTER TABLE `StuffItem`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `StuffItem`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `StuffType`
--

DROP TABLE IF EXISTS `StuffType`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `StuffType`
(
    `id`             bigint(20) NOT NULL AUTO_INCREMENT,
    `created`        datetime            DEFAULT NULL,
    `fileName`       varchar(255)        DEFAULT NULL,
    `giftable`       bit(1)              DEFAULT b'0',
    `groupNum`       int(2)     NOT NULL DEFAULT 0,
    `hasColor`       bit(1)              DEFAULT b'1',
    `info`           varchar(255)        DEFAULT NULL,
    `itemOfTheMonth` varchar(8)          DEFAULT NULL,
    `name`           varchar(255)        DEFAULT NULL,
    `placement`      varchar(10)         DEFAULT NULL,
    `premium`        bit(1)              DEFAULT b'0',
    `price`          int(11)    NOT NULL,
    `rainable`       bit(1)              DEFAULT b'0',
    `type`           varchar(1)          DEFAULT NULL,
    `shop_id`        bigint(20)          DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FK545172ED1946556` (`shop_id`),
    CONSTRAINT `FK545172ED1946556` FOREIGN KEY (`shop_id`) REFERENCES `Shop` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `StuffType`
--

LOCK TABLES `StuffType` WRITE;
/*!40000 ALTER TABLE `StuffType`
    DISABLE KEYS */;

INSERT INTO `StuffType` (`id`, `type`, `fileName`, `placement`, `price`, `shop_id`, `created`, `info`, `hasColor`,
                         `premium`, `giftable`, `itemOfTheMonth`, `name`, `rainable`, `groupNum`)
VALUES (1, 'C', 'bant', 'N', 150, 305, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2, 'C', 'dreads', 'H', 700, 20, NULL, '', 1, 0, 1, '', '', 0, 5),
       (3, 'C', 'frak', 'M', 100, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (4, 'C', 'hair', 'H', 1000, 20, NULL, '', 1, 0, 1, '', '', 0, 5),
       (5, 'C', 'headPhones', 'F', 1100, 305, NULL, '', 1, 1, 1, '', '', 0, 0),
       (6, 'C', 'kapci', 'B', 500, 306, NULL, '', 1, 0, 1, '', '', 0, 0),
       (7, 'C', 'kedy', 'B', 600, 306, NULL, '', 1, 0, 1, '', '', 0, 5),
       (8, 'C', 'kombi', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (9, 'C', 'korona', '', 100, 20, NULL, '', 1, 0, 1, '', '', 1, 5),
       (10, 'C', 'kravatka', 'N', 300, 305, NULL, '', 1, 0, 1, '', '', 1, 0),
       (11, 'C', 'pants', 'L', 500, 306, NULL, '', 1, 0, 1, '', '', 0, 0),
       (12, 'C', 'peruka', 'H', 600, 20, NULL, '', 1, 0, 1, '', '', 0, 0),
       (13, 'C', 'pidtjazhki', 'L', 350, 306, NULL, '', 1, 0, 1, '', '', 1, 5),
       (14, 'C', 'pidzhak', 'M', 600, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (15, 'C', 'plasch', 'N', 600, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (16, 'C', 'pypka', 'N', 600, 305, NULL, '', 1, 0, 1, '', '', 0, 0),
       (17, 'C', 'santehnik', 'ML', 700, 312, NULL, '', 1, 0, 1, '', '', 0, 5),
       (18, 'C', 'sarafan', 'LM', 750, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (19, 'C', 'shapka', '', 300, 20, NULL, 'Rare', 1, 0, 1, '', '', 0, 5),
       (20, 'C', 'vantus', '', 777, 20, NULL, '', 1, 0, 1, '', '', 1, 5),
       (21, 'C', 'viji', 'F', 300, 313, NULL, '', 1, 0, 1, '', '', 1, 5),
       (35, 'C', 'bant_1', 'N', 400, 305, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (36, 'C', 'boots', 'B', 600, 306, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (37, 'C', 'dress', 'ML', 700, 314, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 5),
       (38, 'C', 'glasses', 'F', 1000, 313, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 1, 0),
       (39, 'C', 'hat', '', 250, 20, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 5),
       (40, 'C', 'klipsi', 'F', 400, 20, '2004-11-20 08:00:00', '', 1, 1, 1, '', '', 0, 0),
       (41, 'C', 'kofta', 'M', 750, 314, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (42, 'C', 'kostium_1', 'ML', 1300, 312, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (43, 'C', 'kostium_2', 'ML', 1000, 314, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (44, 'C', 'kostium_3', 'ML', 0, 41, '2004-11-20 08:00:00', '', 1, 0, 0, '', '', 0, 0),
       (45, 'C', 'kostium_4', 'ML', 1250, 312, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (46, 'C', 'kostium_5', 'HML', 800, 312, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (47, 'C', 'kostium_6', 'HML', 30, 312, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 5),
       (48, 'C', 'kostium_7', 'ML', 850, 314, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (49, 'C', 'kovpak', '', 100, 20, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 5),
       (50, 'C', 'pachka', 'L', 5000, 306, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (51, 'C', 'peruka_1', 'H', 700, 20, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 5),
       (52, 'C', 'peruka_2', 'H', 780, 20, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (53, 'C', 'peruka_3', 'H', 160, 20, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (54, 'C', 'peruka_4', 'H', 890, 20, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 5),
       (55, 'C', 'rubaha', 'M', 10, 314, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (56, 'C', 'shoes_camomile', 'B', 700, 306, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (57, 'C', 'shoes_leaf', 'B', 800, 306, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (58, 'C', 'shoes_vuha', 'B', 500, 306, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 0),
       (59, 'C', 'topik', 'M', 400, 314, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 0, 5),
       (60, 'C', 'vinok', 'H', 500, 315, '2004-11-20 08:00:00', '', 1, 0, 1, '', '', 1, 5),
       (61, 'C', 'akademik', 'HM', 1000, 312, NULL, '', 0, 0, 1, '', '', 0, 0),
       (62, 'C', 'Cowboy', 'HMLN', 1500, 312, NULL, '', 0, 0, 1, '', '', 0, 0),
       (63, 'C', 'Faraonsha', 'HML', 850, 312, NULL, '', 0, 0, 1, '', '', 0, 0),
       (64, 'C', 'freman', 'HMLB', 1250, 312, NULL, NULL, 0, 0, 1, NULL, NULL, 0, 5),
       (65, 'C', 'japanizegirl', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (66, 'C', 'jiday', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (67, 'C', 'kleo', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (68, 'C', 'Ninja', 'HMLBNF', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (69, 'C', 'policeman', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (70, 'C', 'Samoray', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (71, 'C', 'Shahtar', 'HMB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (72, 'C', 'Studik', 'FMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (73, 'C', 'ukr', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (74, 'C', 'ukr_girl', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (75, 'C', 'wiking', 'HMLB', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (76, 'C', 'shapka_SClaus', '', 0, 304, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (77, 'C', 'sharphik_SClaus', 'N', 100, 304, NULL, '', 0, 0, 0, '', '', 0, 5),
       (78, 'C', 'shkar_SClaus', 'B', 0, 304, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (88, 'C', 'akademik', 'HM', 0, 41, NULL, '', 0, 1, 0, '', '', 0, 5),
       (89, 'C', 'Cowboy', 'HMLN', 0, 41, NULL, '', 0, 1, 0, '', '', 0, 5),
       (90, 'C', 'Faraonsha', 'HML', 0, 41, NULL, '', 0, 1, 0, '', '', 0, 5),
       (91, 'C', 'freman', 'HMLB', 0, 41, NULL, '', 0, 1, 0, '', '', 0, 5),
       (92, 'C', 'japanizegirl', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (93, 'C', 'Jiday', 'HMLB', 1000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (94, 'C', 'kleo', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (95, 'C', 'Ninja', 'HMLBNF', 1750, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (96, 'C', 'policeman', 'HMLB', 1400, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (97, 'C', 'Samoray', 'HMLB', 1200, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (98, 'C', 'Shahtar', 'HMB', 1000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (99, 'C', 'Studik', 'FMLB', 900, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (100, 'C', 'ukr', 'HMLB', 1100, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (101, 'C', 'ukr_girl', 'HMLB', 1100, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (102, 'C', 'wiking', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (175, 'C', 'okuliari_Chopix', 'F', 0, 313, NULL, 'command=LocationColorModifier;r=75;g=50;b=100', 0, 0, 1, '',
        '', 0, 5),
       (176, 'C', 'mask_begemot', 'F', 700, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (177, 'C', 'mask_cat', 'F', 5000, 19, NULL, '', 0, 0, 1, '', '', 1, 5),
       (178, 'C', 'mask_elephant', 'F', 800, 19, NULL, '', 0, 0, 1, '', '', 0, 0),
       (179, 'C', 'mask_lion', 'F', 5000, 19, NULL, '', 0, 1, 1, '', '', 1, 0),
       (180, 'C', 'mask_panda', 'F', 900, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (181, 'C', 'mask_pingvin', 'F', 10000, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (182, 'C', 'mask_popugay', 'F', 700, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (183, 'C', 'mask_zaiaz', 'F', 1100, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (184, 'C', 'mask_zebra', 'F', 800, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (185, 'C', 'board', 'X', 5000, 15, NULL, 'command=StuffCharModifier;modifier=FlyModifier;speed=17;height=12', 0,
        0, 0, '', 'Flame Shoes', 0, 5),
       (186, 'C', 'cheerleader_girl', 'HMLB', 1100, 312, NULL, '', 1, 1, 1, '', '', 0, 5),
       (187, 'C', 'cinderella', 'BLMHFN', 1300, 312, NULL, '', 1, 1, 1, '', '', 0, 5),
       (188, 'C', 'violet_hair_girl', 'HMLB', 950, 312, NULL, '', 1, 1, 1, '', '', 0, 0),
       (189, 'C', 'blue_hair_girl', 'HMLB', 1100, 312, NULL, '', 1, 1, 1, '', '', 0, 5),
       (190, 'C', 'red_hair_girl', 'HMLB', 0, 41, NULL, '', 1, 1, 0, '', '', 0, 5),
       (191, 'C', 'diver', 'BLMHFN', 1000, 312, NULL, '', 1, 1, 1, '', '', 0, 5),
       (192, 'C', 'Sleepy', 'BLMHFN', 950, 312, NULL, '', 1, 1, 1, '', 'Sleepy', 0, 5),
       (193, 'C', 'roman', 'HMLB', 0, 41, NULL, '', 0, 1, 0, '', '', 0, 5),
       (194, 'C', 'sport_girl', 'HMLB', 0, 41, NULL, '', 1, 1, 0, '', '', 0, 5),
       (195, 'C', 'red_hat_girl', 'HMLB', 1000, 312, NULL, '', 1, 1, 1, '', '', 0, 0),
       (196, 'C', 'PG_girl_1', 'M', 300, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (197, 'C', 'PG_girl_2', 'M', 350, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (198, 'C', 'futbolka_heard', 'M', 900, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (199, 'C', 'sport_girl', 'HMLB', 1100, 312, NULL, '', 1, 0, 1, '', 'Tomboy', 0, 0),
       (200, 'C', 'roman', 'HMLB', 1000, 312, NULL, '', 0, 0, 1, '', '', 0, 0),
       (201, 'C', 'Sleepy', 'BLMHFN', 0, 41, NULL, '', 1, 0, 0, '', '', 0, 5),
       (202, 'C', 'cheerleader_girl', 'HMLB', 0, 41, NULL, '', 1, 0, 0, '', '', 0, 5),
       (204, 'C', 'violet_hair_girl', 'HMLB', 0, 41, NULL, '', 1, 0, 0, '', '', 0, 5),
       (205, 'C', 'red_hair_girl', 'HMLB', 0, 41, NULL, '', 1, 0, 0, '', '', 0, 5),
       (206, 'C', 'red_hair_girl', 'HMLB', 1300, 312, NULL, '', 1, 0, 1, '', '', 0, 0),
       (210, 'C', 'fly_air_complect', 'FLBX', 1000, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=4;height=18', 0, 1, 1, '', '', 0, 0),
       (211, 'C', 'fly_air_glass', 'F', 4500, 15, NULL, '', 0, 1, 1, '', '', 0, 5),
       (212, 'C', 'fly_air_poyas', 'L', 3500, 15, NULL, '', 0, 1, 1, '', '', 0, 5),
       (213, 'C', 'fly_air_shoes', 'X', 5500, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=4;height=18', 0, 0, 1, '', 'a', 0, 0),
       (214, 'C', 'fly_fire_complect', 'FHBX', 7500, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=5;height=18', 0, 1, 1, '', '', 0, 0),
       (215, 'C', 'fly_fire_kaska', 'H', 2000, 15, NULL, '', 0, 1, 1, '', '', 0, 0),
       (216, 'C', 'fly_fire_ruka', 'M', 1500, 15, NULL, '', 0, 1, 1, '', '', 0, 0),
       (217, 'C', 'fly_fire_shoes', 'XB', 4500, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=5;height=18', 0, 1, 1, '', '', 0, 0),
       (218, 'C', 'fly_magnet_shoes', 'XB', 4550, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=6;height=20', 0, 1, 0, '', '', 0, 5),
       (219, 'C', 'mask_begemot_blue', 'F', 700, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (220, 'C', 'mask_begemot_pink', 'F', 700, 19, NULL, '', 0, 0, 1, '', '', 0, 0),
       (221, 'C', 'mask_cat_blue', 'F', 700, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (222, 'C', 'mask_cat_yelow', 'F', 700, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (223, 'C', 'mask_elephant_pink', 'F', 800, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (224, 'C', 'mask_elephant_violet', 'F', 800, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (225, 'C', 'mask_lion_gray', 'F', 400, 19, NULL, '', 0, 0, 1, '', '', 0, 0),
       (226, 'C', 'mask_pingvin_blue', 'F', 1000, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (227, 'C', 'mask_popugay_blue', 'F', 700, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (228, 'C', 'mask_popugay_yelow', 'F', 700, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (229, 'C', 'mask_zaiaz_blue', 'F', 900, 19, NULL, '', 0, 0, 1, '', '', 0, 0),
       (230, 'C', 'mask_zaiaz_pink', 'F', 200, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (231, 'C', 'patrik_dress', 'M', 650, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (232, 'C', 'patrik_girl_complect', 'BMH', 800, 312, NULL, '', 0, 0, 1, '', '', 0, 5),
       (233, 'C', 'patrik_girl_shoes', 'B', 300, 306, NULL, '', 0, 0, 1, '', '', 0, 5),
       (234, 'C', 'patrik_glass', 'F', 444, 313, NULL, 'command=LocationColorModifier;r=80;g=100;b=20', 0, 0, 1, '', '',
        0, 5),
       (235, 'C', 'patrik_hat', 'H', 109, 20, NULL, '', 0, 0, 1, '', '', 0, 5),
       (236, 'C', 'patrik_jacket', 'M', 777, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (237, 'C', 'patrik_peruka', 'H', 260, 20, NULL, '', 0, 0, 1, '', '', 0, 5),
       (238, 'C', 'patrik_shirt_boy', 'M', 600, 314, NULL, '', 0, 1, 1, '', '', 0, 5),
       (239, 'C', 'patrik_shoes', 'B', 205, 306, NULL, '', 0, 0, 1, '', '', 0, 5),
       (240, 'C', 'patrik_shoes2', 'B', 320, 306, NULL, '', 0, 0, 1, '', '', 0, 5),
       (241, 'C', 'patrik_suit1', 'BMH', 777, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (242, 'C', 'patrik_suit2', 'BMF', 777, 312, NULL, 'command=LocationColorModifier;r=80;g=100;b=20', 0, 0, 1, '',
        '', 0, 5),
       (244, 'C', 'fire_wings', '&', 0, 41, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (245, 'C', 'khaki', 'BLMH', 5280, 312, NULL, 'Rare', 0, 1, 0, '', '', 0, 5),
       (246, 'C', 'pirat', 'MNH', 0, 312, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (247, 'C', 'cheburashka', 'F', 500, 20, NULL, 'Rare', 1, 0, 0, '', '', 0, 5),
       (248, 'C', 'glasses_1', 'F', 1500, 313, NULL, '', 1, 1, 1, '', '', 0, 0),
       (249, 'C', 'glasses_big', 'F', 1100, 313, NULL, '', 1, 0, 1, '', '', 0, 0),
       (250, 'C', 'glasses_black', 'F', 2000, 313, NULL, '', 0, 0, 1, '', '', 0, 0),
       (251, 'C', 'glasses_heart', 'F', 1000, 313, NULL, '', 1, 1, 1, '', '', 0, 5),
       (252, 'C', 'glasses_nose', 'F', 1500, 313, NULL, '', 1, 1, 1, '', '', 0, 0),
       (253, 'C', 'glasses_round', 'F', 1000, 313, NULL, '', 1, 1, 1, '', '', 0, 0),
       (254, 'C', 'glasses_stars', 'F', 2000, 313, NULL, '', 1, 1, 1, '', '', 0, 0),
       (255, 'C', 'glasses_techno', 'F', 1250, 313, NULL, '', 1, 1, 1, '', '', 0, 5),
       (256, 'C', 'head_bear', 'H', 800, 20, NULL, 'Rare', 1, 0, 1, '', '', 0, 5),
       (257, 'C', 'korona_brulik', '', 1000, 20, NULL, '', 0, 0, 1, '', '', 0, 5),
       (258, 'C', 'lampochka', 'H', 1600, 20, NULL, '', 0, 1, 0, '', '', 0, 0),
       (259, 'C', 'nimb', '', 1000, 20, NULL, '', 0, 1, 1, '', '', 0, 5),
       (260, 'C', 'wings', 'N', 2000, 15, NULL, '', 0, 1, 1, '', '', 0, 5),
       (261, 'C', 'akademik_blue', 'HM', 1000, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (262, 'C', 'akademik_red', 'HM', 500, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (263, 'C', 'Cowboy_blue', 'HMLN', 1500, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (264, 'C', 'Cowboy_red', 'HMLN', 1500, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (265, 'C', 'Faraonsha_blue', 'HML', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (266, 'C', 'freman_blue', 'HMLB', 50, 312, NULL, 'Rare', 0, 1, 0, '', '', 0, 5),
       (267, 'C', 'freman_red', 'HMLB', 1250, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (268, 'C', 'japanizegirl_blue', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (269, 'C', 'japanizegirl_red', 'HMLB', 850, 312, NULL, 'Rare', 0, 1, 0, '', '', 0, 5),
       (270, 'C', 'Jiday_blue', 'HMLB', 1000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (271, 'C', 'Jiday_red', 'HMLB', 1000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (272, 'C', 'kleo_blue', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (273, 'C', 'kleo_red', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (276, 'C', 'Ninja_blue', 'HMLBNF', 1750, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (277, 'C', 'Ninja_red', 'HMLBNF', 1750, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (278, 'C', 'policeman_blue', 'HMLB', 1400, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (279, 'C', 'policeman_red', 'HMLB', 1400, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (280, 'C', 'Samoray_blue', 'HMLB', 1200, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (281, 'C', 'Samoray_red', 'HMLB', 1200, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (282, 'C', 'Studik_blue', 'FMLB', 900, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (283, 'C', 'Studik_red', 'FMLB', 900, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (284, 'C', 'waysarbi', 'HMB', 0, 41, NULL, '', 1, 1, 0, '', '', 0, 5),
       (285, 'C', 'wiking_blue', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (286, 'C', 'wiking_red', 'HMLB', 850, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (287, 'C', 'hair_5', 'H', 1200, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (288, 'C', 'hair_care', 'H', 900, 20, NULL, '', 1, 0, 1, '', '', 0, 5),
       (289, 'C', 'hair_cheerleader', 'H', 800, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (290, 'C', 'hair_emo', 'H', 1200, 20, NULL, '', 1, 0, 1, '', '', 0, 0),
       (291, 'C', 'hair_jedy', 'H', 700, 20, NULL, '', 1, 0, 1, '', '', 0, 5),
       (292, 'C', 'hair_kosy', 'H', 800, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (293, 'C', 'peruka_80s', 'H', 1000, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (294, 'C', 'peruka_emo1', 'H', 1400, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (295, 'C', 'peruka_emo2', 'H', 1300, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (296, 'C', 'peruka_emo3', 'H', 1100, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (297, 'C', 'peruka_emo4', 'H', 1000, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (298, 'C', 'peruka_green_hat', 'H', 1000, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (299, 'C', 'peruka_jamaika', 'H', 1500, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (300, 'C', 'peruka_scarry', 'H', 650, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (301, 'C', 'beads', 'N', 400, 305, NULL, '', 1, 1, 1, '', '', 0, 0),
       (302, 'C', 'jabo', 'N', 400, 315, NULL, '', 1, 0, 1, '', '', 1, 5),
       (303, 'C', 'shtani', 'L', 500, 306, NULL, '', 1, 0, 1, '', '', 0, 0),
       (304, 'C', 'shtani_romashki', 'L', 750, 306, NULL, '', 1, 1, 1, '', '', 0, 5),
       (305, 'C', 'pants1', 'L', 600, 306, NULL, '', 1, 0, 1, '', '', 0, 0),
       (306, 'C', 'pants2', 'L', 800, 306, NULL, '', 1, 1, 1, '', '', 0, 5),
       (307, 'C', 'pants3', 'L', 600, 306, NULL, '', 1, 1, 1, '', '', 0, 0),
       (308, 'C', 'pants4', 'L', 700, 306, NULL, '', 1, 1, 1, '', '', 0, 0),
       (309, 'C', 'pants5', 'L', 900, 306, NULL, '', 0, 0, 1, '', '', 0, 0),
       (310, 'C', 'pants_square', 'L', 750, 306, NULL, '', 1, 1, 1, '', '', 0, 0),
       (311, 'C', 'shoes_1', 'B', 1000, 306, NULL, '', 1, 1, 1, '', '', 0, 0),
       (312, 'C', 'shoes_2', 'B', 800, 306, NULL, '', 0, 1, 1, '', '', 0, 5),
       (313, 'C', 'shoes_drMartens', 'B', 1000, 306, NULL, '', 1, 1, 1, '', '', 0, 0),
       (314, 'C', 'futbolka_smyle', 'M', 1200, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (315, 'C', 'gerb_jacket', 'M', 1100, 314, NULL, '', 1, 1, 1, '', '', 0, 0),
       (316, 'C', 'kurtka', 'M', 700, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (317, 'C', 'PG_boy_1', 'M', 300, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (318, 'C', 'PG_boy_2', 'M', 350, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (319, 'C', 'shirt_arrow', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (320, 'C', 'shirt_cup', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 1, 5),
       (321, 'C', 'shirt_dialog', 'M', 20, 314, NULL, '', 1, 0, 1, '', '', 1, 5),
       (322, 'C', 'shirt_oklyk', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 1, 5),
       (323, 'C', 'shirt_pet', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 1, 0),
       (324, 'C', 'shirt_phone', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (325, 'C', 'shirt_question', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (326, 'C', 'shirt_tunes', 'M', 900, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (327, 'C', 'shirt_work', 'M', 30, 314, NULL, '', 1, 0, 1, '', '', 1, 5),
       (328, 'C', 'futbolka_emo1', 'M', 650, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (329, 'C', 'futbolka_mickey_mouse', 'M', 1000, 314, NULL, '', 1, 1, 1, '', '', 0, 0),
       (330, 'C', 'jacket_1', 'M', 1300, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (331, 'C', 'jacket_emo1', 'M', 1400, 314, NULL, '', 1, 1, 1, '', '', 0, 0),
       (332, 'C', 'kostum_sharfik', 'M', 900, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (333, 'C', 'moon_jacket', 'M', 1200, 314, NULL, '', 1, 1, 1, '', '', 0, 0),
       (334, 'C', 'rubaha_hawai', 'M', 3000, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (335, 'C', 'svetr_zelenuy', 'M', 1200, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (336, 'C', 'boots2', 'B', 800, 306, NULL, '', 1, 1, 1, '', '', 0, 5),
       (337, 'C', 'dress_2', 'M', 900, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (338, 'C', 'green_hat', 'H', 1850, 20, NULL, '', 1, 0, 1, '', 'Green hat', 0, 0),
       (339, 'C', 'peruka_5', 'H', 750, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (340, 'C', 'peruka_emo5', 'H', 3000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (341, 'C', 'waysarbi', 'HMB', 5000, 312, NULL, 'Rained 1/14/12', 1, 0, 1, '', '', 0, 5),
       (342, 'C', 'glasses_professor', 'F', 0, 313, NULL, '', 0, 0, 1, '', '', 0, 5),
       (344, 'C', 'air_board1', 'X', 6000, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=6;height=10', 1, 0, 1, '', '', 0, 0),
       (345, 'C', 'air_board2', 'X', 7500, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=6;height=10', 1, 1, 1, '', '', 0, 0),
       (346, 'C', 'air_board3', 'X', 6300, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=7;height=10', 1, 1, 1, '', '', 0, 0),
       (347, 'C', 'peruka_anime1', 'H', 3000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (348, 'C', 'peruka_anime2', 'H', 1100, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (349, 'C', 'peruka_anime3', 'H', 900, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (350, 'C', 'peruka_anime4', 'H', 1250, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (351, 'C', 'peruka_dragon1', 'H', 3000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (352, 'C', 'peruka_dragon2', 'H', 3000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (353, 'C', 'peruka_dragon3', 'H', 1000, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (354, 'C', 'laurel', '', 0, 20, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (355, 'C', 'medal_bant', 'N', 0, 315, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (356, 'C', 'medal_bronze', 'N', 0, 315, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (357, 'C', 'medal_classic', 'N', 0, 315, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (358, 'C', 'medal_gold', 'N', 0, 315, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (359, 'C', 'medal_silver', 'N', 0, 315, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (360, 'C', 'Ghost', 'LM', 0, 312, NULL, '', 0, 0, 0, '', 'Ghost suit', 0, 5),
       (361, 'C', 'propellerheads', '', 0, 20, NULL, 'command=StuffCharModifier;modifier=FlyModifier;speed=9;height=10',
        0, 1, 1, '', 'Propeller Hat', 0, 5),
       (362, 'C', 'superchobot', 'MLBN', 0, 329, NULL, '', 0, 0, 0, '', '', 0, 0),
       (363, 'C', 'mimo_1', 'MLNH', 5000, 314, NULL, 'Mimo costume', 0, 0, 1, '', '', 0, 0),
       (364, 'C', 'mimo_2', 'MLNH', 0, 312, NULL, 'Mimo costume 2', 0, 0, 1, '', '', 0, 5),
       (365, 'C', 'Basia', 'MLBNHF', 0, 312, NULL, 'Rare Basia costume', 0, 0, 0, '', '', 0, 5),
       (366, 'C', 'mummy', 'MLBNHF', 0, 41, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (367, 'C', 'shirt_bboy', 'M', 600, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (368, 'C', 'shirt_chlos', 'M', 1200, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (379, 'C', 'hair', 'H', 1000, 20, '2009-04-23 14:25:53', '', 1, 1, 1, '', '', 0, 5),
       (380, 'C', 'hat', '0', 250, 20, '2009-04-23 14:25:53', '', 1, 0, 1, '', '', 0, 5),
       (381, 'C', 'korona_brulik', '', 1000, 20, '2009-04-23 14:25:53', '', 0, 0, 1, '', '', 0, 5),
       (382, 'C', 'kostium_3', 'ML', 500, 312, '2009-04-23 14:25:53', '', 1, 1, 1, '', '', 0, 0),
       (383, 'C', 'patrik_hat', '+', 659, 20, '2009-04-23 14:25:53', '', 0, 1, 1, '', '', 0, 5),
       (384, 'C', 'plasch', 'N', 50, 314, '2009-04-23 14:25:53', '', 1, 1, 1, '', '', 1, 5),
       (385, 'C', 'shoes_camomile', 'B', 700, 306, '2009-04-23 14:25:53', '', 1, 1, 1, '', '', 0, 5),
       (386, 'C', 'shoes_leaf', 'B', 800, 306, '2009-04-23 14:25:53', '', 1, 1, 1, '', '', 0, 1),
       (387, 'C', 'shoes_vuha', 'B', 900, 306, '2009-04-23 14:25:53', '', 1, 1, 1, '', '', 0, 5),
       (388, 'C', 'vantus', 'H', 777, 20, '2009-04-23 14:25:53', '', 1, 0, 1, '', '', 0, 5),
       (390, 'C', 'air_board4', 'X', 5500, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=5;height=10', 1, 1, 1, '', '', 0, 5),
       (391, 'C', 'air_board5', 'X', 5400, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=5;height=10', 1, 1, 1, '', '', 0, 0),
       (392, 'C', 'air_board6', 'X', 7800, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=7;height=10', 1, 1, 1, '', '', 0, 0),
       (393, 'C', 'air_board7', 'X', 8000, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 1, 1, 1, '', '', 0, 0),
       (394, 'C', 'air_board8', 'X', 7500, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=7;height=10', 1, 1, 1, '', '', 0, 5),
       (395, 'C', 'air_board9', 'X', 8000, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=8;height=10', 1, 1, 1, '', '', 0, 5),
       (397, 'C', 'air_board10', 'X', 7500, 15, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=7;height=10', 1, 1, 1, '', '', 0, 5),
       (398, 'C', 'Cleaner_pylesos', 'M', 0, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (399, 'C', 'Cleaner_kaska', 'H', 0, 20, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (400, 'C', 'Cleaner_shoes', 'BX', 0, 306, NULL, '', 0, 0, 1, '', '', 0, 5),
       (401, 'C', 'instrument_drum', 'I', 7300, 24, NULL, 'command=MusicInstrument;name=drum', 1, 0, 1, '', '', 0, 0),
       (402, 'C', 'instrument_guitar_classic', 'I', 6000, 24, NULL, 'command=MusicInstrument;name=pista', 1, 1, 1, '',
        '', 0, 5),
       (403, 'C', 'instrument_guitar_rock', 'I', 8000, 24, NULL, 'command=MusicInstrument;name=solo', 1, 1, 1, '', '',
        0, 0),
       (404, 'C', 'instrument_sax', 'I', 8000, 24, NULL, 'command=MusicInstrument;name=sax', 1, 1, 1, '', '', 0, 5),
       (405, 'C', 'instrument_vinyl', 'I', 7500, 24, NULL, 'command=MusicInstrument;name=hiphop', 1, 1, 1, '', '', 0,
        5),
       (406, 'C', 'scorpio', 'MLBNHF', 2500, 25, NULL, '', 0, 1, 0, '2012712', 'Golden Ninja!', 0, 5),
       (407, 'C', 'vayerman', 'MLBNHF', 5000, 329, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (408, 'C', 'flag', '#', 0, 305, NULL, 'flag_logo1', 1, 0, 1, '', '', 0, 5),
       (409, 'C', 'mummy', 'MLBNF', 10000, 312, NULL, '', 0, 1, 0, '', '', 0, 5),
       (412, 'C', 'pirat', 'MNH', 0, 329, NULL, '', 0, 0, 0, '', 'Pirate Suit', 0, 0),
       (414, 'C', 'fire_wings', '&', 0, 41, NULL, '', 0, 1, 0, '', 'Flame Wings!', 0, 5),
       (415, 'C', 'futbolka_10', 'M', 700, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (416, 'C', 'futbolka_20', 'M', 1000, 314, NULL, '', 0, 0, 0, '', '', 0, 5),
       (417, 'C', 'futbolka_30', 'M', 1000, 314, NULL, '', 0, 0, 0, '', '', 0, 5),
       (418, 'C', 'shirt_bgirl', 'M', 1000, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (419, 'C', 'shirt_ggirl', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (420, 'C', 'shirt_iou', 'M', 50, 314, NULL, '', 1, 0, 1, '', '', 1, 5),
       (421, 'C', 'shirt_love', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (422, 'C', 'shirt_peace', 'M', 100, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (423, 'C', 'shirt_unity', 'M', 1, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (427, 'C', 'instrument_bayan', 'I', 9000, 24, NULL, 'command=MusicInstrument;name=bajan', 1, 1, 1, '', '', 0, 5),
       (428, 'C', 'instrument_guitar_bass', 'I', 7000, 24, NULL, 'command=MusicInstrument;name=bass', 1, 1, 1, '', '',
        0, 5),
       (429, 'C', 'instrument_marakas', 'I', 7500, 24, NULL, 'command=MusicInstrument;name=shakers', 1, 1, 1, '', '', 0,
        0),
       (430, 'C', 'instrument_tam_tam', 'I', 6500, 24, NULL, 'command=MusicInstrument;name=afrik', 1, 1, 1, '', '', 0,
        0),
       (431, 'C', 'instrument_truba', 'I', 8000, 24, NULL, 'command=MusicInstrument;name=truba', 1, 0, 1, '', '', 0, 0),
       (432, 'C', 'glasses_50s', 'F', 1000, 313, NULL, '', 1, 0, 1, '', '', 0, 0),
       (433, 'C', 'glasses_cop', 'F', 2000, 313, NULL, '', 0, 1, 1, '', '', 0, 0),
       (434, 'C', 'glasses_monroe', 'F', 1500, 313, NULL, '', 1, 1, 1, '', '', 0, 0),
       (435, 'C', 'mask_nichos', 'HF', 500, 19, NULL, '', 0, 1, 0, '', '', 0, 5),
       (436, 'C', 'glasses_umnik', 'F', 1300, 313, NULL, 'command=StuffCharModifier;modifier=BigHeadModifier', 0, 1, 1,
        '', '', 0, 0),
       (437, 'C', 'zhurdai', 'M', 1000, 315, NULL, 'command=StuffCharModifier;modifier=SmallHeadModifier;', 0, 1, 1, '',
        '', 0, 5),
       (438, 'C', 'spaceman', 'HMLBN', 3000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (439, 'C', 'indian', 'ML', 0, 329, NULL, '', 0, 0, 0, '', '', 0, 0),
       (440, 'C', 'knight', 'BL', 5000, 312, NULL, 'Rare', 1, 1, 0, '', '', 0, 5),
       (441, 'C', 'kostum_dracon', 'ML', 10000, 312, NULL, 'Rare', 1, 1, 0, '', '', 0, 5),
       (442, 'C', 'kostum_third_eye', 'ML', 0, 312, NULL, 'Rare', 1, 1, 0, '', '', 0, 5),
       (443, 'C', 'strongman', 'ML', 10000, 312, NULL, 'Rare', 0, 1, 0, '', '', 0, 5),
       (446, 'C', '_empty', 'HMLBN', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (447, 'C', 'dress_3', 'M', 1100, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (448, 'C', 'dress_4', 'M', 1150, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (449, 'C', 'futbolka_c', 'M', 1800, 314, NULL, '', 1, 1, 1, '', '', 0, 0),
       (450, 'C', 'futbolka_girl1', 'M', 800, 314, NULL, '', 1, 0, 1, '', '', 0, 5),
       (451, 'C', 'head_shake', 'F', 2250, 313, NULL, '', 0, 0, 1, '', '', 0, 5),
       (452, 'C', 'latino_nakydka', 'M', 1200, 314, NULL, '', 0, 1, 1, '', '', 0, 0),
       (453, 'C', 'mask_ant', 'F', 10000, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (454, 'C', 'mask_bee', 'F', 910, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (455, 'C', 'mask_bogomol', 'F', 1000, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (456, 'C', 'pants_girl_1', 'L', 650, 306, NULL, '', 1, 0, 1, '', '', 0, 0),
       (457, 'C', 'peruka_6', 'H', 2000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (458, 'C', 'peruka_7', 'H', 990, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (459, 'C', 'peruka_8', 'H', 1050, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (460, 'C', 'peruka_9', 'H', 1850, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (461, 'C', 'sailor_girl', 'M', 1150, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (462, 'C', 'sandali', 'B', 1000, 306, NULL, '', 1, 1, 1, '', '', 0, 0),
       (463, 'C', 'sombrero', '', 870, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (464, 'C', 'adam', 'M', 0, 326, NULL, 'Adam', 0, 0, 0, '', '', 0, 5),
       (466, 'C', '_empty', 'HMLBN', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (467, 'C', 'futbolka_500', 'M', 10, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (469, 'C', 'fire_wings', '&', 2500, 25, NULL, '', 0, 1, 0, '2012096', 'Flame Wings!', 0, 5),
       (471, 'C', 'futbolka_b-day', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 1, 5),
       (472, 'C', 'futbolka_HIKI', 'M', 0, 326, NULL, 'Hikikomori', 1, 0, 0, '', '', 0, 5),
       (473, 'C', 'flag_usa', '#', 1000, 305, NULL, 'American Flag', 0, 0, 1, '', 'American Flag', 0, 5),
       (474, 'C', 'cylinder', '', 1000, 20, NULL, '', 0, 1, 1, '', '', 0, 5),
       (482, 'C', 'fire_wings', '&', 0, 41, NULL, '', 0, 1, 0, '', 'Flame Wings!', 0, 5),
       (483, 'C', 'carrot', '&', 0, 315, NULL, '', 0, 0, 1, '', 'Carrot Bag', 0, 5),
       (484, 'C', 'bones', 'MLBN', 50000, 312, NULL, '', 0, 1, 0, '', 'Skeleton!', 0, 0),
       (485, 'C', 'butterfly', '&', 80000, 305, NULL, '', 1, 0, 0, '', '', 0, 5),
       (486, 'C', 'china_dragon_mask', 'H', 2500, 25, NULL, '', 0, 1, 0, '20120912', 'Dragon Mask', 0, 5),
       (487, 'C', 'cook', 'MH', 1400, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (488, 'C', 'hat_china', 'H', 750, 20, NULL, '', 0, 1, 1, '', '', 0, 5),
       (489, 'C', 'hat_indian', 'H', 950, 20, NULL, '', 1, 1, 0, '', '', 0, 5),
       (490, 'C', 'hat_turkish', '', 1000, 20, NULL, '', 0, 0, 1, '', '', 0, 0),
       (491, 'C', 'kostum_indian_boy', 'MLB', 3000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (492, 'C', 'kostum_indian_girl', 'M', 3000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (493, 'C', 'peruka_indian', 'H', 500, 20, NULL, '', 0, 1, 1, '', '', 0, 0),
       (500, 'C', 'brush', 'I', 0, 305, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (501, 'C', 'wellgames', 'M', 1000, 314, NULL, 'Wellgames', 0, 0, 0, '', '', 0, 5),
       (502, 'C', 'chrisdog', 'M', 0, 326, NULL, 'Chrisdog', 0, 0, 0, '', '', 0, 5),
       (503, 'C', 'flag_mimo_logo', '#', 1000, 305, NULL, '', 0, 1, 1, '', 'Mimo Flag!', 0, 5),
       (504, 'C', 'futbolka_mimo', 'M', 0, 326, NULL, 'Mimo', 0, 0, 0, '', '', 0, 5),
       (505, 'C', 'zorro', 'MLBNHF', 1350, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (506, 'C', 'papuas', 'MLBNHF', 5000, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (507, 'C', 'eskimos', 'MLBNH', 1250, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (508, 'C', 'dress_5', 'M', 1200, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (509, 'C', 'english_guardian', 'MLBNHF', 1800, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (510, 'C', 'hat_paper', '', 600, 20, NULL, '', 0, 1, 1, '', '', 0, 5),
       (511, 'C', 'kostium_8', 'M', 950, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (512, 'C', 'peruka_10', 'H', 800, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (513, 'C', 'peruka_11', 'H', 3000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (514, 'C', 'sansey', 'MLBNHF', 1800, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (515, 'C', 'video_camera', 'I', 0, 305, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (516, 'C', 'banana', '&', 4000, 305, NULL, '', 0, 1, 1, '', '', 0, 0),
       (517, 'C', 'basketbollist', 'ML', 3000, 314, NULL, '', 1, 1, 1, '', '', 0, 0),
       (518, 'C', 'corn', '&', 4000, 305, NULL, '', 0, 1, 1, '', '', 0, 5),
       (519, 'C', 'flag_chobots', '#', 999, 305, NULL, '', 1, 0, 1, '', '', 0, 5),
       (520, 'C', 'ice_wings', '&', 1000, 15, NULL, '', 0, 0, 0, '', 'Ice Wings!', 0, 5),
       (521, 'C', 'mask_alien', 'F', 800, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (522, 'C', 'Niceplayer', 'M', 0, 326, NULL, 'Niceplayer', 0, 0, 0, '', '', 0, 5),
       (523, 'C', 'strawberries', '&', 3000, 305, NULL, '', 0, 1, 1, '', 'Backpack', 0, 5),
       (529, 'C', 'golden_wings', '&', 4000, 305, NULL, '', 0, 1, 1, '', '', 0, 0),
       (530, 'C', 'flag', '#', 0, 41, NULL, '', 1, 0, 0, '', '', 0, 0),
       (531, 'C', 'flag_agent', '#', 5000, 32, NULL, '', 1, 0, 0, '', 'Agent Flag', 0, 0),
       (532, 'C', 'flag_heart', '#', 2500, 305, NULL, '', 1, 1, 1, '', '', 0, 5),
       (533, 'C', 'flag_smile', '#', 500, 305, NULL, 'Rare', 1, 1, 1, '', '', 0, 0),
       (534, 'C', 'flag_sun', '#', 50000, 305, NULL, '', 1, 0, 1, '', '', 0, 5),
       (535, 'C', 'futbolka_999', 'M', 10, 314, NULL, 'Rare', 1, 0, 1, '', '', 0, 5),
       (536, 'C', 'jet_pack', '&X', 0, 329, NULL, 'command=StuffCharModifier;modifier=FlyModifier;speed=10;height=25',
        0, 0, 0, '', 'Jet Pack 1', 0, 0),
       (537, 'C', 'jet_pack2', '&X', 0, 15, NULL, 'command=StuffCharModifier;modifier=FlyModifier;speed=22;height=21',
        0, 0, 0, '', 'Jet Pack', 0, 5),
       (538, 'C', 'fiuchobot', 'MLBNH', 950, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (539, 'C', 'pumpkin_mask', 'FH', 5000, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (540, 'C', 'pumpkin_head', 'MBNF', 5000, 312, NULL, '', 0, 0, 1, '', 'Pumpkin!', 0, 5),
       (541, 'C', 'witch', 'MNH', 5000, 312, NULL, '', 0, 0, 1, '', '', 0, 5),
       (542, 'C', 'umbrella', '#', 25, 305, NULL, '', 0, 0, 1, '', '', 0, 5),
       (543, 'C', 'futbolka_pie', 'M', 1000, 314, NULL, 'Rare--for contests only', 1, 0, 1, '', '', 0, 5),
       (544, 'C', 'vampire', 'F', 2500, 31, NULL, '', 0, 0, 1, '', 'Dracula!', 0, 5),
       (545, 'C', 'plasch_vampire', 'N', 850, 315, NULL, '', 0, 0, 1, '', '', 0, 5),
       (547, 'C', 'futbolka_1year', 'M', 1000, 314, NULL, 'Rare', 1, 0, 1, '', '', 0, 5),
       (548, 'C', 'bones', 'MLBN', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (549, 'C', 'futbolka_no_lag', 'M', 100, 314, NULL, '', 0, 0, 1, '', '', 1, 5),
       (550, 'C', 'flag_StGeorges', '#', 1000, 305, NULL, 'English Flag', 0, 0, 1, '', 'English Flag', 0, 5),
       (551, 'C', 'flag_deutsche', '#', 1000, 305, NULL, 'German Flag', 0, 0, 1, '', 'German Flag', 0, 5),
       (552, 'C', 'candy', '&', 2000, 305, NULL, '', 0, 0, 1, '', '', 0, 5),
       (553, 'C', 'cavegirl', 'MBH', 5000, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (554, 'C', 'caveman', 'MBH', 5000, 312, NULL, '', 0, 1, 1, '', '', 0, 0),
       (555, 'C', 'dress_6', 'M', 800, 314, NULL, '', 1, 1, 1, '', '', 0, 5),
       (556, 'C', 'fairy', 'MBHL', 4666, 312, NULL, '', 0, 1, 0, '', '', 0, 5),
       (557, 'C', 'ice_cream', '&', 800, 305, NULL, '', 0, 1, 1, '', '', 0, 5),
       (558, 'C', 'peruka_12', 'H', 1000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (559, 'C', 'peruka_13', 'H', 1000, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (560, 'C', 'suit_for_fly', 'MBLF', 200000, 312, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=20;height=35', 1, 0, 0, '', '', 0, 0),
       (561, 'C', 'terrapin', 'M', 100000, 305, NULL, '', 1, 0, 0, '', '', 0, 0),
       (562, 'C', 'futbolka_s', 'M', 0, 326, NULL, 'Smurfet', 0, 0, 0, '', '', 0, 5),
       (565, 'C', 'mask_dog', 'F', 0, 19, NULL, 'Rare', 0, 1, 0, '', 'Dog Mask!', 0, 5),
       (566, 'C', 'firework', '&', 750, 305, NULL, '', 0, 0, 1, '', '', 0, 0),
       (567, 'C', 'tnt', '&', 900, 315, NULL, '', 0, 1, 1, '', '', 0, 0),
       (568, 'C', 'paa', 'MLBNF', 1000, 312, NULL, 'Rare', 0, 0, 0, '', '', 0, 5),
       (569, 'C', 'futbolka_jessie', 'M', 0, 326, NULL, 'Jessie2000', 0, 0, 0, '', '', 0, 5),
       (570, 'C', 'turkey_suit', 'MLBNF', 5000, 312, NULL, '', 0, 1, 1, '', '', 0, 5),
       (571, 'C', 'deer', '', 800, 20, NULL, '', 0, 0, 1, '', '', 0, 5),
       (572, 'C', 'deer_head', 'H', 0, 304, NULL, '', 0, 1, 1, '', 'Rudolph', 0, 5),
       (573, 'C', 'present_bag', '&', 0, 304, NULL, '', 0, 0, 0, '', '', 0, 5),
       (574, 'C', 'present_box', '&', 0, 304, NULL, '', 0, 0, 0, '', 'Present Bag!', 0, 5),
       (575, 'C', 'present_sock', '&', 800, 304, NULL, '', 0, 1, 0, '', '', 0, 5),
       (576, 'C', 'santa', 'HML', 2500, 304, NULL, '', 0, 1, 0, '2011121', 'Santa', 0, 5),
       (577, 'C', 'snowgirl', 'MLBNHF', 870, 304, NULL, '', 0, 1, 0, '', '', 0, 5),
       (578, 'C', 'snowman', 'MLBNHF', 0, 304, NULL, '', 0, 1, 0, '', 'Snowman', 0, 5),
       (579, 'C', 'xmas_tree', 'MLNHF', 1200, 304, NULL, '', 0, 1, 0, '', '', 0, 5),
       (580, 'M', 'coins3', '', 0, 305, NULL, '', 0, 0, 1, '', '', 0, 5),
       (581, 'M', 'coins2', '', 0, 305, NULL, '', 0, 0, 0, '', '', 0, 5),
       (582, 'M', 'coins1', '', 1, 305, NULL, '', 0, 0, 1, '', '', 0, 5),
       (583, 'C', 'flag_robots', '#', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 0),
       (584, 'C', 'robo_jacket', 'M', 200, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (585, 'C', 'holiday_hat', '', 200, 20, NULL, '', 0, 0, 0, '', '', 0, 5),
       (586, 'C', 'winter_hat1', '', 900, 20, NULL, '', 1, 0, 1, '', '', 1, 5),
       (587, 'C', 'winter_hat2', '', 0, 20, NULL, 'Rare', 0, 1, 0, '', 'Winter Hat!', 0, 5),
       (588, 'C', 'winter_hat3', '', 900, 20, NULL, '', 1, 0, 1, '', '', 0, 5),
       (589, 'C', 'winter_hat4', '', 900, 20, NULL, '', 0, 1, 1, '', '', 0, 5),
       (590, 'C', 'winter_phones', 'F', 900, 20, NULL, '', 0, 1, 1, '', '', 0, 5),
       (591, 'C', 'xmas_hat', '', 0, 304, NULL, '', 0, 1, 0, '', '', 0, 5),
       (594, 'C', 'bell_hat', '', 0, 304, NULL, '', 0, 0, 0, '', 'Bell Hat', 0, 5),
       (595, 'C', 'elf', 'MLH', 2500, 304, NULL, '', 0, 1, 0, '', '', 0, 5),
       (596, 'C', 'walrus_mask', '', 0, 19, NULL, 'Rare', 0, 1, 0, '', 'Walrus Mask', 0, 5),
       (597, 'C', 'white_bear', 'MLBF', 0, 312, NULL, 'Rare', 0, 1, 0, '', 'Bear Costume!', 0, 5),
       (598, 'C', 'flag_robots_team', '#', 0, 41, NULL, '', 0, 0, 0, '', '', 0, 5),
       (599, 'C', 'robo_jacket_team', 'M', 0, 314, NULL, '', 0, 0, 1, '', '', 0, 5),
       (601, 'C', 'magic_buben', 'FHI', 2500, 25, NULL, 'command=MagicItem;name=rain_new', 0, 1, 0, '20120912', '', 0,
        5),
       (605, 'C', 'magic_snow', 'I', 10000, 324, NULL, 'command=MagicItem;name=snowfall', 0, 0, 0, '', '', 0, 5),
       (607, 'C', 'magic_rainbow', '&I', 0, 329, NULL, 'command=MagicItem;name=rainbow', 0, 0, 0, '', '', 0, 0),
       (608, 'C', 'wings_bat', '&', 10000, 15, NULL, 'command=StuffCharModifier;modifier=FlyModifier;speed=6;height=25',
        0, 1, 1, '', '', 0, 5),
       (610, 'C', 'wings_dracon', '&', 10000, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=6;height=25', 0, 1, 0, '', '', 0, 5),
       (612, 'C', 'wings_griffon', '&', 0, 329, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=6;height=25', 0, 0, 0, '', '', 0, 0),
       (614, 'C', 'mask_shark', 'F', 10000, 19, NULL, 'Rare', 0, 1, 0, '', '', 0, 5),
       (616, 'C', 'mask_spider', 'F', 0, 19, NULL, '', 0, 0, 0, '', '', 0, 5),
       (618, 'C', 'mask_eagle', 'F', 10000, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (620, 'C', 'mask_alien_2', 'F', 1000, 19, NULL, '', 0, 1, 1, '', '', 0, 5),
       (622, 'C', 'mask_alien_3', 'F', 1000, 19, NULL, '', 0, 1, 1, '', '', 0, 0),
       (636, 'C', 'magic_air_ball_blue', '&I', 10000, 324, NULL,
        'command=MagicStuffItemRain;fName=magicBubbleBlue;count=5', 0, 0, 0, '', '', 0, 5),
       (638, 'C', 'magic_air_ball_red', '&I', 10000, 324, NULL, 'command=MagicStuffItemRain;fName=magicBubble;count=5',
        0, 0, 0, '', '', 0, 5),
       (640, 'C', 'magic_air_ball_yellow', '&I', 10000, 324, NULL,
        'command=MagicStuffItemRain;fName=magicBubbleYellow;count=5', 0, 0, 0, '', '', 0, 5),
       (642, 'C', '_empty', '&I', 0, 41, NULL, '', 0, 1, 0, '', '', 0, 5),
       (644, 'C', 'futbolka_deli', 'M', 0, 326, NULL, 'Deliciouzz', 1, 0, 0, '', '', 0, 5),
       (646, 'C', 'futbolka_chobot', 'M', 0, 326, NULL, 'Chobot', 0, 0, 0, '', '', 0, 5),
       (648, 'C', 'hypnotic', '#', 6500, 305, NULL, '', 0, 1, 1, '', '', 0, 0),
       (650, 'C', 'sunflower', '#', 1000, 305, NULL, '', 0, 1, 1, '', '', 0, 5),
       (652, 'C', 'windmill', '', 2500, 25, NULL, '', 0, 1, 0, '2012096', 'Windmill', 0, 5),
       (654, 'C', 'bubble', 'MHLFB', 0, 312, NULL, '', 0, 1, 0, '', '', 0, 5),
       (656, 'C', 'flag_peace', '#', 1500, 305, NULL, '', 1, 0, 1, '', '', 0, 0),
       (658, 'C', 'wings_dragonfly', '&', 5000, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=23;height=25', 0, 1, 0, '', 'Dragonfly\'s Wings', 0, 5),
       (660, 'C', 'ufo_1', 'XHMBF', 0, 329, NULL, 'command=StuffCharModifier;modifier=FlyModifier;speed=11;height=25',
        0, 0, 0, '', '', 0, 0),
       (662, 'C', 'magic_hat', 'H', 2500, 25, NULL, '', 0, 1, 0, '2012106x', 'Wizard Hat', 0, 5),
       (666, 'C', 'nichos_suit', 'MHF', 0, 41, NULL,
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 1, 0, 0, '', '', 0, 5),
       (668, 'C', 'feather', 'I', 0, 305, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (670, 'C', 'futbolka_house', 'M', 10, 314, NULL, 'Rare', 1, 0, 1, '', '', 0, 5),
       (672, 'C', 'dress_7', 'MN', 850, 314, NULL, '', 0, 1, 1, '', '', 0, 5),
       (674, 'C', 'dress_8', 'M', 1305, 314, NULL, '', 0, 1, 1, '', '', 0, 5),
       (676, 'C', 'dress_9', 'MN', 5000, 314, NULL, '', 0, 1, 1, '', '', 0, 5),
       (678, 'C', 'hat_c', '', 2000, 20, NULL, 'Rare', 1, 0, 0, '', '', 0, 5),
       (680, 'C', 'hat_panamka', '', 600, 20, NULL, '', 1, 0, 1, '', '', 0, 5),
       (682, 'C', 'peruka_14', 'H', 2000, 20, NULL, '', 1, 1, 1, '', '', 0, 5),
       (684, 'C', 'peruka_emo6', 'H', 750, 20, NULL, '', 1, 1, 1, '', '', 0, 0),
       (686, 'C', 'smoking', 'MLBN', 1500, 314, NULL, '', 0, 1, 1, '', '', 0, 0),
       (690, 'C', 'magic_heart_bubble', '&I', 12000, 324, NULL,
        'command=MagicStuffItemRain;fName=magicbubbleheart;count=5', 0, 0, 0, '', '', 0, 5),
       (694, 'C', 'face_doll_1', 'FH', 100000, 31, NULL, '', 1, 1, 1, '', '', 0, 5),
       (696, 'C', 'face_doll_2', 'FH', 100000, 31, NULL, '', 1, 1, 1, '', '', 0, 0),
       (698, 'C', 'face_doll_3', 'FH', 100000, 31, NULL, '', 1, 1, 1, '', '', 0, 0),
       (700, 'C', 'jet_pack_3', '&X', 2500, 15, NULL,
        'command=StuffCharModifier;modifier=FlyModifier;speed=15;height=25', 0, 1, 0, '', 'Jet Pack 3', 0, 5),
       (702, 'C', 'comix', 'I', 0, 305, NULL, 'Prize', 0, 0, 0, '', '', 0, 5),
       (704, 'C', 'face_boy_1', 'FH', 35000, 31, NULL, '', 1, 1, 1, '', '', 0, 0),
       (706, 'C', 'face_boy_2', 'FH', 25000, 31, NULL, '', 1, 1, 1, '', '', 0, 0),
       (708, 'C', 'face_boy_3', 'FH', 45000, 31, NULL, '', 1, 1, 1, '', '', 0, 5),
       (710, 'C', 'face_doll_4', 'FH', 100000, 31, NULL, '', 1, 0, 1, '', '', 0, 0),
       (712, 'C', 'face_doll_5', 'FH', 10000, 31, NULL, '', 0, 0, 1, '', '', 0, 0),
       (714, 'C', 'face_doll_6', 'FH', 10000, 31, NULL, '', 1, 1, 1, '', '', 0, 5),
       (716, 'C', 'face_doll_7', 'FH', 50000, 31, NULL, '', 1, 1, 1, '', '', 0, 5),
       (718, 'C', 'magic_speed', '&I', 10000, 324, NULL, 'command=MagicStuffItemRain;fName=magicSpeed;count=5', 0, 0, 0,
        '', '', 0, 5),
       (720, 'C', 'dress_7_reg', 'MN', 5000, 314, NULL, '', 0, 1, 1, '', '', 0, 0),
       (722, 'C', 'face_boy_5', 'FH', 50000, 31, '2010-03-26 15:07:57', '', 1, 0, 1, '', '', 0, 0),
       (724, 'C', 'face_boy_6', 'FH', 21200, 31, '2010-03-26 15:09:53', '', 1, 0, 1, '', '', 0, 5),
       (726, 'C', 'face_boy_7', 'FH', 14000, 31, '2010-03-26 15:10:45', '', 1, 1, 1, '', '', 0, 5),
       (728, 'C', 'face_doll_11', 'HF', 100000, 31, '2010-03-26 15:11:40', '', 1, 1, 1, '', '', 0, 5),
       (730, 'C', 'face_doll_9', 'FH', 50000, 31, '2010-03-26 15:12:57', '', 1, 1, 1, '', '', 0, 0),
       (732, 'C', 'face_doll_10', 'FH', 40000, 31, '2010-03-26 15:14:15', '', 1, 1, 1, '', '', 0, 5),
       (734, 'C', 'hat_campanula', '', 0, 20, '2010-03-26 15:18:59', 'Rare', 0, 0, 0, '', '', 0, 5),
       (736, 'C', 'futbolka_crown', 'M', 0, 314, '2010-03-26 15:19:43', 'Rare', 1, 0, 1, '', '', 0, 5),
       (738, 'C', 'dress_10', 'ML', 5600, 314, '2010-03-26 15:20:50', '', 1, 1, 1, '', '', 0, 0),
       (740, 'C', 'head_package', 'F', 0, 20, '2010-03-30 11:21:43', 'Rare', 0, 1, 0, '', 'Paper Bag', 0, 5),
       (742, 'C', 'mask_hamster', 'FH', 2500, 25, '2010-03-30 12:12:34', '', 0, 1, 0, '2012096', 'Hamster Mask', 0, 5),
       (744, 'C', 'mask_clown', 'F', 2500, 25, '2010-03-30 12:13:19', '', 0, 1, 0, 'Apr12BON', 'Clown Mask', 0, 5),
       (746, 'C', 'easter_bag', '&', 400, 315, '2010-03-31 11:06:09', '', 0, 0, 1, '', '', 0, 5),
       (748, 'C', 'easter_bunny', '&', 300, 305, '2010-03-31 11:06:42', '', 0, 1, 1, '', '', 0, 5),
       (750, 'C', 'shirt', 'M', 8000, 314, '2010-04-02 12:39:28', '', 0, 0, 1, '', '', 0, 5),
       (752, 'C', 'shirt_girl1', 'M', 5000, 314, '2010-04-02 12:40:10', '', 1, 0, 1, '', '', 0, 0),
       (754, 'C', 'dress_11', 'M', 8000, 314, '2010-04-02 12:40:36', '', 1, 0, 1, '', '', 0, 5),
       (756, 'C', 'dress_12', 'M', 4000, 314, '2010-04-02 12:40:59', '', 1, 1, 1, '', '', 0, 0),
       (758, 'C', 'boy_jeans', 'L', 3000, 306, '2010-04-02 12:41:34', '', 1, 0, 1, '', '', 0, 0),
       (760, 'C', 'elf_doll_1', 'FH', 100000, 31, '2010-04-08 14:53:22', '', 1, 0, 1, '', '', 0, 5),
       (762, 'C', 'american footbolist', 'HMBLI', 2500, 312, '2010-04-08 14:55:01', 'Rare', 1, 1, 0, '',
        'Football outfit', 0, 5),
       (764, 'C', 'air_board_pizza', 'X', 5000, 15, '2010-04-08 15:02:21',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 1, 1, '', 'Pizza Board', 0, 5),
       (766, 'C', 'air_board_cd', 'X', 5000, 15, '2010-04-08 15:02:51',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 0, 1, '', 'CD Board', 0, 5),
       (768, 'C', 'air_board11', 'X', 0, 15, '2010-04-08 15:04:44',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=10', 0, 1, 1, '', 'Airboard', 0, 5),
       (770, 'C', 'board', 'X', 5000, 41, '2010-04-09 10:05:44',
        'command=StuffCharModifier;modifier=FlyModifier;speed=10;height=15', 1, 0, 0, '', 'Flame Shoes', 0, 5),
       (772, 'C', 'jumper_teleport', 'X', 2500, 25, '2010-04-09 10:34:52',
        'command=StuffCharModifier;modifier=TeleportModifier;', 0, 1, 0, 'JUL12BON', 'Pogo Stick', 0, 5),
       (774, 'C', 'jaket_boy_1', 'MN', 3000, 314, '2010-04-16 10:16:30', '', 0, 1, 1, '', '', 0, 5),
       (776, 'C', 'elf_boy_1', 'FH', 100000, 31, '2010-04-16 10:16:54', '', 1, 0, 1, '', '', 0, 5),
       (778, 'C', 'elf_boy_2', 'FH', 100000, 31, '2010-04-16 10:17:21', '', 1, 1, 1, '', '', 0, 5),
       (780, 'C', 'elf_doll_2', 'FH', 50000, 31, '2010-04-16 10:17:44', '', 1, 1, 1, '', '', 0, 5),
       (782, 'C', 'skirt_1', 'L', 5000, 306, '2010-04-16 10:18:10', '', 1, 1, 1, '', '', 0, 5),
       (784, 'C', 'ork_1', 'FH', 20000, 19, '2010-04-16 10:22:07', '', 1, 1, 0, '', '', 0, 0),
       (786, 'C', 't-shirt_girl_1', 'M', 15000, 314, '2010-04-16 10:22:38', '', 1, 1, 1, '', '', 0, 0),
       (788, 'C', 'vintage_boy_1', 'FMLB', 7500, 312, '2010-04-21 13:22:57', '', 0, 1, 1, '', '', 0, 0),
       (790, 'C', 'vintage_girl_1', 'MLB', 0, 314, '2010-04-21 13:23:31', '', 0, 0, 1, '', '', 0, 5),
       (792, 'C', 'anime_girl_1', 'NMLB', 50000, 314, '2010-04-21 13:24:24', '', 1, 0, 1, '', '', 0, 5),
       (794, 'C', 'ork_2', 'FH', 6000, 19, '2010-04-21 13:24:56', '', 1, 0, 0, '', '', 0, 0),
       (796, 'C', 'trousers_boy_1', 'L', 5000, 306, '2010-04-21 13:25:22', '', 1, 1, 1, '', '', 0, 0),
       (798, 'C', 'anime_boy_1', 'MLB', 50000, 312, '2010-04-21 13:25:57', '', 1, 1, 1, '', '', 0, 0),
       (800, 'C', 'kostum_monah', 'HMBIL', 0, 312, '2010-04-22 12:43:28', '', 0, 0, 0, '', 'Kung Fu Fighter', 0, 5),
       (802, 'C', 'goth_girl_2', 'M', 1500, 314, '2010-04-22 12:44:07', '', 0, 1, 1, '', '', 0, 5),
       (804, 'C', 'goth_girl_1', 'LB', 1000, 306, '2010-04-22 12:44:42', '', 0, 1, 1, '', '', 0, 5),
       (806, 'C', 'kostum_z', 'M', 0, 314, '2010-04-22 12:44:58', 'Rare', 0, 0, 0, '', '', 0, 5),
       (808, 'C', 'kostum_z', 'M', 0, 314, '2010-04-22 12:45:02', 'Rare', 0, 1, 0, '', 'Robot Z', 0, 5),
       (810, 'C', 'kostum_cosmo', 'HMLB', 10000, 312, '2010-04-22 13:52:43', '', 0, 1, 1, '', '', 0, 5),
       (812, 'C', 't-short_sailor', 'M', 1000, 314, '2010-04-27 13:23:22', '', 0, 1, 1, '', '', 0, 0),
       (814, 'C', 't-shirt_stars', 'M', 0, 314, '2010-04-27 13:23:46', '', 0, 0, 1, '', '', 0, 5),
       (816, 'C', 'vintage_girl_4', 'L', 1500, 306, '2010-04-27 13:24:13', '', 0, 1, 1, '', '', 0, 0),
       (818, 'C', 'vintage_girl_3', 'M', 2000, 314, '2010-04-27 13:27:14', '', 1, 1, 1, '', '', 0, 5),
       (820, 'C', 'vintage_7', 'M', 1250, 314, '2010-04-27 13:27:30', '', 1, 1, 1, '', '', 0, 0),
       (822, 'C', 'hat_ananas', 'H', 15000, 20, '2010-04-27 13:27:52', '', 0, 1, 1, '', '', 0, 5),
       (824, 'C', 'futbolka_cj', 'M', 1200, 314, '2010-04-27 13:28:47', '', 1, 1, 1, '', '', 0, 0),
       (826, 'C', 'air_board_devilfish', 'X', 0, 15, '2010-04-27 13:29:03',
        'command=StuffCharModifier;modifier=BoardModifier;speed=12;height=4', 0, 0, 1, '', '', 0, 5),
       (828, 'C', 'air_board_devilfish', 'X', 0, 15, '2010-04-30 15:06:24',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 1, 1, '', 'Devilfish Board', 0, 5),
       (830, 'C', 'kostium_trash', 'HM', 0, 312, '2010-04-30 15:07:22', 'Rare', 0, 1, 0, '', 'GarbageCan Suit', 0, 5),
       (832, 'C', 'bag_toadstool', '&I', 10000, 324, '2010-04-30 19:48:52', 'command=MagicItem;name=spring', 0, 0, 0,
        '', 'Magic Spring Spring', 0, 5),
       (834, 'C', 'dress_doll_fashion', 'M', 2000, 314, '2010-05-07 11:38:45', '', 1, 0, 1, '', '', 0, 0),
       (836, 'C', 'shtany_goth', 'L', 1000, 306, '2010-05-07 11:39:03', '', 1, 1, 1, '', '', 0, 5),
       (838, 'C', 'elf_dress', 'M', 1500, 314, '2010-05-07 11:39:14', '', 1, 1, 1, '', '', 0, 5),
       (840, 'C', 'shirt_bear', 'M', 5250, 314, '2010-05-07 11:39:30', '', 1, 1, 1, '', '', 0, 0),
       (842, 'C', 'hat_stile', '', 5000, 20, '2010-05-07 11:39:45', '', 0, 1, 1, '', '', 0, 5),
       (844, 'C', 'dress_flower', 'ML', 5000, 314, '2010-05-07 11:39:59', '', 0, 1, 1, '', '', 0, 5),
       (846, 'C', 'shirt_boy_7', 'M', 3500, 314, '2010-05-07 11:40:25', '', 1, 1, 1, '', '', 0, 0),
       (848, 'C', 'elf_boy_4', 'HF', 50000, 31, '2010-05-07 11:40:39', '', 0, 0, 1, '', '', 0, 5),
       (850, 'C', 't-shirt_stars', 'M', 2000, 314, '2010-05-07 11:40:52', '', 0, 1, 1, '', '', 0, 5),
       (852, 'C', 'air_board_psp', 'X', 0, 15, '2010-05-07 12:30:10',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 1, '', '', 0, 5),
       (854, 'C', 'hat_stile_doll', 'H', 10000, 20, '2010-05-07 12:30:23', '', 1, 1, 1, '', '', 0, 0),
       (856, 'C', 'magic_sun', 'I', 10000, 324, '2010-05-07 12:30:46', 'command=MagicItem;name=sun', 0, 0, 0, '', '', 0,
        5),
       (858, 'C', 'air_board_leaf', 'X', 500, 15, '2010-05-07 12:31:05',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 0, 1, '', '', 0, 5),
       (860, 'C', 'hat_stile_doll_2', 'H', 10500, 20, '2010-05-07 12:31:17', '', 1, 1, 1, '', '', 0, 5),
       (862, 'C', 'shirt_tiger', 'M', 2000, 314, '2010-05-07 12:31:40', '', 0, 0, 1, '', '', 0, 0),
       (864, 'C', 'dress_tiger', 'M', 2500, 314, '2010-05-07 12:31:51', '', 0, 1, 1, '', '', 0, 5),
       (866, 'C', 'dress_girl_13', 'M', 1050, 314, '2010-05-14 13:32:02', '', 1, 1, 1, '', '', 0, 5),
       (868, 'C', 'trousers_boy_2', 'L', 950, 306, '2010-05-14 13:32:33', '', 1, 1, 1, '', '', 0, 5),
       (870, 'C', 'vintage_boy_2', 'M', 1250, 314, '2010-05-14 13:32:52', '', 1, 1, 1, '', '', 0, 5),
       (872, 'C', 'air_board_racket', 'X', 10000, 15, '2010-05-14 13:34:02',
        'command=StuffCharModifier;modifier=BoardModifier;speed=7;height=10', 0, 1, 1, '', '', 0, 5),
       (876, 'C', 'foliant', 'I', 0, 305, '2010-05-19 12:43:54', 'Prize', 0, 0, 0, '', '', 0, 5),
       (878, 'C', 'microphone', 'I', 0, 305, '2010-05-19 12:44:09', 'Prize', 0, 0, 0, '', '', 0, 5),
       (880, 'C', 'toy_bear2', 'I', 5000, 329, '2010-05-19 12:44:23', '', 0, 1, 0, '', '', 0, 5),
       (882, 'C', 'face_boy_8', 'FH', 50000, 31, '2010-05-19 12:45:46', '', 1, 1, 1, '', '', 0, 0),
       (884, 'C', 'bag_cat', '&', 15000, 305, '2010-05-19 12:50:11', '', 0, 1, 1, '', '', 0, 0),
       (886, 'C', 'magic_water', '&I', 0, 329, '2010-05-19 12:50:28', 'command=MagicItem;name=surfer', 0, 0, 0, '', '',
        0, 0),
       (888, 'C', 'face_doll_12', 'FH', 25000, 31, '2010-05-19 12:51:40', '', 1, 1, 1, '', '', 0, 0),
       (890, 'C', 'bag_puppy_1', '&', 7500, 305, '2010-05-19 12:52:00', '', 0, 1, 1, '', 'Backpack Puppy', 0, 0),
       (892, 'C', 'air_board_flower', 'X', 0, 15, '2010-05-21 10:29:55',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 1, 1, '', '', 0, 5),
       (894, 'C', 'air_board_clock', 'X', 2000, 15, '2010-05-21 10:30:05',
        'command=StuffCharModifier;modifier=BoardModifier;speed=7;height=10', 0, 1, 1, '', '', 0, 5),
       (896, 'C', 'hat_boy_2', 'HF', 5000, 20, '2010-05-21 10:30:27', '', 1, 1, 1, '', '', 0, 0),
       (898, 'C', 'skirt_2', 'L', 1500, 306, '2010-05-27 09:38:39', '', 1, 1, 1, '', '', 0, 0),
       (900, 'C', 'bag_panda', '&', 10000, 305, '2010-05-27 09:39:07', '', 0, 0, 1, '', 'Panda Bag', 0, 0),
       (902, 'C', 'bag_bear', '&', 5000, 305, '2010-05-27 09:39:16', '', 0, 1, 1, '', '', 0, 5),
       (904, 'C', 'jacket_1', 'M', 600, 314, '2010-05-28 12:55:27', 'DUPLICATE', 1, 1, 1, '', '', 0, 5),
       (906, 'C', 'costume_ball', 'MLN', 0, 312, '2010-05-28 12:55:40', '', 0, 1, 1, '', '', 0, 5),
       (908, 'C', 'air_board_carpet', 'X', 0, 329, '2010-05-31 14:14:58',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 0, 0, '', 'Magic Carpet', 0, 0),
       (918, 'C', 'hawaiian_lei', 'N', 2500, 25, '2010-05-31 15:04:10', '', 0, 1, 0, '2012091', 'Hawaiian Lei', 0, 5),
       (920, 'C', 'swimming_ring', '', 0, 314, '2010-05-31 15:10:13', 'Rare', 0, 1, 0, '', 'Swimming Ring', 0, 5),
       (922, 'C', 'magic_notes', '&I', 10000, 324, '2010-06-11 09:29:24', 'command=MagicItem;name=notes', 0, 0, 0, '',
        '', 0, 5),
       (924, 'C', 'air_board_mountain', 'X', 2000, 15, '2010-06-11 09:30:49',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 1, '', '', 0, 5),
       (926, 'C', 'jet_pack_4', '&X', 2500, 25, '2010-06-11 09:31:30',
        'command=StuffCharModifier;modifier=FlyModifier;speed=15;height=25', 0, 1, 0, '2012106', 'Jet Pack Magician', 0,
        5),
       (928, 'C', 'mask_grom', 'HF', 50000, 19, '2010-06-11 12:53:02', '', 1, 0, 0, '', '', 0, 5),
       (930, 'C', 'mask_yello', 'HF', 50000, 19, '2010-06-11 12:53:12', '', 1, 0, 0, '', '', 0, 0),
       (932, 'C', 'mask_pinka', 'HF', 50000, 19, '2010-06-11 12:53:20', '', 1, 0, 0, '', '', 0, 0),
       (934, 'C', 'magic_lightning', 'I', 10000, 324, '2010-06-18 11:56:06', 'command=MagicItem;name=lightning', 0, 0,
        0, '', 'Lightning Animation', 0, 5),
       (936, 'C', 'hat_indians_1', '', 5000, 20, '2010-06-18 14:00:03', '', 0, 1, 1, '', '', 0, 0),
       (938, 'C', 'hat_indians_2', 'H', 2300, 20, '2010-06-18 14:00:21', '', 0, 1, 1, '', '', 0, 0),
       (940, 'C', 'hat_indians_girl_1', 'H', 2700, 20, '2010-06-18 14:00:33', '', 0, 1, 1, '', '', 0, 0),
       (942, 'C', 'glasses_3d', 'IF', 3500, 305, '2010-06-18 14:00:50', '', 0, 1, 1, '', '3D Glasses', 0, 0),
       (944, 'C', 'kostum_baseball', 'LMH', 5000, 312, '2010-06-18 14:01:09', '', 1, 1, 1, '', '', 0, 0),
       (946, 'C', 't-shirt_boy', 'M', 3200, 314, '2010-06-18 14:01:23', '', 1, 0, 1, '', '', 0, 5),
       (948, 'C', 'dress_doll_16', 'M', 1500, 314, '2010-06-18 14:01:33', '', 1, 1, 1, '', '', 0, 5),
       (950, 'C', 'air_board_candy', 'X', 3000, 15, '2010-06-18 14:16:52',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 1, '', '', 0, 5),
       (952, 'C', 'air_board_palm', 'X', 5000, 15, '2010-06-18 14:17:06',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 1, '', 'LEVEL 6 ITEM', 0, 5),
       (954, 'C', 'bag_rabbit', '&', 750, 305, '2010-06-18 14:17:14', '', 0, 1, 1, '', '', 0, 5),
       (956, 'C', 'dress_doll_14', 'M', 1350, 314, '2010-06-18 14:17:35', '', 1, 1, 1, '', '', 1, 5),
       (958, 'C', 'bant_1_test', 'N', 0, 315, '2010-06-18 14:17:49', '', 1, 1, 1, '', '', 0, 5),
       (960, 'C', 'bag_gitar', '&', 1400, 305, '2010-07-09 11:42:35', '', 0, 1, 1, '', '', 0, 0),
       (962, 'C', 'kostium_luckyluke', 'HMLB', 12500, 312, '2010-07-09 11:43:50', '', 0, 1, 1, '', '', 0, 0),
       (964, 'C', 'mask_faraon', 'H', 2000, 31, '2010-07-09 11:44:30', '', 0, 1, 1, '', '', 0, 5),
       (968, 'C', 'dress_doll_17', 'ML', 4000, 314, '2010-07-09 11:47:00', '', 1, 1, 1, '', '', 0, 5),
       (970, 'C', 'shirt_parrots', 'M', 2000, 314, '2010-07-09 11:48:32', '', 0, 1, 1, '', '', 0, 0),
       (972, 'C', 'shirt_boy_14', 'M', 3299, 314, '2010-07-09 11:49:20', '', 1, 1, 1, '', '', 0, 0),
       (974, 'C', 'mask_tyrannosaurus rex', 'H', 1000, 19, '2010-07-09 11:51:06', '', 0, 1, 1, '', 'T. Rex Mask', 0, 0),
       (976, 'C', 'mask_triceraptos', 'HF', 5000, 19, '2010-07-09 11:51:40', '', 0, 1, 1, '', '', 0, 0),
       (978, 'C', 'hat_girl', 'H', 1000, 20, '2010-07-09 11:52:03', '', 1, 1, 1, '', '', 0, 5),
       (980, 'C', 'bag_lion', '&', 5000, 305, '2010-07-09 11:52:29', '', 0, 1, 1, '', '', 0, 0),
       (982, 'C', 'boots2_test', 'ML', 2000, 306, '2010-07-16 14:57:13', '', 1, 1, 1, '', '', 0, 5),
       (984, 'C', 'dress_doll_18', 'M', 2000, 314, '2010-07-16 14:57:57', 'Rare', 1, 1, 1, '', '', 0, 5),
       (986, 'C', 'flag_football', '#', 1500, 305, '2010-07-16 14:58:26', '', 1, 1, 1, '', '', 0, 0),
       (988, 'C', 'hat_boy_3', 'H', 1000, 20, '2010-07-16 14:58:49', '', 1, 1, 1, '', '', 0, 5),
       (990, 'C', 'hat_boy_4', 'H', 700, 20, '2010-07-16 14:59:22', '', 1, 1, 1, '', '', 0, 0),
       (992, 'C', 'hat_girl_3', 'H', 1500, 20, '2010-07-16 15:02:08', '', 1, 0, 1, '', '', 0, 5),
       (994, 'C', 'hat_girl_4', 'H', 700, 20, '2010-07-16 15:02:19', '', 1, 1, 1, '', '', 0, 0),
       (996, 'C', 'hat_girl_5', 'H', 1000, 20, '2010-07-16 15:02:26', '', 1, 0, 1, '', '', 0, 5),
       (998, 'C', 'hat_girl_6', 'H', 1000, 20, '2010-07-16 15:02:35', '', 1, 0, 1, '', '', 0, 5),
       (1000, 'C', 'hat_girl_7', 'H', 1000, 20, '2010-07-16 15:02:41', '', 1, 1, 1, '', '', 0, 5),
       (1002, 'C', 'shirt_ball', 'M', 2000, 314, '2010-07-16 15:02:54', '', 1, 1, 1, '', '', 0, 0),
       (1004, 'C', 'shirt_boy_15', 'M', 1500, 314, '2010-07-16 15:04:34', '', 1, 1, 1, '', '', 0, 5),
       (1006, 'C', 'mask_muska', 'HF', 2500, 19, '2010-07-16 15:05:26', '', 1, 1, 1, '', '', 0, 0),
       (1008, 'C', 'dress_13', 'M', 1500, 314, '2010-07-16 15:05:53', '', 1, 1, 1, '', '', 0, 5),
       (1010, 'C', 'costume_drakula_boy', 'MLHFB', 0, 41, '2010-07-16 15:06:14', '', 1, 0, 0, '', '', 0, 5),
       (1012, 'C', 'air_board_flower2', 'X', 5000, 15, '2010-07-16 15:06:45',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 1, '', '', 0, 5),
       (1014, 'C', 'roller', 'HBX', 0, 312, '2010-07-23 08:30:23',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 1, 1, '', 'Roller costume', 0, 5),
       (1016, 'C', 'kostum_cow', 'HFMLBN', 4000, 312, '2010-07-23 08:30:35', '', 0, 1, 1, '', 'Cow costume', 0, 5),
       (1018, 'C', 'giga_suit', 'HFMLBN', 2500, 25, '2010-07-23 08:30:49', '', 0, 1, 0, '2012081', 'Giant Giga', 0, 5),
       (1020, 'C', 'dress_14', 'M', 5000, 314, '2010-08-06 14:58:29', '', 0, 1, 1, '', '', 0, 5),
       (1022, 'C', 'boots2_test', '', 0, 306, '2010-08-31 17:32:47', '', 0, 1, 1, '', '', 0, 5),
       (1024, 'C', 'air_board_maple', 'X', 0, 41, '2010-08-31 17:32:59', '', 0, 1, 0, '', '', 0, 2),
       (1026, 'C', 'fish_tail', '', 0, 41, '2010-08-31 17:33:09', '', 0, 1, 0, '', '', 0, 5),
       (1028, 'C', 'fish_tail', '', 0, 312, '2010-08-31 20:58:11', '', 1, 1, 0, '', '', 0, 5),
       (1030, 'C', 'fish_tail2', 'XLBI', 0, 41, '2010-08-31 21:08:10',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 1, 0, '', 'Neptune Suit', 0, 5),
       (1032, 'C', 'air_board_maple2', 'X', 2500, 25, '2010-08-31 21:14:03',
        'command=StuffCharModifier;modifier=BoardModifier;speed=11;height=10', 0, 1, 0, '2012101x', 'Maple Board', 0,
        5),
       (1034, 'C', 'toy_bear2', 'I', 0, 329, '2010-08-31 21:16:22', '', 0, 0, 0, '', 'Teddy Bear', 0, 0),
       (1036, 'C', 'dress_saphira', 'M', 0, 326, '2010-09-03 10:17:11', 'Sapfira', 0, 0, 0, '', '', 0, 5),
       (1040, 'C', 'magic_leafs', '&I', 2500, 25, '2010-09-06 14:41:21', 'command=MagicItem;name=autumn', 0, 1, 0,
        '20120912', '', 0, 5),
       (1042, 'C', 'shoes_winter_2', 'B', 2500, 306, '2010-09-13 10:12:29', '', 1, 0, 1, '', '', 0, 5),
       (1044, 'C', 'shoes_winter', 'B', 1000, 306, '2010-09-13 10:12:54', '', 1, 0, 1, '', '', 0, 5),
       (1046, 'C', 'hat_winter_11', 'H', 1000, 20, '2010-09-13 10:13:02', '', 1, 1, 1, '', '', 0, 0),
       (1048, 'C', 'coat_girl_3', 'M', 3000, 314, '2010-09-13 10:13:08', '', 1, 0, 1, '', '', 0, 5),
       (1050, 'C', 'jacket_girl_2', 'M', 2000, 314, '2010-09-13 10:13:15', '', 1, 1, 1, '', '', 0, 5),
       (1052, 'C', 'jacket_boy_2', 'M', 2000, 314, '2010-09-13 10:13:21', '', 1, 1, 1, '', '', 0, 0),
       (1054, 'C', 'jaket_boy_1', 'MN', 2000, 314, '2010-09-13 10:13:28', '', 1, 1, 1, '', '', 0, 0),
       (1056, 'C', 'hat_boy_winter_1', 'H', 1000, 20, '2010-09-13 10:13:34', '', 1, 1, 1, '', '', 0, 0),
       (1058, 'C', 'girl_coat_1', 'M', 1500, 314, '2010-09-13 10:13:40', '', 1, 1, 1, '', '', 0, 0),
       (1060, 'C', 'bag_cake', '&', 5000, 305, '2010-09-30 14:07:59', '', 0, 1, 1, '', '', 0, 0),
       (1062, 'C', 'hat_winter_2', 'H', 2000, 20, '2010-09-30 14:08:33', '', 1, 0, 1, '', '', 0, 0),
       (1064, 'C', 'bag_snowman', '&', 5000, 305, '2010-09-30 14:08:42', '', 0, 1, 1, '', '', 0, 5),
       (1066, 'C', 'costume_zombie', 'HMLF', 10000, 312, '2010-09-30 14:08:59', '', 0, 1, 0, '', '', 0, 5),
       (1068, 'C', 'costume_fox', 'HB', 0, 329, '2010-09-30 14:09:11', '', 0, 0, 0, '', 'Fox Suit', 0, 0),
       (1070, 'C', 'magic_helloween', '&I', 2500, 25, '2010-09-30 14:09:24', 'command=MagicItem;name=pumkin_jump', 0, 1,
        0, '20121012', 'Halloween Glider', 0, 5),
       (1072, 'C', 'air_board_broom', 'X', 0, 15, '2010-09-30 14:09:43',
        'command=StuffCharModifier;modifier=BoardModifier;speed=12;height=4', 0, 0, 1, '', '', 0, 5),
       (1074, 'C', 'costume_witch', 'HMLF', 10000, 312, '2010-09-30 14:09:57', '', 0, 1, 1, '', '', 0, 5),
       (1076, 'C', 'jacket girl_4', 'M', 2000, 314, '2010-09-30 14:10:07', '', 1, 0, 1, '', '', 0, 0),
       (1078, 'C', 'dress_girl_new_1', 'M', 3000, 314, '2010-09-30 14:10:17', '', 1, 1, 1, '', '', 0, 5),
       (1080, 'C', 'face_boy_winter_1', 'H', 52000, 31, '2010-09-30 14:10:27', '', 1, 1, 1, '', '', 0, 5),
       (1082, 'C', 'face_doll_winter_1', 'H', 50000, 31, '2010-09-30 14:10:38', '', 1, 0, 1, '', '', 0, 0),
       (1084, 'C', 'shorts_girl_1', 'L', 3000, 306, '2010-09-30 14:10:47', '', 1, 1, 1, '', '', 0, 0),
       (1086, 'C', 'jacket_boy_4', 'M', 3000, 314, '2010-09-30 14:10:57', '', 1, 0, 1, '', '', 0, 5),
       (1088, 'C', 'jacket_girl_3', 'M', 4000, 314, '2010-09-30 14:11:07', '', 1, 1, 1, '', '', 0, 5),
       (1090, 'C', 'jacket_boy_3', 'M', 4000, 314, '2010-09-30 14:11:13', '', 1, 1, 1, '', '', 0, 0),
       (1092, 'C', 'bag_butterfly', '&', 10000, 305, '2010-09-30 14:11:21', '', 0, 1, 1, '', '', 0, 0),
       (1094, 'C', 'trousers_girl_1', 'L', 3000, 306, '2010-09-30 14:11:31', '', 1, 1, 1, '', '', 0, 0),
       (1096, 'C', 'bag_mushrooms', '&', 4500, 305, '2010-09-30 14:11:43', '', 0, 1, 1, '', '', 0, 0),
       (1098, 'C', 'air_board_broom', 'X', 0, 15, '2010-09-30 14:24:21',
        'command=StuffCharModifier;modifier=BoardModifier;speed=12;height=4', 0, 0, 1, '', '', 0, 5),
       (1100, 'C', 'air_board_mitla', 'X', 2500, 25, '2010-09-30 14:29:01',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 1, 0, '20121013', 'Magic broom', 0,
        5),
       (1102, 'C', 'air_board_mitla1', 'X', 3666, 15, '2010-09-30 14:47:20',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=20', 0, 1, 1, '', 'Magic broom', 0, 5),
       (1104, 'C', 'futbolka_2years', 'M', 2000, 314, '2010-10-09 18:25:50', '', 0, 0, 1, '', '', 0, 5),
       (1106, 'C', 'hat_cake1', '', 5000, 20, '2010-10-22 14:04:50', '', 0, 1, 1, '', '', 0, 5),
       (1108, 'C', 'skates', 'B', 5000, 306, '2010-10-22 14:05:03',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=0.5', 1, 1, 1, '', '', 0, 5),
       (1110, 'C', 'bag_sun', '&', 4500, 305, '2010-10-22 14:05:14', '', 0, 1, 1, '', 'Sun bag', 0, 5),
       (1112, 'C', 'coat_boy_winter', 'M', 2000, 314, '2010-10-22 14:05:24', '', 1, 0, 1, '', '', 0, 0),
       (1114, 'C', 'skirt', 'L', 2000, 306, '2010-10-22 14:05:32', '', 0, 1, 1, '', '', 0, 0),
       (1116, 'C', 'shoes_girl_winter', 'B', 2000, 306, '2010-10-22 14:05:42', '', 1, 1, 1, '', '', 0, 0),
       (1118, 'C', 'coat_girl_winter_10', 'M', 3000, 314, '2010-10-22 14:06:04', '', 1, 1, 1, '', '', 0, 5),
       (1120, 'C', 'hat_boy_111', 'H', 4000, 20, '2010-10-22 14:06:13', '', 1, 0, 1, '', '', 0, 0),
       (1122, 'C', 'hat_girl_111', 'H', 2000, 20, '2010-10-22 14:06:20', '', 1, 1, 1, '', '', 0, 0),
       (1124, 'C', 'bag_b_cat', '&', 10000, 305, '2010-10-22 14:06:29', '', 0, 1, 1, '', '', 0, 0),
       (1126, 'C', 'bag_mitla', '&', 10000, 305, '2010-10-22 14:06:35', '', 0, 1, 1, '', '', 0, 0),
       (1128, 'C', 'shirt_boy_music', 'M', 2000, 314, '2010-10-22 14:06:43', '', 0, 1, 1, '', '', 0, 5),
       (1130, 'C', 'flag_pumpkin', '#', 1000, 305, '2010-10-22 14:06:51', '', 1, 0, 1, '', '', 1, 5),
       (1132, 'C', 'costume_tree', 'HMLBI', 10000, 304, '2010-10-22 14:07:03', '', 0, 1, 0, '', '', 0, 5),
       (1134, 'C', 'costume_sheep', 'HMLBI', 10000, 312, '2010-10-22 14:07:09', '', 0, 1, 1, '', '', 0, 5),
       (1136, 'C', 'hat_winter_5', 'H', 2000, 20, '2010-10-22 14:07:18', '', 1, 0, 1, '', '', 0, 0),
       (1138, 'C', 'hat_winter_4', '', 2000, 20, '2010-10-22 14:07:24', '', 1, 0, 1, '', '', 0, 0),
       (1140, 'C', 'costume_yeti_1', 'HMLBI', 0, 312, '2010-10-22 14:07:33', 'Rare', 0, 1, 0, '', 'Yeti suit', 0, 5),
       (1142, 'C', 'dress_girl_new_2', 'M', 2000, 314, '2010-10-22 14:07:45', '', 1, 1, 1, '', '', 0, 5),
       (1144, 'C', 'air_board_snow', 'X', 0, 15, '2010-10-22 14:07:51',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 0, 1, '', '', 0, 5),
       (1146, 'C', 'pupmpkinman', 'HMLB', 10000, 312, '2010-10-22 14:08:03', '', 0, 1, 0, '', '', 0, 5),
       (1148, 'C', 'mask_hedgehog', 'H', 0, 19, '2010-10-29 16:02:18', '', 0, 1, 1, '', 'Hedgehog mask', 0, 5),
       (1150, 'C', 'mask_hedgehog', 'H', 50000, 31, '2010-10-29 16:02:34', '', 0, 0, 1, '', '', 0, 5),
       (1152, 'C', 'lapka', 'I', 1000, 305, '2010-11-24 15:53:23', '', 0, 0, 1, '', '', 0, 5),
       (1154, 'C', 'turkey_head', 'H', 5000, 20, '2010-11-24 15:55:47', '', 0, 1, 1, '', '', 0, 5),
       (1156, 'C', 'hat_boy_thanks_day', 'H', 5000, 20, '2010-11-24 15:55:54', '', 1, 1, 1, '', '', 0, 5),
       (1158, 'C', 'toothbrush', 'I', 5000, 305, '2010-11-29 10:11:44', '', 0, 0, 1, '', '', 0, 0),
       (1160, 'C', 'sleep_set', 'MIL', 6500, 312, '2010-11-29 10:12:01', '', 1, 1, 1, '', '', 0, 0),
       (1162, 'C', 'kofta_cat', 'MH', 6000, 314, '2010-11-29 10:12:42', '', 1, 1, 1, '', '', 0, 0),
       (1164, 'C', 'jalabaja', 'M', 3000, 314, '2010-11-29 10:12:53', '', 1, 0, 1, '', '', 0, 5),
       (1166, 'C', 'shirt_doll_flower', 'M', 2999, 314, '2010-11-29 10:13:03', '', 0, 0, 1, '', '', 0, 0),
       (1168, 'C', 'costume_11', 'MH', 5000, 312, '2010-11-29 10:13:16', '', 0, 1, 1, '', 'Clown Costume', 0, 0),
       (1170, 'C', 'hat_kryshka', '', 0, 20, '2010-11-29 10:13:37', '', 0, 1, 1, '', '', 0, 5),
       (1172, 'C', 'hat_kryshka', '', 4000, 20, '2010-11-29 10:16:59', '', 0, 1, 1, '', '', 0, 5),
       (1174, 'C', 'dow4ovyk', 'MH', 3499, 314, '2010-11-29 10:17:08', '', 1, 1, 1, '', '', 0, 0),
       (1176, 'C', 'blazenator', 'MH', 0, 329, '2010-11-29 10:17:22',
        'command=StuffCharModifier;modifier=FlyModifier;speed=10;height=15', 0, 0, 0, '', '', 0, 0);
INSERT INTO `StuffType` (`id`, `type`, `fileName`, `placement`, `price`, `shop_id`, `created`, `info`, `hasColor`,
                         `premium`, `giftable`, `itemOfTheMonth`, `name`, `rainable`, `groupNum`)
VALUES (1178, 'C', 'bath_set', 'HI', 5000, 312, '2010-11-29 10:17:37', '', 0, 1, 1, '', '', 0, 5),
       (1180, 'C', 'face_boy_winter', 'HF', 50000, 31, '2010-11-29 10:17:52', '', 1, 0, 1, '', '', 0, 0),
       (1182, 'C', 'face_doll_winter_222', 'HF', 50000, 31, '2010-11-29 10:18:01', '', 1, 0, 1, '', '', 0, 0),
       (1184, 'C', 'face_doll_winter_111', 'HF', 50000, 31, '2010-11-29 10:18:10', '', 1, 0, 1, '', '', 0, 0),
       (1186, 'C', 'hat_victory', 'H', 4599, 20, '2010-11-29 10:18:20', '', 0, 0, 1, '', '', 0, 0),
       (1188, 'C', 'air_board_winter', 'X', 10000, 304, '2010-11-29 10:18:31',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 1, '', 'Flying Sledges', 0, 5),
       (1190, 'C', 'coat_doll_winter_6', 'M', 2300, 314, '2010-11-29 10:18:45', '', 1, 0, 1, '', '', 0, 0),
       (1192, 'C', 'coat_doll_winter_6', 'M', 1000, 314, '2010-11-29 10:18:48', '', 1, 1, 1, '', '', 0, 5),
       (1194, 'C', 'hat_hrobak', 'HF', 5600, 20, '2010-11-29 10:19:01', '', 0, 1, 1, '', '', 0, 0),
       (1196, 'C', 'hat_apple', 'HF', 1575, 20, '2010-11-29 10:19:09', '', 0, 0, 1, '', '', 0, 5),
       (1198, 'C', 'octopus', 'H', 0, 20, '2010-11-29 10:19:20', '', 0, 1, 1, '', '', 0, 5),
       (1200, 'C', 'hair_prjadka', 'H', 7900, 20, '2010-11-29 10:19:30', '', 1, 1, 1, '', '', 0, 5),
       (1202, 'C', 'dress_18', 'M', 4999, 314, '2010-11-29 10:19:38', '', 1, 1, 1, '', '', 0, 0),
       (1204, 'C', 'costum_astronavt', 'MHBL', 0, 312, '2010-11-29 10:19:53', '', 1, 0, 0, '', 'Astronaut Suit', 0, 5),
       (1206, 'C', 'dress_kryshka', 'M', 7000, 314, '2010-11-29 10:20:06', '', 0, 1, 1, '', '', 0, 5),
       (1208, 'C', 'costume_robot', 'MHBL', 0, 329, '2010-11-29 10:20:20', '', 0, 0, 0, '', 'Gold Guy', 0, 0),
       (1210, 'C', 'costume_wintersport', 'MBL', 4000, 312, '2010-11-29 10:20:35', '', 1, 0, 1, '', '', 0, 5),
       (1212, 'C', 'costume_holytreeman', 'MHL', 5000, 312, '2010-11-29 10:20:52', '', 0, 1, 1, '', '', 0, 5),
       (1214, 'C', 'hat_birdshouse', 'H', 0, 20, '2010-11-29 10:21:16', 'Rare', 0, 1, 0, '', 'Bird house', 0, 5),
       (1216, 'C', 'hat_king', '', 10000, 20, '2010-11-29 10:21:23', 'Rare', 0, 1, 0, '', '', 0, 5),
       (1218, 'C', 'hat_umbrella', 'H', 2000, 20, '2010-11-29 10:21:30', '', 0, 1, 0, '', 'Umbrella Hat!', 0, 0),
       (1220, 'C', 'bag_newyear_2', '&', 0, 305, '2010-11-29 10:21:44', '', 0, 0, 1, '', '', 0, 5),
       (1222, 'C', 'costume_suprice', 'MLB', 3000, 304, '2010-11-29 10:21:55', '', 1, 1, 1, '', '', 0, 5),
       (1224, 'C', 'hat_newyear_3', '', 0, 304, '2010-11-29 10:22:07', '', 0, 0, 0, '', 'Christmas Hat', 0, 5),
       (1226, 'C', 'dress_doll_princes', 'M', 4000, 314, '2010-11-29 10:22:22', '', 0, 1, 1, '', '', 0, 0),
       (1228, 'C', 'shirt_winter', 'M', 3000, 314, '2010-11-29 10:22:30', '', 0, 1, 1, '', '', 0, 5),
       (1230, 'C', 'dress_doll_star', 'M', 4700, 314, '2010-11-29 10:22:36', '', 0, 0, 1, '', '', 0, 5),
       (1232, 'C', 'bag_newyear_1', '&', 0, 305, '2010-11-29 10:22:48', '', 0, 0, 1, '', '', 0, 5),
       (1234, 'C', 'mask_horse', 'FH', 50000, 19, '2010-11-29 10:23:00', '', 0, 0, 1, '', '', 0, 0),
       (1236, 'C', 'hat_newyear_2', 'FH', 0, 304, '2010-11-29 10:23:17', '', 0, 0, 0, '', '', 0, 5),
       (1238, 'C', 'shapkaglass', 'HF', 1000, 20, '2010-11-29 10:23:30', '', 0, 0, 1, '', '', 0, 5),
       (1240, 'C', 'zont', 'HF', 3000, 20, '2010-11-29 10:23:42', '', 0, 1, 1, '', '', 0, 5),
       (1242, 'C', 'sunglass', 'F', 2000, 313, '2010-11-29 10:23:54', '', 0, 1, 1, '', '', 0, 0),
       (1244, 'C', 'rosegrey_hat', '', 4500, 20, '2010-11-29 10:24:03', '', 0, 1, 1, '', '', 0, 5),
       (1246, 'C', 'eyegreen', 'HML', 20000, 312, '2010-11-29 10:24:22', '', 0, 1, 1, '', '', 0, 5),
       (1248, 'C', 'duck_costume', 'HML', 4500, 312, '2010-11-29 10:24:31', '', 0, 1, 1, '', '', 0, 5),
       (1250, 'C', 'pineapplehair', 'H', 2000, 20, '2010-11-29 10:24:41', '', 1, 0, 1, '', '', 0, 5),
       (1252, 'C', 'hair_palm', 'H', 5999, 20, '2010-11-29 10:24:54', '', 1, 0, 1, '', '', 0, 5),
       (1254, 'C', 'ravlik', '&', 4999, 305, '2010-11-29 10:25:07', '', 0, 1, 1, '', '', 0, 0),
       (1256, 'C', 'lollipop', 'I', 2500, 25, '2010-11-29 10:25:18', '', 0, 1, 0, '2012091', '', 0, 5),
       (1258, 'C', 'fish', 'HML', 0, 329, '2010-11-29 10:25:46', '', 0, 0, 0, '', 'Fish suit', 0, 0),
       (1260, 'C', 'treedress', 'M', 4000, 314, '2010-11-29 10:25:59', '', 0, 0, 1, '', '', 0, 5),
       (1264, 'C', 'jaket_newyear', 'M', 10000, 304, '2010-11-29 10:26:22', '', 0, 1, 1, '', '', 0, 5),
       (1266, 'C', 'hat_flowers', 'H', 4000, 20, '2010-11-29 10:26:33', '', 1, 1, 1, '', '', 0, 0),
       (1268, 'C', 'hat_newyear_1', 'HF', 7500, 304, '2010-11-29 10:26:41', '', 0, 1, 0, '', '', 0, 5),
       (1274, 'C', 'octopus2', 'H', 5000, 305, '2010-11-29 10:53:24', '', 0, 1, 1, '', 'Octopus Hat', 0, 0),
       (1278, 'C', 'magic_santa', '&', 10000, 324, '2010-12-22 15:15:06', 'command=MagicItem;name=santa_fly', 0, 0, 0,
        '', '', 0, 5),
       (1280, 'C', 'magic_santa1', '&', 500, 304, '2010-12-24 12:10:08', 'command=MagicItem;name=santa_fly', 0, 1, 0,
        '', '', 0, 5),
       (1284, 'C', 'bag_snowflake', '&', 2000, 305, '2010-12-31 23:06:56', '', 0, 1, 1, '', 'Snow flake', 0, 5),
       (1286, 'C', 'snowmobile', 'X', 0, 15, '2010-12-31 23:07:14',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=2', 0, 0, 0, '', 'Snow mobile', 0, 5),
       (1288, 'C', 'hat_ski', '', 0, 20, '2010-12-31 23:19:48', 'Rare', 0, 1, 0, '', 'Hat ski', 0, 5),
       (1290, 'C', 'rose', 'I', 1900, NULL, '2011-01-31 15:57:59', '', 0, 1, 1, '', 'Rose', 0, 5),
       (1292, 'C', 'heart_bag', '&', 0, NULL, '2011-01-31 15:58:53', 'Rare', 0, 1, 1, '', 'Heart bag', 0, 5),
       (1294, 'C', 'heart_bag', 'X', 2750, NULL, '2011-01-31 15:59:29', '', 0, 1, 1, '', 'heart_ball_basket', 0, 5),
       (1296, 'C', 'heart_ball_basket2', 'X', 10000, 15, '2011-01-31 16:00:16',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=17', 0, 1, 0, '', '', 0, 5),
       (1298, 'C', 'heart_ball_basket2', '', 0, NULL, '2011-01-31 16:05:15',
        'command=StuffCharModifier;modifier=BoardModifier;speed=8;height=10', 0, 1, 1, '', '', 0, 5),
       (1300, 'C', 'heart_ball_basket3', 'X', 0, NULL, '2011-01-31 16:15:41',
        'command=StuffCharModifier;modifier=BoardModifier;speed=8;height=10', 0, 1, 1, '', 'Heart balloon', 0, 5),
       (1302, 'C', 'chopper', 'X', 0, 329, '2011-02-07 10:39:18',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=1', 1, 0, 0, '', 'Chopper', 0, 0),
       (1304, 'C', 'hair_afro', 'H', 3000, 20, '2011-02-07 10:40:27', '', 1, 0, 1, '', 'Afro', 0, 0),
       (1306, 'C', 'air_board_jet', 'X', 5000, 15, '2011-02-09 11:37:01',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=10', 0, 0, 1, '', '', 0, 5),
       (1310, 'C', 'one_hand_bag', 'I', 4000, 305, '2011-02-10 09:59:07', '', 0, 0, 1, '', '', 0, 0),
       (1312, 'C', 'futbolka_tron_theme', 'M', 2100, 314, '2011-02-10 09:59:26', '', 1, 1, 1, '', '', 0, 0);
INSERT INTO `StuffType` (`id`, `type`, `fileName`, `placement`, `price`, `shop_id`, `created`, `info`, `hasColor`,
                         `premium`, `giftable`, `itemOfTheMonth`, `name`, `rainable`, `groupNum`)
VALUES (1314, 'C', 'futbolka_cut', 'M', 2000, 314, '2011-02-10 09:59:36', '', 1, 0, 1, '', '', 0, 0),
       (1316, 'C', 'dress_19', 'MNL', 10000, 314, '2011-02-10 10:00:08', '', 0, 0, 1, '', '', 0, 0),
       (1318, 'C', 'cylinder2', '', 5000, 20, '2011-02-10 10:00:29', '', 0, 0, 1, '', '', 0, 0),
       (1320, 'C', 'cane', 'I', 4000, 305, '2011-02-10 10:00:38', '', 0, 1, 0, '', 'cane', 0, 0),
       (1322, 'C', 'segway', 'X', 30000, 15, '2011-02-11 11:28:35',
        'command=StuffCharModifier;modifier=BoardModifier;speed=14;height=1', 1, 1, 0, '', '', 0, 5),
       (1324, 'C', 'magic_heart_wing', '&I', 10000, 324, '2011-02-14 09:47:48', 'command=MagicItem;name=heart_wing', 0,
        0, 0, '', 'Flying hearts', 0, 5),
       (1326, 'C', 'bionic_hand', 'I', 2000, 305, '2011-02-14 09:48:30', '', 0, 1, 0, '', 'Biomechanical hand', 0, 5),
       (1328, 'C', 'pterodaktyl', 'X', 100000, 15, '2011-02-15 10:09:41',
        'command=StuffCharModifier;modifier=BoardModifier;speed=13;height=30', 1, 1, 0, '', '', 0, 5),
       (1330, 'C', 'fan_hand', 'I', 3000, 305, '2011-02-15 10:54:26', '', 1, 0, 1, '', '', 0, 0),
       (1332, 'C', 'shirt2', 'M', 4000, 314, '2011-02-17 11:57:07', '', 1, 0, 1, '', '', 0, 0),
       (1334, 'C', 'hair_curly', 'H', 4000, 20, '2011-02-17 11:57:29', '', 1, 0, 1, '', '', 0, 0),
       (1336, 'C', 'air_board_dragonfly', 'X', 30000, 15, '2011-02-18 14:57:45',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=3', 0, 0, 0, '', '', 0, 5),
       (1338, 'C', 'air_board_dragonfly', 'X', 0, 15, '2011-02-18 14:59:39',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=3', 0, 0, 0, '', '', 0, 5),
       (1340, 'C', 'air_board_dragonfly2', 'X', 1000, 15, '2011-02-18 15:05:20',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=3', 0, 0, 0, '', '', 0, 5),
       (1342, 'C', 'bicycle', 'X', 2500, 15, '2011-02-21 10:40:21',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=1', 1, 0, 0, '', '', 0, 5),
       (1344, 'C', 'bicycle', 'X', 0, 15, '2011-02-21 10:41:21',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=1', 0, 0, 0, '', '', 0, 5),
       (1346, 'C', 'bicycle2', 'X', 100000, 15, '2011-02-21 10:47:19',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=1', 0, 0, 0, '', '', 0, 5),
       (1348, 'C', 'magic_sun_ray', '&I', 10000, 324, '2011-03-01 09:06:15', 'command=MagicItem;name=defrosting_ice', 0,
        0, 0, '', 'Melting icicle', 0, 5),
       (1350, 'C', 'butterfly_net', 'I', 2050, 305, '2011-03-01 09:06:23', '', 0, 1, 1, '', 'Butterfly net', 0, 5),
       (1352, 'C', 'jumper_grasshopper', 'X', 0, 15, '2011-03-01 09:06:29',
        'command=StuffCharModifier;modifier=TeleportModifier;', 0, 1, 0, '', 'Grasshopper', 0, 5),
       (1358, 'C', 't_rex', 'X', 100000, 15, '2011-03-07 14:19:53',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=1', 0, 1, 0, '', '', 0, 5),
       (1360, 'C', 'helicopter', '&MLBNHFX', 5000, 15, '2011-03-09 14:17:40',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=70', 1, 0, 0, '', '', 0, 5),
       (1362, 'C', 'air_board_shark', 'X', 0, 329, '2011-03-09 14:17:52',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=3', 0, 0, 0, '', '', 0, 0),
       (1364, 'C', 't_rex2', 'X', 60000, 15, '2011-03-09 16:00:52',
        'command=StuffCharModifier;modifier=BoardModifier;speed=5;height=1', 0, 1, 0, '', '', 0, 5),
       (1366, 'C', 'air_board_shark1', 'X', 5000, 15, '2011-03-09 16:01:03',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 1, 0, 1, '', '', 0, 5),
       (1368, 'C', 'helicopter', 'X', 0, 329, '2011-03-10 11:36:05',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=40', 1, 0, 0, '', '', 0, 0),
       (1370, 'C', 'helicopter2', '&MLBNHFX', 0, 15, '2011-03-10 11:36:24',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=30', 1, 0, 0, '', '', 0, 5),
       (1372, 'C', 'magic_patric', '&I', 10000, 324, '2011-03-14 14:19:16', 'command=MagicItem;name=patric', 0, 0, 0,
        '', '', 0, 5),
       (1374, 'C', 'hat_hair', 'H', 5000, 20, '2011-03-14 14:19:42', '', 1, 0, 1, '', '', 0, 5),
       (1376, 'C', 'Cleaner_pot', 'I', 0, 305, '2011-03-16 11:25:42', '', 0, 0, 1, '', '', 0, 5),
       (1378, 'C', 'Cleaner_board', 'X', 0, 15, '2011-03-16 13:59:21',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=10', 0, 0, 1, '', '', 0, 5),
       (1380, 'C', 'bath', 'XH', 100000, 15, '2011-03-24 15:42:18',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 0, 0, '', '', 0, 5),
       (1382, 'C', 'submarine', 'X', 0, 15, '2011-03-31 16:17:06',
        'command=StuffCharModifier;modifier=BoardModifier;speed=10;height=5', 0, 1, 0, '', 'Submarine', 0, 5),
       (1384, 'C', 'fools_day_hat', 'H', 0, 20, '2011-03-31 16:17:26', 'Rare', 0, 1, 0, '', 'Fools day hat', 0, 5),
       (1386, 'C', 'bicycle_One_wheel', 'X', 0, 15, '2011-03-31 16:17:35',
        'command=StuffCharModifier;modifier=BoardModifier;speed=8;height=2', 0, 1, 0, '', 'One wheel bicycle', 0, 5),
       (1388, 'C', 'plane', '&MLBNHFX', 0, 15, '2011-04-30 21:11:34',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=70', 0, 1, 0, '', 'Plane', 0, 5),
       (1390, 'C', 'bag_umbrella', '&', 1000, 305, '2011-04-30 21:12:06', '', 0, 1, 1, '', 'Umbrella', 0, 5),
       (1392, 'C', 'air_board_ball', 'X', 0, 15, '2011-04-30 21:12:17',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 0, '', 'Ball board', 0, 5),
       (1394, 'C', 'cylinder', '', 1000, 20, '2011-05-29 08:38:53', '', 0, 0, 1, '', '', 0, 5),
       (1396, 'C', 'hat_feather', '', 2121, 20, '2011-05-31 20:43:32', '', 0, 1, 1, '', 'Hat Feather', 0, 0),
       (1398, 'C', 'air_board1_surf', 'X', 0, 15, '2011-05-31 20:44:00',
        'command=StuffCharModifier;modifier=FlyModifier;speed=10;height=5', 0, 1, 0, '', 'Air board', 0, 5),
       (1400, 'C', 'air_board_beach_stuff', 'X', 0, 15, '2011-05-31 20:44:37',
        'command=StuffCharModifier;modifier=BoardModifier;speed=11;height=3', 0, 1, 0, '', 'Beach board', 0, 5),
       (1402, 'C', 'air_board_medusa', 'X', 12000, 15, '2011-06-22 08:52:01',
        'command=StuffCharModifier;modifier=BoardModifier;speed=15;height=10', 0, 1, 1, '', '', 0, 5),
       (1404, 'C', 'hair_6', 'H', 4000, 20, '2011-06-22 08:53:17', '', 1, 1, 1, '', '', 0, 0),
       (1406, 'C', 'water_pistol', 'I', 5000, 305, '2011-06-22 08:54:25', '', 0, 1, 1, '', '', 0, 5),
       (1408, 'C', 'Sandwich', 'I', 8000, 305, '2011-07-01 08:03:47', '', 0, 1, 1, '', 'Sandwich', 0, 0),
       (1410, 'C', 'air_board_peacock', 'X', 0, 15, '2011-07-01 08:04:18',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 0, 1, 0, '', 'Peacock Board', 0, 5),
       (1412, 'C', 'boomerang', 'I', 10000, 324, '2011-07-01 08:04:41', 'command=MagicItem;name=boomerang', 0, 0, 0, '',
        'Boomerang', 0, 5),
       (1414, 'C', 'wings_2', '&', 5000, 305, '2011-07-20 14:45:48', '', 1, 0, 1, '', '', 0, 0),
       (1416, 'C', 'hair_7', 'H', 4000, 20, '2011-07-20 14:46:09', '', 1, 0, 1, '', '', 0, 0),
       (1418, 'C', 'fishing', 'I', 5000, 305, '2011-07-20 14:46:29', '', 0, 0, 1, '', '', 0, 0),
       (1420, 'C', '_empty', 'X', 0, 41, '2011-08-15 03:33:22', 'command=StuffC', 1, 1, 0, '', 'Flame Boots', 0, 5),
       (1422, 'C', '_empty', 'X', 0, 41, '2011-08-15 03:33:30', 'command=StuffC', 1, 1, 0, '', 'Flame Boots', 0, 5),
       (1423, 'C', '_empty', '&I', 0, 41, '2011-08-19 11:07:09', '', 0, 1, 0, '', '', 0, 5),
       (1428, 'C', 'magic_star', '&I', 10000, 324, '2011-08-20 14:20:09',
        'command=MagicStuffItemRain;fName=magicStar;count=5', 0, 0, 0, '', '', 0, 5),
       (1430, 'C', 'magic_bubble', '&I', 10000, 324, '2011-08-20 14:24:51', 'command=MagicItem;name=bubble', 0, 0, 0,
        '', '', 0, 5),
       (1432, 'C', 'costume_egg', 'MLBNF', 2600, 312, '2011-09-04 08:47:25', '', 0, 1, 1, '', '', 0, 5),
       (1433, 'C', 'costume_ice cream', 'MLBNF', 4000, 312, '2011-09-04 08:53:32', '', 0, 1, 1, '', '', 0, 0),
       (1434, 'C', 'dress_buterfly', 'M', 1000, 314, '2011-09-04 08:57:42', '', 1, 1, 1, '', '', 0, 5),
       (1435, 'C', 'hair_johnny_bravo', 'H', 600, 20, '2011-09-04 09:12:42', '', 1, 1, 1, '', '', 0, 5),
       (1436, 'C', 'hat_bird', '', 5000, 20, '2011-09-04 09:13:49',
        'command=StuffCharModifier;modifier=BoardModifier;speed=9;height=10', 1, 0, 0, '', '', 0, 5),
       (1437, 'C', 'hat_halloween_1', '', 600, 20, '2011-09-04 09:40:48',
        'Rained at halloween (2011)\rRained at halloween (2012)', 0, 1, 0, '', '', 0, 5),
       (1438, 'C', 'costume_15', 'M', 1600, 314, '2011-09-04 11:38:44', '', 1, 0, 1, '', '', 0, 5),
       (1439, 'C', 'elf_boy_costum', 'M', 1000, 314, '2011-09-04 11:40:13', '', 1, 0, 1, '', '', 0, 0),
       (1440, 'C', 'elve_doll_33', 'F', 50000, 31, '2011-09-04 11:40:46', '', 1, 0, 1, '', '', 0, 5),
       (1441, 'C', 'face_boy_8', 'F', 7000, 19, '2011-09-04 11:41:41', '', 1, 1, 0, '', '', 0, 5),
       (1442, 'C', 'face_boy_13', 'F', 50000, 31, '2011-09-04 11:42:01', '', 0, 0, 1, '', '', 0, 5),
       (1443, 'C', 'face_doll_15', 'F', 7000, 31, '2011-09-04 11:42:32', '', 0, 0, 1, '', '', 0, 5),
       (1444, 'C', 'face_doll_14', 'F', 50000, 31, '2011-09-04 11:42:49', '', 1, 0, 1, '', '', 0, 5),
       (1445, 'C', 'face_doll_13', 'F', 50000, 31, '2011-09-04 11:43:02', '', 0, 0, 1, '', '', 0, 0),
       (1446, 'C', 'goth_boy_2', 'M', 1500, 314, '2011-09-04 11:46:44', '', 1, 0, 1, '', '', 0, 0),
       (1447, 'C', 'goth_boy_1', 'M', 1500, 312, '2011-09-04 11:46:48', '', 0, 1, 1, '', '', 0, 0),
       (1448, 'C', 'hair_bantik', 'H', 3000, 20, '2011-09-04 11:47:19', '', 1, 0, 1, '', '', 0, 0),
       (1449, 'C', 'hat_boy_1', 'H', 3000, 20, '2011-09-04 11:48:02', '', 1, 0, 1, '', '', 0, 5),
       (1450, 'C', 'hat_boy_5', 'H', 1500, 20, '2011-09-04 11:48:42', '', 1, 0, 1, '', '', 0, 0),
       (1451, 'C', 'hat_girl_8', 'H', 2000, 20, '2011-09-04 11:50:44', '', 1, 0, 1, '', '', 0, 0),
       (1452, 'C', 'hat_halloween_1', '', 1500, 20, '2011-09-04 11:51:09', '', 0, 1, 0, '', '', 0, 5),
       (1453, 'C', 'hat_origami', 'H', 800, 20, '2011-09-04 11:51:45', '', 1, 0, 1, '', '', 0, 0),
       (1454, 'C', 'hat_TV', 'H', 2500, 25, '2011-09-04 11:52:22', '', 0, 1, 0, '2011111', 'TV Head', 0, 5),
       (1455, 'C', 'shirt_boy_18', 'M', 1500, 314, '2011-09-04 12:05:48', '', 1, 0, 1, '', '', 0, 0),
       (1456, 'C', 'shirt_boy_9', 'M', 1500, 314, '2011-09-04 12:06:13', '', 1, 0, 1, '', '', 0, 5),
       (1457, 'C', '_empty', 'B', 0, 41, '2011-09-04 12:49:30', '', 0, 1, 0, '', 'Fire Shoes', 0, 5),
       (1458, 'C', 'elf_dress', 'M', 3500, 314, '2011-09-05 10:39:19', '', 0, 1, 1, '', '', 0, 0),
       (1459, 'C', 'wings_bat', '&', 20000, 305, '2011-09-06 06:10:50',
        'command=StuffCharModifier;modifier=FlyModifier;speed=14;height=25', 0, 0, 1, '', '', 0, 0),
       (1461, 'C', 'beads', '', 700, 315, '2011-10-07 21:11:34', '', 1, 1, 1, '', '', 0, 0),
       (1481, 'C', 'futbolka_foxik', 'M', 0, 326, '2011-10-12 14:24:49', 'Foxik', 1, 0, 0, '', '', 0, 5),
       (1482, 'C', 'futbolka_p', 'M', 0, 326, '2011-10-12 14:41:38', 'Puffles', 1, 0, 0, '', '', 0, 5),
       (1483, 'C', 'Sleepy', '', 0, 41, '2011-10-13 16:08:43', '', 1, 0, 0, '', '', 0, 5),
       (1484, 'C', 'Sleepy', 'BLMHFN', 0, 41, '2011-10-13 16:09:27', '', 1, 0, 0, '', 'Sleepy', 0, 5),
       (1485, 'C', 'Sleepy', 'BLMHFN', 0, 41, '2011-10-13 16:09:36', '', 1, 0, 0, '', 'Sleepy', 0, 5),
       (1487, 'C', 'swimming_ring', '', 0, 41, '2011-10-13 17:27:53', 'Rare', 0, 0, 0, '', '', 0, 5),
       (1488, 'C', 'agent_girl', 'HMLBN', 5000, 32, '2011-10-16 14:22:22', '', 0, 0, 0, '', 'Agents girl Suit!', 0, 0),
       (1489, 'C', 'mask_shark', 'H', 2500, 25, '2011-10-22 17:35:14', '', 0, 1, 0, '2012091', '', 0, 5),
       (1490, 'C', 'flag_pumpkin', '#', 1200, 305, '2011-10-23 14:13:25', '', 1, 0, 1, '', '', 0, 5),
       (1491, 'C', 'pumpkin_mask', 'F', 750, 19, '2011-10-23 15:15:07', 'Rain at Halloween party', 0, 0, 1, '',
        'Pumpkin Mask', 0, 5),
       (1492, 'C', 'costume_witch', 'MBHLF', 0, 41, '2011-10-23 15:21:26', '', 0, 0, 0, '', '', 0, 5),
       (1493, 'C', 'costume_thanksgivingday', 'MLBHF&', 4000, 312, '2011-10-23 15:24:11', 'Rare', 0, 1, 0, '',
        'Thanksgiving Costume', 0, 5),
       (1494, 'C', 'costume_drakula_boy', 'MHLF', 2870, 312, '2011-10-23 15:55:23', '', 0, 0, 0, '', '', 0, 5),
       (1495, 'C', 'costume_zombie', 'MBHLF', 0, 41, '2011-10-23 15:57:23', '', 0, 1, 0, '', '', 0, 5),
       (1496, 'C', 'mask_ice cream', '', 3500, 20, '2011-10-23 16:21:40', '', 0, 1, 1, '', '', 0, 0),
       (1497, 'C', 'mask_aladdin', 'HF', 1600, 19, '2011-10-23 16:25:28', '', 1, 0, 1, '', '', 0, 5),
       (1498, 'C', 'mask_aladdin', 'HF', 2000, 19, '2011-10-23 16:25:46', '', 1, 1, 1, '', '', 0, 5),
       (1499, 'C', 'face_boy_14', 'HF', 50000, 31, '2011-10-23 16:38:21', '', 0, 0, 1, '', '', 0, 0),
       (1500, 'C', 'shirt_boy_16', 'M', 1250, 314, '2011-10-23 16:41:18', '', 0, 0, 1, '', '', 0, 0),
       (1501, 'C', 't-shirt_beer', 'M', 400, 314, '2011-10-23 16:43:37', '', 0, 0, 1, '', '', 0, 5),
       (1502, 'C', 'bag_pencil', '&', 1000, 305, '2011-10-23 16:48:49', '', 1, 1, 1, '', '', 0, 0),
       (1503, 'C', 'bag_roll', '&', 1000, 305, '2011-10-23 16:49:45', '', 0, 1, 1, '', '', 0, 5),
       (1504, 'C', 'bag_water-melon', '&', 1500, 305, '2011-10-23 16:53:11', '', 0, 0, 1, '', 'Pumpkin backpack', 0, 5),
       (1505, 'C', 'dress_15', 'M', 1700, 314, '2011-10-23 16:57:07', '', 1, 0, 1, '', '', 0, 5),
       (1506, 'C', 'hair_obruch', 'H', 800, 20, '2011-10-23 17:48:26', '', 1, 0, 1, '', '', 0, 5),
       (1507, 'C', 'pencilbag', '&', 0, 315, '2011-10-23 18:04:14', '', 0, 1, 1, '', '', 0, 5),
       (1508, 'C', 'shorty_1', 'L', 900, 306, '2011-10-23 18:08:09', '', 1, 0, 1, '', '', 0, 0),
       (1509, 'C', 'skirt_3', 'L', 2000, 306, '2011-10-23 18:10:33', '', 1, 1, 1, '', '', 0, 5),
       (1510, 'C', 'sweater_blue', 'M', 4500, 314, '2011-10-23 18:54:08', '', 0, 0, 1, '', '', 0, 0),
       (1520, 'C', 'shirt_arrow', 'M', 500, 314, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1546, 'R', '_empty', '', 0, 41, '2011-11-03 10:07:51', '', 0, 1, 0, '', '', 0, 0),
       (1547, 'C', 'snowgirl', 'HML', 2500, 25, '2011-11-03 21:27:33', '', 0, 1, 0, '2011121', 'Mrs. Claus', 0, 5),
       (1550, 'C', 'hat_neru', 'H', 800, 20, '2011-11-04 21:02:42', 'Rare', 0, 0, 1, '', 'Indian Hat', 0, 5),
       (1551, 'C', 'flag_india', '#', 1000, 305, '2011-11-04 21:03:32', 'Indian Flag', 0, 0, 1, '', 'Indian Flag', 0,
        5),
       (1559, 'R', '_empty', '', 0, 41, '2011-11-09 17:39:59', '', 0, 0, 0, '', '', 0, 0),
       (1560, 'R', '_empty', '', 0, 41, '2011-11-09 17:40:15', '', 0, 0, 0, '', '', 0, 0),
       (1561, 'R', '_empty', '', 0, 41, '2011-11-09 17:40:36', '', 0, 1, 0, '', '', 0, 0),
       (1562, 'R', '_empty', '', 0, 41, '2011-11-09 17:43:14', '', 0, 0, 0, '', '', 0, 0),
       (1563, 'R', '_empty', '', 0, 41, '2011-11-09 17:44:50', '', 0, 0, 0, '', '', 0, 0),
       (1564, 'R', '_empty', '', 0, 41, '2011-11-09 17:44:52', '', 0, 0, 0, '', '', 0, 0),
       (1565, 'R', '_empty', '', 0, 41, '2011-11-09 17:44:52', '', 0, 1, 0, '', '', 0, 0),
       (1566, 'R', '_empty', '', 0, 41, '2011-11-09 17:44:54', '', 0, 0, 0, '', '', 0, 0),
       (1567, 'R', '_empty', '', 0, 41, '2011-11-09 17:46:32', '', 0, 0, 0, '', '', 0, 0),
       (1568, 'R', '_empty', '', 0, 41, '2011-11-09 17:46:32', '', 0, 0, 0, '', '', 0, 5),
       (1569, 'R', '_empty', '', 0, 41, '2011-11-09 17:46:33', '', 0, 1, 0, '', '', 0, 0),
       (1570, 'R', '_empty', '', 0, 41, '2011-11-09 17:46:33', '', 0, 0, 0, '', '', 0, 5),
       (1572, 'R', '_empty', '', 0, 41, '2011-11-09 18:35:22', '', 0, 0, 0, '', '', 0, 0),
       (1573, 'R', '_empty', '', 0, 41, '2011-11-09 18:38:52', '', 0, 1, 0, '', '', 0, 0),
       (1574, 'C', 'flag_usa', '#', 1111, 305, '2011-11-10 20:14:32', 'Verterans Day USA Flag', 0, 0, 1, '', '', 0, 5),
       (1575, 'C', 'flag_usa', '#', 111, 305, '2011-11-10 20:14:48', 'Verterans Day USA Flag', 0, 0, 1, '', '', 0, 5),
       (1576, 'C', 'nichos_suit', 'M', 14000, 312, '2011-11-11 17:35:28', '', 0, 1, 1, '', '', 0, 0),
       (1577, 'C', 'sharphik_SClaus', '', 0, 304, '2011-11-13 03:16:45', '', 0, 0, 0, '', '', 0, 5),
       (1585, 'C', '_empty', 'X', 0, 41, '2011-10-08 12:56:52',
        'command=StuffCharModifier;modifier=BoardModifier;speed=60;height=12', 0, 1, 0, '', 'Fire Shoes', 0, 5),
       (1589, 'C', 'air_board_winter', 'X', 0, 304, '2011-12-02 18:29:14',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=10', 0, 0, 0, '', 'Faster Winter Board', 0,
        5),
       (1603, 'C', 'jet_pack_3', '&X', 2500, 15, '2011-12-05 15:02:50',
        'command=StuffCharModifier;modifier=FlyModifier;speed=22;height=25', 0, 1, 0, '', 'Jet Pack 3', 0, 5),
       (1605, 'C', 'agent', 'HMLBN', 5000, 32, '2011-12-09 13:53:49', '', 0, 0, 0, '', 'Agents boy Suit!', 0, 0),
       (1610, 'F', 'snowman', '', 1100, 304, '2011-12-11 04:49:49', '', 0, 0, 0, '', '', 0, 5),
       (1616, 'C', 'magic_santa1', 'H&', 2500, 25, '2011-12-13 16:45:09', 'command=MagicItem;name=santa_fly', 0, 1, 0,
        'Dec11BON', 'Santa Magic', 0, 5),
       (1650, 'C', 'magic_helloween', 'I&', 0, 41, '2012-01-04 12:56:18', 'command=MagicItem;name=pumkin_jump', 0, 0, 0,
        '', '', 0, 5),
       (1669, 'C', 'remote_control', 'I', 0, 305, '2012-01-25 13:37:35', 'Prize', 0, 0, 0, '', '', 0, 5),
       (1680, 'F', 'umbrella', '', 6400, 8, '2012-01-30 18:12:47', '', 0, 0, 1, '', '', 0, 1),
       (1684, 'C', '_empty', '&', 0, 41, '2012-01-31 00:42:26', '', 1, 0, 0, '', '', 0, 0),
       (1686, 'F', '_empty', '', 0, 41, '2012-01-31 00:43:21', '', 0, 1, 0, '', '', 0, 5),
       (1689, 'C', 'magic_heart', '&I', 2500, 25, '2012-02-01 21:06:53', 'command=MagicItem;name=hearts', 0, 1, 0,
        'Feb12BON', 'Heart Magic', 0, 5),
       (1698, 'C', 'magic_patric', '&I', 2500, 25, '2012-02-27 20:33:40', 'command=MagicItem;name=patric', 0, 1, 0,
        'Mar12BON', 'Shamrock Wings', 0, 5),
       (1699, 'C', 'air_board_pizza', 'X', 0, 15, '2012-03-04 07:26:23',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=15', 0, 0, 0, '', '', 0, 5),
       (1700, 'C', 'air_board_clock', 'X', 0, 15, '2012-03-04 07:34:08',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=10', 0, 0, 0, '', '', 0, 5),
       (1701, 'C', 'air_board_cd', 'X', 0, 15, '2012-03-04 07:34:32',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=10', 0, 0, 1, '', '', 0, 5),
       (1702, 'C', 'air_board_flower', 'X', 0, 15, '2012-03-04 07:35:14',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=10', 0, 0, 1, '', '', 0, 5),
       (1703, 'C', 'air_board_flower', 'X', 0, 15, '2012-03-04 07:36:41',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=10', 0, 0, 1, '', '', 0, 5),
       (1704, 'C', '_empty', '', 0, 41, '2012-03-04 07:37:23',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=10', 0, 0, 0, '', '', 0, 5),
       (1705, 'C', '_empty', 'X', 0, 41, '2012-03-04 07:37:25',
        'command=StuffCharModifier;modifier=BoardModifier;speed=17;height=10', 0, 0, 0, '', '', 0, 5),
       (1907, 'C', 'rose', 'I', 10000, 305, '2012-10-18 09:29:29', 'Rare', 0, 1, 0, '', 'Rose', 0, 5),
       (1908, 'C', 'fireboots', 'X', 9300, 32, '2013-01-29 14:00:44',
        'command=StuffCharModifier;modifier=FlyModifier;speed=16;height=12', 1, 1, 0, '0', 'Speedy Shoes', 0, 0),
       (1909, 'C', 'fireboots', 'X', 9300, 32, '2013-01-29 14:00:45',
        'command=StuffCharModifier;modifier=FlyModifier;speed=26;height=12', 1, 1, 0, '0', 'Speedy Shoes', 0, 1),
       (1910, 'F', 'bed', '', 500, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1911, 'F', 'chair1', '', 350, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1912, 'F', 'chair2', '', 400, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1913, 'F', 'chair3', '', 475, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1914, 'F', 'sofa', '', 500, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1915, 'F', 'fountain', '', 450, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1916, 'F', 'bookshelf', '', 350, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1917, 'F', 'table1', '', 425, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1918, 'F', 'table2', '', 450, 8, NULL, '', 1, 0, 1, '', '', 0, 0),
       (1919, 'F', 'bed3dRed', '', 2000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1920, 'F', 'bed3dGreen', '', 1000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1921, 'F', 'bed3dBlue', '', 1000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1922, 'F', 'bed3dOrange', '', 1000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1923, 'F', 'bed3dWhite', '', 1000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1924, 'F', 'bed3dSilver', '', 1000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1925, 'F', 'chair3dGreen', '', 450, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1926, 'F', 'chair3dOrange', '', 450, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1927, 'F', 'chair3dRed', '', 900, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1928, 'F', 'chair3dSilver', '', 450, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1929, 'F', 'chair3dWhite', '', 450, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1930, 'F', 'divan3dBlue', '', 750, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1931, 'F', 'divan3dGreen', '', 750, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1932, 'F', 'divan3dOrange', '', 750, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1933, 'F', 'divan3dRed', '', 1500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1934, 'F', 'divan3dSilver', '', 750, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1935, 'F', 'divan3dWhite', '', 750, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1936, 'F', 'divandi3dBlue', '', 500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1937, 'F', 'divandi3dGreen', '', 500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1938, 'F', 'divandi3dOrange', '', 500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1939, 'F', 'divandi3dRed', '', 1000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1940, 'F', 'divandi3dSilver', '', 500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1941, 'F', 'divandi3dWhite', '', 500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1942, 'F', 'safe3dBlue', '', 400, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1943, 'F', 'safe3dGreen', '', 400, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1944, 'F', 'safe3dOrange', '', 400, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1945, 'F', 'safe3dRed', '', 800, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1946, 'F', 'safe3dSilver', '', 400, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1947, 'F', 'safe3dWhite', '', 400, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1948, 'F', 'shafka3dBlue', '', 500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1949, 'F', 'shafka3dGreen', '', 500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1950, 'F', 'sofa3dBlue', '', 550, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1951, 'F', 'sofa3dGreen', '', 550, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1952, 'F', 'sofa3dOrange', '', 550, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1953, 'F', 'sofa3dRed', '', 1100, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1954, 'F', 'sofa3dSilver', '', 550, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1955, 'F', 'sofa3dWhite', '', 550, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1956, 'F', 'stereo3dBlue', '', 2000, 8, NULL, 'DUPLICATE', 0, 0, 1, '', '', 0, 5),
       (1957, 'F', 'stereo3dGreen', '', 2000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1958, 'F', 'stereo3dOrange', '', 2000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1959, 'F', 'stereo3dRed', '', 4000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1960, 'F', 'stereo3dSilver', '', 2000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1961, 'F', 'stereo3dWhite', '', 2000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1962, 'F', 'tumba3dBlue', '', 1500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1963, 'F', 'tumba3dGreen', '', 1500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1964, 'F', 'tumba3dOrange', '', 1500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1965, 'F', 'tumba3dRed', '', 3000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1966, 'F', 'tumba3dSilver', '', 1500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1967, 'F', 'tumba3dWhite', '', 1500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1968, 'F', 'game3drobo', '', 3000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1969, 'F', 'game3dasteroid', '', 3000, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1970, 'F', 'game3dchoboard', '', 3250, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1971, 'F', 'game3dcrab', '', 2500, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1972, 'F', 'game3dpinball', '', 2750, 8, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1973, 'F', 'globus', '', 0, 8, NULL, '', 0, 0, 1, '', '', 0, 5),
       (1974, 'F', 'tree', '', 6777, 8, '2011-12-11 04:56:54', '', 0, 0, 1, '', '', 0, 1),
       (1975, 'F', 'table1', '', 100, 8, '2012-01-30 18:11:20', '', 0, 1, 1, '', '', 0, 0),
       (1976, 'F', 'heart_pillow', '', 2397, 8, '2012-01-30 18:12:02', '', 0, 1, 1, '', '', 0, 1),
       (1977, 'F', 'umbrella', '', 6400, 8, '2012-01-30 18:12:47', '', 0, 0, 1, '', '', 0, 1),
       (1978, 'F', 'lamp', '', 4800, 8, '2012-01-31 00:42:59', '', 0, 0, 1, '', '', 0, 1),
       (1979, 'F', 'pot2', '', 1000, 8, '2012-03-10 20:55:53', '', 0, 0, 1, '', '', 0, 1),
       (1980, 'F', 'pot1', '', 3840, 8, '2012-03-10 20:56:31', '', 0, 0, 1, '', '', 0, 1),
       (1981, 'F', 'plant', '', 4100, 8, '2012-04-12 21:05:09', '', 0, 0, 1, '', '', 0, 1),
       (1982, 'F', 'party_light_red', '', 800, 8, '2012-09-09 04:19:02', '', 0, 1, 0, '', '', 0, 1),
       (1983, 'F', 'party_light_green', '', 800, 8, '2012-09-09 04:19:42', '', 0, 1, 0, '', '', 0, 1),
       (1984, 'H', 'home1', '', 5000, 9, NULL, '', 1, 1, 1, '', '', 0, 0),
       (1985, 'H', 'home2', '', 6000, 9, NULL, '', 0, 1, 1, '', '', 0, 0),
       (1986, 'H', 'home3', '', 7500, 9, NULL, '', 0, 1, 1, '', '', 0, 0),
       (1987, 'H', 'home4', '', 5000, 9, NULL, '', 0, 1, 1, '', '', 0, 0),
       (1988, 'H', 'shower', '', 5000, 9, NULL, '', 0, 0, 1, '', '', 0, 0),
       (1989, 'H', 'home5', '', 5500, 9, '2011-12-11 06:48:21', '', 1, 1, 1, '', '', 0, 5),
       (1990, 'S', 'magicSpeed', 'C', 30, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1991, 'S', 'magicBottle', '', 40, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1992, 'S', 'magicBlur', '', 90, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1993, 'S', 'magicBubble', '', 5, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1994, 'S', 'magicStar', '', 25, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1995, 'S', 'magicBalls', '', 10, 2, NULL, '', 0, 0, 1, '', '', 1, 5),
       (1996, 'S', 'magicScale', '', 85, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1997, 'S', 'magicBubbleBlue', '', 5, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1998, 'S', 'magicBubbleYellow', '', 5, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (1999, 'S', 'magicBubbleGreen', '', 50, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (2000, 'S', 'magicLantz', '', 300, 2, NULL, '', 0, 0, 1, '', '', 1, 0),
       (2001, 'S', 'magicbubbleheart', '', 7, 2, NULL, '', 0, 1, 1, '', '', 1, 5),
       (2002, 'S', 'magicKite', '', 0, 2, '2011-10-12 08:47:51', '', 0, 1, 1, '', '', 1, 5),
       (2003, 'S', 'magicReset', '', 30, 2, '2011-10-12 08:49:56', '', 0, 1, 1, '', '', 1, 1),
       (2004, 'S', 'magicKite', '', 0, 2, '2012-01-07 21:27:42', '', 0, 0, 1, '', '', 1, 5),
       (2005, 'S', 'magicCharly', '', 30, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2006, 'S', 'magicToxic', '', 25, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2007, 'S', 'magicLarge', '', 35, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2008, 'S', 'magicHue', '', 15, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2009, 'S', 'magicBevel', '', 40, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2010, 'S', 'magicBlend', '', 30, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2011, 'S', 'magicGhost', '', 40, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2012, 'S', 'magicFlame', '', 20, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2013, 'S', 'magicInvert', '', 50, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2014, 'S', 'magicUmnik', '', 300, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2015, 'S', 'magicZhurdyai', '', 250, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2016, 'S', 'magicTeleport', '', 300, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2017, 'S', 'magicNearest', '', 300, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2018, 'S', 'magicMoonwalk', '', 300, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2019, 'S', 'magicPromotion', '', 300, 6, NULL, '', 0, 1, 1, '', '', 1, 0),
       (2020, 'S', 'magicBubbleBlack', '', 0, 6, '2012-01-07 21:25:55', '', 0, 1, 1, '', '', 0, 5),
       (2021, 'B', 'card1', '', 100, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2022, 'B', 'card2', '', 100, 27, NULL, '', 1, 0, 1, '', '', 0, 5),
       (2023, 'B', 'card3', '', 100, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2024, 'B', 'canab', '', 1000, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2025, 'B', 'canab2', '', 1000, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2026, 'B', 'blank', '', 25, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2027, 'B', 'card4', '', 1000, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2028, 'B', 'card5', '', 1000, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2029, 'B', 'card6', '', 1000, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2030, 'B', 'card7', '', 1000, 27, NULL, '', 1, 0, 1, '', '', 0, 0),
       (2031, 'B', 'card8_halloween', '', 1000, 27, NULL, '', 1, 0, 1, '', '', 0, 5),
       (2032, 'B', 'card9_beach', '', 1000, 27, NULL, 'LEVEL 3 ITEM', 0, 0, 1, '', '', 0, 5),
       (2033, 'B', 'card10_stars', '', 750, 27, NULL, '', 1, 1, 1, '', '', 0, 0),
       (2034, 'B', 'card11_snow', '', 1000, 27, NULL, '', 1, 1, 1, '', '', 0, 5),
       (2035, 'B', 'card12_mountain', '', 1000, 27, NULL, '', 0, 0, 1, '', '', 0, 5),
       (2036, 'B', 'card14_valentine', '', 1000, 27, NULL, '', 1, 1, 1, '', '', 0, 5),
       (2037, 'B', 'card_elves', '', 50000, 27, '2010-05-14 13:53:52', '', 1, 0, 1, '', '', 0, 0),
       (2038, 'B', 'card_celebrity', '', 0, 27, '2011-02-09 11:39:49', '', 0, 0, 1, '', '', 0, 5),
       (2039, 'B', 'card_disco', '', 8000, 27, '2011-03-04 12:21:27', '', 1, 0, 1, '', '', 0, 0),
       (2040, 'B', 'card_digital', '', 15000, 27, '2011-03-04 12:21:38', '', 1, 1, 1, '', '', 0, 0),
       (2041, 'B', 'cardhalloween', '', 500, 27, '2011-10-25 06:42:00', '', 0, 0, 1, '', '', 0, 5),
       (2042, 'B', 'card20_chobots', '', 0, 27, '2011-10-25 06:42:53', '', 0, 1, 1, '', '', 0, 5),
       (2043, 'B', 'card20_chobots', '', 2000, 27, '2011-10-25 06:42:55', '', 0, 1, 1, '', '', 0, 5),
       (2044, 'B', 'card_elves_3', '', 0, 27, '2011-10-26 19:39:16', '', 1, 0, 1, '', 'Dave Flag', 0, 5),
       (2045, 'B', 'card_elves_2', '', 900, 27, '2011-10-27 17:10:51', '', 1, 0, 1, '', '', 0, 5),
       (2046, 'B', 'card_elves_3', '', 700, 27, '2011-10-27 17:11:22', '', 1, 0, 1, '', '', 0, 5),
       (2047, 'B', 'card20_chobots', '', 2000, 27, '2011-11-22 16:25:45', '', 1, 1, 1, '', '', 0, 1),
       (2048, 'B', 'card21_citizen', '', 1600, 27, '2011-11-25 10:20:07', '', 1, 1, 1, '', '', 0, 1),
       (2049, 'B', 'card_beta', '', 500, 27, '2011-12-30 14:23:31', '', 1, 0, 0, '', '', 0, 5),
       (2050, 'B', 'card_elves_3', '', 0, 27, '2012-01-17 16:50:14', '', 1, 0, 1, '', '', 0, 5),
       (2051, 'B', 'king', '', 0, 27, '2012-03-16 18:15:52', '', 1, 0, 0, '', '', 0, 5),
       (2052, 'B', 'radio_bg', '', 5200, 27, '2012-04-12 21:04:57', 'Lv 8', 1, 0, 1, '', '', 0, 1),
       (2053, 'B', 'bg_rock', '', 2700, 27, '2012-04-12 21:05:03', '', 0, 0, 1, '', '', 0, 5),
       (2054, 'B', 'card22_dots', '', 5200, 27, '2012-05-01 18:40:48', '', 1, 0, 1, '', '', 0, 5),
       (2055, 'B', 'card23_sweet', '', 5100, 27, '2012-05-01 18:41:21', '', 1, 0, 1, '', '', 0, 5),
       (2056, 'B', 'card24_honeycomb', '', 4500, 27, '2012-05-01 18:43:51', '', 0, 0, 1, '', '', 0, 1),
       (2057, 'E', 'cocktail0', '', 10, 3, NULL, '', 0, 0, 1, '', '', 0, 0),
       (2058, 'E', 'cocktail1', '', 6, 3, NULL, '', 0, 0, 1, '', '', 0, 0),
       (2059, 'E', 'cocktail2', '', 8, 3, NULL, '', 0, 0, 1, '', '', 0, 0),
       (2060, 'E', 'cocktail3', '', 29, 3, NULL, '', 0, 0, 1, '', '', 0, 0);

INSERT INTO `StuffType` (`type`, `fileName`, `placement`, `price`, `shop_id`, `created`, `info`, `hasColor`,
                         `premium`, `giftable`, `itemOfTheMonth`, `name`, `rainable`, `groupNum`)
VALUES
    ('P', 'makarony', '', 7, 10, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'popcorn', '', 8, 10, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
-- Disabled, has no animation ('P', 'jajcya', '', 6, 10, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'kistka', '', 7, 10, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
-- Disabled, has no animation ('P', 'ravlyky', '', 8, 10, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'cukerka', '', 6, 10, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'gameBall', '', 300, 11, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'gameCircle', '', 300, 11, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'gameBatut', '', 300, 11, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'gameScate', '', 300, 11, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'gameVantus', '', 300, 11, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'gamePet', '', 300, 11, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'podushka', '', 300, 12, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'sleeping', '', 300, 12, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
-- Disabled, has no animation ('P', 'gnizdo', '', 300, 12, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'knyzhka', '', 300, 12, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0),
    ('P', 'tapok', '', 300, 12, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0);
-- Disabled, has no animation ('P', 'maska', '', 300, 12, '2015-01-01 00:00', '', 0, 0, 0, '', '', 0, 0);

/*!40000 ALTER TABLE `StuffType`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TopScore`
--

DROP TABLE IF EXISTS `TopScore`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TopScore`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT,
    `created`     datetime     DEFAULT NULL,
    `score`       double     NOT NULL,
    `scoreId`     varchar(255) DEFAULT NULL,
    `gameChar_id` bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FKC9957E5DB0D63236` (`gameChar_id`),
    CONSTRAINT `FKC9957E5DB0D63236` FOREIGN KEY (`gameChar_id`) REFERENCES `GameChar` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TopScore`
--

LOCK TABLES `TopScore` WRITE;
/*!40000 ALTER TABLE `TopScore`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `TopScore`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Transaction`
--

DROP TABLE IF EXISTS `Transaction`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Transaction`
(
    `id`                   bigint(20) NOT NULL AUTO_INCREMENT,
    `created`              datetime     DEFAULT NULL,
    `billingRequestParams` longtext     DEFAULT NULL,
    `description`          varchar(255) DEFAULT NULL,
    `payedAmount`          varchar(255) DEFAULT NULL,
    `payedCurrency`        varchar(255) DEFAULT NULL,
    `source`               varchar(50)  DEFAULT NULL,
    `state`                tinyint(4) NOT NULL,
    `successMessage`       varchar(255) DEFAULT NULL,
    `type`                 int(11)      DEFAULT NULL,
    `skuId`                bigint(20)   DEFAULT NULL,
    `userId`               bigint(20)   DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FKE30A7ABE248B7D4D` (`userId`),
    CONSTRAINT `FKE30A7ABE248B7D4D` FOREIGN KEY (`userId`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Transaction`
--

LOCK TABLES `Transaction` WRITE;
/*!40000 ALTER TABLE `Transaction`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `Transaction`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TransactionUserInfo`
--

DROP TABLE IF EXISTS `TransactionUserInfo`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TransactionUserInfo`
(
    `id`            bigint(20) NOT NULL AUTO_INCREMENT,
    `created`       datetime     DEFAULT NULL,
    `address1`      varchar(255) DEFAULT NULL,
    `address2`      varchar(255) DEFAULT NULL,
    `city`          varchar(255) DEFAULT NULL,
    `country`       varchar(255) DEFAULT NULL,
    `email`         varchar(255) DEFAULT NULL,
    `first_name`    varchar(255) DEFAULT NULL,
    `last_name`     varchar(255) DEFAULT NULL,
    `phone`         varchar(255) DEFAULT NULL,
    `state`         varchar(255) DEFAULT NULL,
    `state2`        varchar(255) DEFAULT NULL,
    `transactionId` varchar(255) DEFAULT NULL,
    `zip`           varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TransactionUserInfo`
--

LOCK TABLES `TransactionUserInfo` WRITE;
/*!40000 ALTER TABLE `TransactionUserInfo`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `TransactionUserInfo`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `User`
(
    `id`                    bigint(20) NOT NULL AUTO_INCREMENT,
    `created`               datetime            DEFAULT NULL,
    `login`                 varchar(255)        DEFAULT NULL,
    `password`              varchar(255)        DEFAULT NULL,
    `acceptRequests`        tinyint(1)          DEFAULT 1,
    `activated`             bit(1)              DEFAULT NULL,
    `activationKey`         varchar(255)        DEFAULT NULL,
    `agent`                 tinyint(1)          DEFAULT 0,
    `banReason`             varchar(255)        DEFAULT NULL,
    `baned`                 tinyint(1)          DEFAULT 0,
    `chatEnabled`           tinyint(1)          DEFAULT 1,
    `citizenExpirationDate` datetime            DEFAULT NULL,
    `citizenTryCount`       int(11)    NOT NULL DEFAULT 0,
    `deleted`               bit(3)     NOT NULL DEFAULT b'0',
    `drawEnabled`           tinyint(1)          DEFAULT 1,
    `email`                 varchar(255)        DEFAULT NULL,
    `enabled`               tinyint(1)          DEFAULT 1,
    `gameChar_id`           bigint(20)          DEFAULT NULL,
    `guest`                 bit(1)              DEFAULT NULL,
    `helpEnabled`           tinyint(1)          DEFAULT 1,
    `locale`                varchar(255)        DEFAULT NULL,
    `loginToken`            varchar(255)        DEFAULT NULL,
    `moderator`             tinyint(1)          DEFAULT 0,
    `musicVolume`           int(3)     NOT NULL DEFAULT 50,
    `parent`                tinyint(1)          DEFAULT 0,
    `robotTeam_id`          bigint(20)          DEFAULT NULL,
    `showTips`              bit(3)     NOT NULL DEFAULT b'1',
    `soundVolume`           int(3)     NOT NULL DEFAULT 50,
    `superUser`             bit(3)     NOT NULL DEFAULT b'0',
    `invitedBy_id`          bigint(20)          DEFAULT NULL,
    `marketingInfo_id`      bigint(20)          DEFAULT NULL,
    `membershipInfo_id`     bigint(20)          DEFAULT NULL,
    `userExtraInfo_id`      bigint(20)          DEFAULT NULL,
    `salt`                  varchar(64)         DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `login` (`login`),
    KEY `FK285FEB1DAE48FE` (`userExtraInfo_id`),
    KEY `FK285FEB7D858D7E` (`marketingInfo_id`),
    KEY `FK285FEB838D5F8F` (`invitedBy_id`),
    KEY `FK285FEB197823B6` (`membershipInfo_id`),
    KEY `FK285FEBB0D63236` (`gameChar_id`),
    KEY `FK285FEB7057D69E` (`robotTeam_id`),
    CONSTRAINT `FK285FEB197823B6` FOREIGN KEY (`membershipInfo_id`) REFERENCES `MembershipInfo` (`id`),
    CONSTRAINT `FK285FEB1DAE48FE` FOREIGN KEY (`userExtraInfo_id`) REFERENCES `UserExtraInfo` (`id`),
    CONSTRAINT `FK285FEB7057D69E` FOREIGN KEY (`robotTeam_id`) REFERENCES `RobotTeam` (`id`),
    CONSTRAINT `FK285FEB7D858D7E` FOREIGN KEY (`marketingInfo_id`) REFERENCES `MarketingInfo` (`id`),
    CONSTRAINT `FK285FEB838D5F8F` FOREIGN KEY (`invitedBy_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FK285FEBB0D63236` FOREIGN KEY (`gameChar_id`) REFERENCES `GameChar` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 17
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `User`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserDance`
--

DROP TABLE IF EXISTS `UserDance`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserDance`
(
    `id`      bigint(20) NOT NULL AUTO_INCREMENT,
    `created` datetime      DEFAULT NULL,
    `dance`   varchar(1000) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserDance`
--

LOCK TABLES `UserDance` WRITE;
/*!40000 ALTER TABLE `UserDance`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `UserDance`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserExtraInfo`
--

DROP TABLE IF EXISTS `UserExtraInfo`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserExtraInfo`
(
    `id`                       bigint(20) NOT NULL AUTO_INCREMENT,
    `created`                  datetime     DEFAULT NULL,
    `continuousDaysLoginCount` int(10)      DEFAULT 0,
    `lastIp`                   varchar(255) DEFAULT NULL,
    `lastLoginDate`            datetime     DEFAULT NULL,
    `lastLogoutDate`           datetime     DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserExtraInfo`
--

LOCK TABLES `UserExtraInfo` WRITE;
/*!40000 ALTER TABLE `UserExtraInfo`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `UserExtraInfo`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserReport`
--

DROP TABLE IF EXISTS `UserReport`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserReport`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT,
    `created`     datetime   DEFAULT NULL,
    `processed`   tinyint(1) DEFAULT 0,
    `text`        text       NOT NULL,
    `reporter_id` bigint(20) DEFAULT NULL,
    `user_id`     bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FKD32EC4FF4D9B3936` (`user_id`),
    KEY `FKD32EC4FF4801A060` (`reporter_id`),
    CONSTRAINT `FKD32EC4FF4801A060` FOREIGN KEY (`reporter_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FKD32EC4FF4D9B3936` FOREIGN KEY (`user_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserReport`
--

LOCK TABLES `UserReport` WRITE;
/*!40000 ALTER TABLE `UserReport`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `UserReport`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserServer`
--

DROP TABLE IF EXISTS `UserServer`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserServer`
(
    `id`       bigint(20) NOT NULL AUTO_INCREMENT,
    `serverId` bigint(20) DEFAULT NULL,
    `userId`   bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `FKD4E49F0E8D849F3D` (`serverId`),
    KEY `FKD4E49F0E248B7D4D` (`userId`),
    CONSTRAINT `FKD4E49F0E248B7D4D` FOREIGN KEY (`userId`) REFERENCES `User` (`id`),
    CONSTRAINT `FKD4E49F0E8D849F3D` FOREIGN KEY (`serverId`) REFERENCES `Server` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserServer`
--

LOCK TABLES `UserServer` WRITE;
/*!40000 ALTER TABLE `UserServer`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `UserServer`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User_User`
--

DROP TABLE IF EXISTS `User_User`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `User_User`
(
    `User_id`    bigint(20) NOT NULL,
    `friends_id` bigint(20) NOT NULL,
    KEY `FK8BA0F3BF4D9B3936` (`User_id`),
    KEY `FK8BA0F3BFEDB98F2C` (`friends_id`),
    CONSTRAINT `FK8BA0F3BF4D9B3936` FOREIGN KEY (`User_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FK8BA0F3BFEDB98F2C` FOREIGN KEY (`friends_id`) REFERENCES `User` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User_User`
--

LOCK TABLES `User_User` WRITE;
/*!40000 ALTER TABLE `User_User`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `User_User`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User_UserDance`
--

DROP TABLE IF EXISTS `User_UserDance`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `User_UserDance`
(
    `User_id`   bigint(20) NOT NULL,
    `dances_id` bigint(20) NOT NULL,
    UNIQUE KEY `dances_id` (`dances_id`),
    KEY `FKABD88B34983F2B66` (`dances_id`),
    KEY `FKABD88B344D9B3936` (`User_id`),
    CONSTRAINT `FKABD88B344D9B3936` FOREIGN KEY (`User_id`) REFERENCES `User` (`id`),
    CONSTRAINT `FKABD88B34983F2B66` FOREIGN KEY (`dances_id`) REFERENCES `UserDance` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User_UserDance`
--

LOCK TABLES `User_UserDance` WRITE;
/*!40000 ALTER TABLE `User_UserDance`
    DISABLE KEYS */;
/*!40000 ALTER TABLE `User_UserDance`
    ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'chobots'
--
/*!40103 SET TIME_ZONE = @OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE = @OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS = @OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION = @OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES = @OLD_SQL_NOTES */;

-- Dump completed on 2025-07-25  3:33:48
