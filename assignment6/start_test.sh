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

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
#        exit 1;
fi

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

# Results check
rm -rf docker-results db 

while true; do
echo "WARNING: The following operations will delete all docker containers and prune the system. Type \"y\" for proceeding with the prune, \"n\" without cleaning system."
read -p "Wish to continue with system cleanup?" yn
case $yn in
	[Yy]* ) docker system prune -a -f;docker-compose down --rmi all;docker-compose -v down; break;;
        [Nn]* ) echo "Using system as it is."; break;;
        * ) echo "Please answer y or n.";;
esac
done

# Build mysql container
docker-compose up -d --build mariadb

# Create read/write permission for mysql user on volume dir,
# for some reason can't get to work with command in compose
docker exec -it mariadb bash -c "chmod a+w /data/"

# Build assignment6_client container
docker-compose up -d --build assignment6_client

echo "Check docker-results directory for results.i"
echo "Note: The results will be populated withing 5 minutes."

#rm baseball.sql
trap cleanup EXIT
