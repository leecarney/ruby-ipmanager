--- If you receive either of these errors when trying to request an IP:
--- Error: SQLSTATE[42S22]: Column not found: 1054 Unknown column 'dns_name' in 'field list'","time":0.013}
--- Column not found: 1054 Unknown column 'dns_name' in 'field list

--- then follow these steps...

--- Run the mysql below at the mysql command prompt. Then log into phpipam GUI > go to verify database and fix the errors.

--- drop fields created with verify database
ALTER TABLE `ipaddresses` DROP `hostname `;
ALTER TABLE `requests ` DROP `hostname `;

--- rename fields
ALTER TABLE `ipaddresses` CHANGE `dns_name` `hostname` VARCHAR(255)  CHARACTER SET utf8  COLLATE utf8_general_ci  NULL  DEFAULT NULL;
ALTER TABLE `requests` CHANGE `dns_name` `hostname` VARCHAR(255)  CHARACTER SET utf8  COLLATE utf8_general_ci  NULL  DEFAULT NULL;