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
