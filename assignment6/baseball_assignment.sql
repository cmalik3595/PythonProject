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
	       	IF(atBat > 0, sum(Hit)/sum(atBat), 0) as historic_avg	-- giving condition within Select 
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
		IF(atBat > 0, sum(Hit)/sum(atBat), 0) as annual_avg
	FROM batter_game_actual_info 
	GROUP BY batter,year 
	ORDER BY batter,year;

----------------------------------------------------------------------------------------------------------------
-- Part III-A: 100 day Rolling Average Alternate
-- 	Tried using partitioning reference : 
-- 			https://learnsql.com/blog/range-clause/
--			https://learnsql.com/blog/moving-average-in-sql/
----------------------------------------------------------------------------------------------------------------
SELECT 'Computing faster 100 day Rolling Average for each batter.' AS '';
SELECT now() as 'Current Time';
DROP TABLE IF EXISTS batter_rolling_100_alternate;
CREATE TABLE batter_rolling_100_alternate
	AS
	SELECT 
		DATE(batters_info.game_date) as game_date,
	        batters_info.batter,
		batters_info.Hit ,
	       	batters_info.atBat,
       		AVG(batters_info.Hit / batters_info.atBat)			-- Suggested as code review comment from buddy	
     			OVER (							-- Window function. Rows are not collapsed and 
										-- each row has own window over which calculation is done

				PARTITION by batter				-- For each batter
				ORDER BY game_date				-- Order by date in this case. If the 100dayGameAverage was 
										-- the question, then we would have order by game_id
				ROWS BETWEEN 99 PRECEDING AND CURRENT ROW	-- 100 row entries only
			)
		        AS 100Day_avg
	FROM batter_game_actual_info batters_info;

	-- No need of joining any other table because batter_game_actual_info table has all necessary information
	-- ORDER BY game_date; Not required here because we already created windows and ordered them by date.

SELECT '100 day Rolling Average faster operation completed !!' AS '';
SELECT now() as 'Completion Time';


