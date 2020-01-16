-- Create Player table
CREATE TABLE IF NOT EXISTS `orpcore_player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steam_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_ipaddress` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_logged_in` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
