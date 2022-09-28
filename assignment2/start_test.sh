######################Installed packages#################################
# File: start_test.sh
# Description: 
#	Downloads the sql DB and loads in the mysql. 
#	Starts the Assignment, load the tables and perform unit test
# 	Packages installed on my system:
#		apt-get install -y mariadb-server
# 		apt-get install -y libmariadb-dev
# 		apt-get install -y libmariadb-dev-compat
#########################################################################

#!/bin/bash

BASEBALL_TAR_FILE=baseball.sql.tar.gz
BASEBALL_SQL_BASEBALL_TAR_FILE=baseball.sql
PW=$1

function cleanup {
	killall -9 mysql 2>/dev/null
}

if [ -z "$1" ]; then
	echo "Root Password not given. Usage: ./start_test.sh <root pw>"
        exit 1;
fi

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1;
fi

echo "Starting Assgnment 2 script. Please wait to enter root password"
# Download the database if DB sql file is not present 
if ! [[ -f "$BASEBALL_SQL_BASEBALL_TAR_FILE" ]]; then
if [[ -f "$BASEBALL_TAR_FILE" ]]; then
	tar -xvzf baseball.sql.tar.gz
	rm -rf baseball.sql.tar.gz
else
	ping -c 1 8.8.8.8;
	if [ $? -eq 0 ]; then
		echo "Downloading database"
		wget http://teaching.mrsharky.com/data/baseball.sql.tar.gz 
		echo "Untar database"
		tar -xvzf baseball.sql.tar.gz
		rm -rf baseball.sql.tar.gz
	else
		echo "No internet connectivity. Could not download the database."
		echo "Please download database and keep the tar file in this directory."
		exit 1
	fi
fi # end check baseball.sql
fi # end check baseball.sql.tar.gz

echo "Deleting old database"
mysql -u root -p${PW} -e "DROP DATABASE baseball"

echo "Creating database"
mysql -u root -p${PW} -e "CREATE DATABASE baseball"

echo "Loading database. This may take a while..."
mysql -u root -p${PW} baseball < baseball.sql

echo "Running assignment to load new tables in database"
mysql -u root -p${PW} baseball < baseball_assignment.sql

while true; do
read -p "Do you wish to do slower 100 day rolling search? " yn
case $yn in
        [Yy]* ) mysql -u root -p${PW} baseball < baseball_assignment_slower.sql; break;;
        [Nn]* ) echo "Execute mysql -u root -p<pw> baseball < baseball_assignment_slower.sql for standalone test"; break;;
        * ) echo "Please answer yes or no.";;
esac
done

echo "Unit testing"
mysql -u root -p${PW} baseball < test_baseball_assignment.sql

echo "Test complete. Cleanup repository"
rm baseball.sql

trap cleanup EXIT
