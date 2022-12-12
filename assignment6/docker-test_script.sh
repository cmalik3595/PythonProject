#!/bin/sh

echo "Starting script in container"
sleep 10

DB_CHECK=`mysql -u root -e "show databases" | grep -i baseball`
DB_NAME='baseball'

if [ "$DB_CHECK" == "$DB_NAME" ]; then
	mysql -h mariadb -u root baseball < /scripts/baseball_assignment.sql
else 
	mysql -h mariadb -u root -e "create database baseball;"
	mysql -h mariadb -u root -D baseball < /data/baseball.sql
	mysql -h mariadb -u root baseball < /scripts/baseball_assignment.sql
fi


mysql -h mariadb -u root baseball -e '
SELECT * from batter_rolling_100_alternate ;' > /results/batter_rolling_avg_100.txt

mysql -h mariadb -u root baseball -e '
SELECT * from batter_rolling_100_alternate  where batter = 110029;' > /results/batter_12560_rolling_avg_100.txt
