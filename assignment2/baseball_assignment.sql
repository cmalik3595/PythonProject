----------------------------------------------------------------------------------------------------------------
-- Assignment	: 2
-- Filename	: baseball_assignment.sql
-- Creator	: Chetan Malik
-- Description	: Assignment 2 for understanding mysql and operate on baseball.sql data
----------------------------------------------------------------------------------------------------------------
	
SHOW ERRORS;
SHOW WARNINGS;
COMMIT;

-- Use the database
USE baseball -A;

DROP TABLE IF EXISTS batter_game_actual_info;
DROP TABLE IF EXISTS batter_overall_average;
DROP TABLE IF EXISTS batter_annual_average;
DROP TABLE IF EXISTS batter_rolling_100;
----------------------------------------------------------------------------------------------------------------
-- Prepare relevant data
----------------------------------------------------------------------------------------------------------------
SELECT 'Prepare Data' AS '';
DROP TABLE IF EXISTS batter_game_actual_info;
CREATE TABLE batter_game_actual_info 
	AS 
		SELECT
		      	batters_info.game_id AS game_id,						 -- Game ID
		      	batters_info.batter AS batter, 						 	-- Batter ID
			DATE_FORMAT(local_game.local_date,'%Y-%m-%d') as game_date,			-- game_date 
			DATE(DATE_SUB(local_game.local_date, INTERVAL 101 DAY)) AS 100_day_before_date,  -- 100 days prior to game date
		       	batters_info.atBat,   								-- AT BAT of Batter
		       	batters_info.Hit     								-- Hits of Batter
		FROM batter_counts batters_info 							-- Create instance of batter_counts table
		INNER JOIN game local_game 								-- Join game table
			ON batters_info.game_id = local_game.game_id 					-- If the game_id matches
		WHERE batters_info.atBat > 0;								-- atbat should be non-zero

----------------------------------------------------------------------------------------------------------------
-- Part I: Overall Average
----------------------------------------------------------------------------------------------------------------
SELECT 'Computing Overall Average' AS '';
DROP TABLE IF EXISTS batter_overall_average;
CREATE TABLE batter_overall_average
	AS
	SELECT 
		batter,
		sum(Hit) as Hit, 
		sum(atBat) as atbat, 
	       	IF(atBat != 0, sum(Hit)/sum(atBat), 0) as historic_avg 
	FROM batter_game_actual_info 
	GROUP BY batter 
	ORDER BY batter;

----------------------------------------------------------------------------------------------------------------
-- Part II: Annual Average
----------------------------------------------------------------------------------------------------------------
SELECT 'Computing Annual Average' AS '';
DROP TABLE IF EXISTS batter_annual_average;
CREATE TABLE batter_annual_average
	AS
	SELECT 
		batter,
		sum(Hit) as Hit, 
		sum(atBat) as atbat, 
		DATE_FORMAT(game_date, '%Y') as year, 
		IF(atBat != 0, sum(Hit)/sum(atBat), 0) as annual_avg
	FROM batter_game_actual_info 
	GROUP BY batter,year 
	ORDER BY batter,year;

----------------------------------------------------------------------------------------------------------------
-- Part III-A: 100 day Rolling Average
----------------------------------------------------------------------------------------------------------------
SELECT 'Computing 100 day Rolling Average for each batter.' AS '';
SELECT 'This operation may take 2.5 hours to complete. Please wait...' AS '';
select now() as 'Current Time';
DROP TABLE IF EXISTS batter_rolling_100;
CREATE TABLE batter_rolling_100 
	AS
	SELECT
		batters_info1.batter,
		batters_info1.game_date,
	       	sum(batters_info2.Hit)/sum(batters_info2.atBat) AS 100Day_avg 
	FROM batter_game_actual_info batters_info1
       		JOIN batter_game_actual_info batters_info2 
		ON batters_info1.batter = batters_info2.batter	
		WHERE batters_info2.game_date BETWEEN batters_info1.100_day_before_date AND DATE(batters_info1.game_date) 
	GROUP BY batter,game_date
	ORDER BY batter,game_date limit 0,10;

SELECT '100 day Rolling Average operation completed !!' AS '';
select now() as 'Completion Time';

----------------------------------------------------------------------------------------------------------------
-- Part III-B: 100 day Rolling Average Alternate
-- 	Tried using partitioning reference : https://learnsql.com/blog/range-clause/
-- 	but MYSQL 5.8+ versions don't support "PARTITION BY" statement.
--
-- 	As such, I could never test the below code and improve on my timings 
----------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS batter_rolling_100_alternate;
--CREATE TABLE batter_rolling_100_alternate
--	AS
--	SELECT 
--		DATE(local_game.local_date) AS game_date,
--	        batters_info.batter,
--     		SUM(batters_info.Hit) OVER (
--				PARTITION BY batters_info.batter 
--	        	    	ORDER BY DATE(local_game.local_date)
--				WHERE batters_info.game_date BETWEEN batters_info.100_day_before_date AND DATE(batters_info.game_date) 
--		) /
--        	SUM(batters_info.atBat) OVER (
--				PARTITION BY batters_info.batter
--			        ORDER BY DATE(local_game.local_date)
--				WHERE batters_info.game_date BETWEEN batters_info.100_day_before_date AND DATE(batters_info.game_date) 
--		)
--	        AS 100Day_avg
--	FROM batter_game_actual_info batters_info
--       	JOIN game local_game 
--		ON batters_info.game_id = local_game.game_id 
--	        WHERE batters_info.atBat > 0
--	GROUP BY game_date, batter
--	ORDER BY game_date;

