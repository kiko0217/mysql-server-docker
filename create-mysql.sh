#!/bin/bash

usage() {
    echo usage: $0 port_publich name_container name_volume name_network user password
    exit 1
}
containsElement() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}
createVolume() {
    echo create volume $1
    docker volume create $1
}
createNetwork() {
    echo create network $1 with driver bridge
    docker network create --driver bridge $1
}

[[ $# -ne 6 ]] && usage || echo create $2
array=($(docker volume ls -q))
containsElement  $3 "${array[@]}"
[[ $? -ne 0 ]] && createVolume $3 || echo volume $3 exist
array2=($(docker network ls --format '{{.Name}}'))
containsElement $4 "${array2[@]}"
[[ $? -ne 0 ]] && createNetwork $4 || echo network $4 exist

docker container run \
--name $2 \
--publish $1:3306 \
--volume $3:/var/lib/mysql \
--volume $pwd/config:/etc/mysql/conf.d \
--network $4 \
--env MYSQL_ROOT_PASSWORD=$6 \
-d \
mysql:latest &&
sleep 1m &&
docker exec -i mysqlcontainer mysql -uroot -p$6 << EOF
system echo 'Running script';
system echo 'create user $5';
CREATE USER '$5'@'%' IDENTIFIED BY '$6';
GRANT ALL PRIVILEGES ON *.* TO '$5'@'%';
FLUSH PRIVILEGES;
SELECT user,host FROM mysql.user;
EOF