#!/bin/bash

echo "Deleting old database"
mysql -h mariadb -u root -e "DROP DATABASE baseball"

echo "Baseball database does not exist..."
echo "...creating baseball database..."
mysql -h mariadb -u root -e "CREATE DATABASE baseball;"

echo "...adding data to database..."
mysql -h mariadb -u root baseball < ../sql/baseball.sql

echo "...baseball database created."

echo "Adding tables..."
echo "...creating table mlb_game..."
mysql -h mariadb -u root baseball < ../sql/mlb_game.sql
echo "...creating table prior_game..."
mysql -h mariadb -u root baseball < ../sql/prior_game.sql
echo "...creating 'window' tables..."
mysql -h mariadb -u root baseball < ../sql/window.sql
echo "...creating team performance table..."
mysql -h mariadb -u root baseball < ../sql/team_performance.sql
echo "...creating pythagorean expectation tables..."
mysql -h mariadb -u root baseball < ../sql/pythagorean_expectation.sql
echo "...create base run estimate tables..."
mysql -h mariadb -u root baseball < ../sql/base_runs.sql
echo "...create defense independent pitching stats..."
mysql -h mariadb -u root baseball < ../sql/dips.sql

echo "Database setup complete"

echo "Running main python script."
python /app/main.py
