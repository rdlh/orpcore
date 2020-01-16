-- Create Bans table
CREATE TABLE IF NOT EXISTS `orpcore_bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `release_date` datetime DEFAULT NULL,
  `reason` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ipaddress` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `steam_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
