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
