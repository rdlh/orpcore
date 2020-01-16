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
