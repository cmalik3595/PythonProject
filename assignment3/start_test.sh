#!/bin/bash
######################Installed packages#################################
# File: start_test.sh
# Description: 
#	Setup environment.
#	Starts the Assignment, load the tables and perform unit test
#########################################################################

function cleanup {
	killall -9 mysql 2>/dev/null
}

if [[ ! -f ../.venv/lib/python3.10/site-packages/pyspark/jars/mysql-connector-java-8.0.29.jar  ]]; then
       # Copy the jar to venv path. Otherwise the python-spark integration gives errors.
       	mkdir -p tmp 
	cd tmp
	wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.29.tar.gz 
	tar -xvf mysql-connector-java-8.0.29.tar.gz
	cp mysql-connector-java-8.0.29/mysql-connector-java-8.0.29.jar ../../.venv/lib/python3.10/site-packages/pyspark/jars/mysql-connector-java-8.0.29.jar
	cd -; rm -rf tmp
fi

source ../.venv/bin/activate

# Re-install everything
echo "Setup pip environment"
pip-compile --output-file=../requirements.txt ../requirements.in --upgrade 2>/dev/null
pip install -r ../requirements.txt 2>/dev/null

echo "Starting Assgnment 3 script"
python3 baseball_spark.py

trap cleanup EXIT
