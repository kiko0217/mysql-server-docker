#!/bin/bash

docker exec -i mysqlcontainer mysql -uroot << EOF
system echo 'Running script $1';
# GRANT ALL PRIVILEGES ON *.* TO 'user'@'%';
# FLUSH PRIVILEGES;
# SHOW GRANTS FOR 'user'@'%';
SELECT user,host FROM mysql.user;
EOF