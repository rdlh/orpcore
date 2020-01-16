-- --------------------------------------------------------
-- Hôte :                        127.0.0.1
-- Version du serveur:           10.4.11-MariaDB - mariadb.org binary distribution
-- SE du serveur:                Win64
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Listage de la structure de la base pour orp_core
DROP DATABASE IF EXISTS `orp_core`;
CREATE DATABASE IF NOT EXISTS `orp_core` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin */;
USE `orp_core`;

-- Listage de la structure de la table orp_core. orpcore_bans
DROP TABLE IF EXISTS `orpcore_bans`;
CREATE TABLE IF NOT EXISTS `orpcore_bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `release_date` datetime DEFAULT NULL,
  `reason` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ipaddress` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `steam_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Les données exportées n'étaient pas sélectionnées.

-- Listage de la structure de la table orp_core. orpcore_character
DROP TABLE IF EXISTS `orpcore_character`;
CREATE TABLE IF NOT EXISTS `orpcore_character` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `firstname` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastname` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `health` int(11) NOT NULL,
  `hunger` int(11) NOT NULL,
  `thirst` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_2FB3206799E6F5DF` (`player_id`),
  CONSTRAINT `FK_2FB3206799E6F5DF` FOREIGN KEY (`player_id`) REFERENCES `orpcore_player` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Les données exportées n'étaient pas sélectionnées.

-- Listage de la structure de la table orp_core. orpcore_inventory
DROP TABLE IF EXISTS `orpcore_inventory`;
CREATE TABLE IF NOT EXISTS `orpcore_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `_character_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_DE4DA654B6DDCDC` (`_character_id`),
  KEY `IDX_DE4DA65126F525E` (`item_id`),
  CONSTRAINT `FK_DE4DA65126F525E` FOREIGN KEY (`item_id`) REFERENCES `orpcore_item` (`id`),
  CONSTRAINT `FK_DE4DA654B6DDCDC` FOREIGN KEY (`_character_id`) REFERENCES `orpcore_character` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1339 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Les données exportées n'étaient pas sélectionnées.

-- Listage de la structure de la table orp_core. orpcore_item
DROP TABLE IF EXISTS `orpcore_item`;
CREATE TABLE IF NOT EXISTS `orpcore_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_usable` tinyint(1) NOT NULL,
  `is_equipable` tinyint(1) NOT NULL,
  `effect_on_health` int(11) DEFAULT NULL,
  `effect_on_hunger` int(11) DEFAULT NULL,
  `effect_on_thirst` int(11) DEFAULT NULL,
  `weight` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Les données exportées n'étaient pas sélectionnées.

-- Listage de la structure de la table orp_core. orpcore_player
DROP TABLE IF EXISTS `orpcore_player`;
CREATE TABLE IF NOT EXISTS `orpcore_player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steam_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_ipaddress` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_logged_in` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Les données exportées n'étaient pas sélectionnées.

-- Listage de la structure de la table orp_core. orpcore_position
DROP TABLE IF EXISTS `orpcore_position`;
CREATE TABLE IF NOT EXISTS `orpcore_position` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `_character_id` int(11) DEFAULT NULL,
  `pos_x` double NOT NULL,
  `pos_y` double NOT NULL,
  `pos_z` double NOT NULL,
  `pos_h` double NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_E93FAD444B6DDCDC` (`_character_id`),
  CONSTRAINT `FK_E93FAD444B6DDCDC` FOREIGN KEY (`_character_id`) REFERENCES `orpcore_character` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Les données exportées n'étaient pas sélectionnées.

-- Listage des données de la table orp_core.orpcore_item : ~2 rows (environ)
DELETE FROM `orpcore_item`;
/*!40000 ALTER TABLE `orpcore_item` DISABLE KEYS */;
INSERT INTO `orpcore_item` (`id`, `name`, `is_usable`, `is_equipable`, `effect_on_health`, `effect_on_hunger`, `effect_on_thirst`, `weight`) VALUES
	(1, 'food_apple', 1, 0, 0, 10, 0, 100),
	(2, 'food_water_bottle', 1, 0, 0, 0, 50, 100),
	(3, 'med_bandage', 1, 0, 20, 0, 0, 50),
	(4, 'base_cash_unit', 0, 0, 0, 0, 0, 1);
/*!40000 ALTER TABLE `orpcore_item` ENABLE KEYS */;