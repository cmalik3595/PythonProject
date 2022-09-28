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

----------------------------------------------------------------------------------------------------------------
-- 100 day Rolling Average slower
----------------------------------------------------------------------------------------------------------------
SELECT 'Computing 100 day slower Rolling Average for each batter.' AS '';
SELECT 'This operation may take 2.5 hours to complete. Please wait...' AS '';
SELECT now() as 'Current Time';
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
	ORDER BY batter,game_date;

SELECT '100 day Rolling Average operation completed !!' AS '';
SELECT now() as 'Completion Time';

-- Unit Test 
SELECT '***************************Rolling Average of 110029 **********************' AS '';
SELECT 'Checking 100 day Rolling Average of batter=110029' AS '';
SELECT * from batter_rolling_100 where batter = 110029 limit 0,50;

SELECT 'Checking 100 day Rolling Average of batter=110029 with date=2010-05-18' AS '';
SELECT * from batter_rolling_100 where batter = 110029 and game_date ='2010-05-18' limit 0,50;
