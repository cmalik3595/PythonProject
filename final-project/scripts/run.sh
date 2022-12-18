#!/bin/bash

echo "Deleting old database"
mysql -u root -phsc321 -e "DROP DATABASE baseball"

echo "Baseball database does not exist..."
echo "...creating baseball database..."
mysql -u root -phsc321 -e "CREATE DATABASE baseball;"

echo "...adding data to database..."
mysql -u root -phsc321 baseball < ../sql/baseball.sql

echo "...baseball database created."

echo "Adding tables..."
echo "...creating table mlb_game..."
mysql -u root -phsc321 baseball < ../sql/mlb_game.sql
echo "...creating table prior_game..."
mysql -u root -phsc321 baseball < ../sql/prior_game.sql
echo "...creating 'window' tables..."
mysql -u root -phsc321 baseball < ../sql/window.sql
echo "...creating team performance table..."
mysql -u root -phsc321 baseball < ../sql/team_performance.sql
echo "...creating pythagorean expectation tables..."
mysql -u root -phsc321 baseball < ../sql/pythagorean_expectation.sql
echo "...create base run estimate tables..."
mysql -u root -phsc321 baseball < ../sql/base_runs.sql
echo "...create defense independent pitching stats..."
mysql -u root -phsc321 baseball < ../sql/dips.sql

echo "Database setup complete"



echo "Running main python script."
python ../src/main.py
