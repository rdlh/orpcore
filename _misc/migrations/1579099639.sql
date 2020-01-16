-- Create Items table
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
