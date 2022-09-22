----------------------------------------------------------------------------------------------------------------
-- filename:	test_baseball_assignment.sql
-- Description: Test commands for checking the baseball data	
----------------------------------------------------------------------------------------------------------------
SHOW ERRORS;
SHOW WARNINGS;
COMMIT;


-- Use the database
USE baseball -A;

-- Display the databases
SELECT 'Starting test suite' AS '';

SELECT '*******************************Raw Data***********************************' AS '';
-- Unit Test 
SELECT 'Checking Info of batter=110029 in main table' AS '';
SELECT * FROM batter_game_actual_info WHERE batter=110029 limit 0,10;

-- Unit Test 
SELECT '**************************Overall Average of 110029 **********************' AS '';
SELECT 'Checking Overall Average of batter=110029' AS '';
SELECT * FROM batter_overall_average WHERE batter=110029 limit 0,10;

-- Unit Test 
SELECT '***************************Annual Average of 110029 **********************' AS '';
SELECT 'Checking Annual Average of batter=110029' AS '';
SELECT * FROM batter_annual_average WHERE batter=110029 limit 0,10;

-- Unit Test 
SELECT '***************************Rolling Average of 110029 **********************' AS '';
SELECT 'Checking 100 day Rolling Average of batter=110029' AS '';
SELECT * from batter_rolling_100 where batter = 110029 limit 0,50;

SELECT 'Checking 100 day Rolling Average of batter=110029 with date=2010-05-18' AS '';
SELECT * from batter_rolling_100 where batter = 110029 and game_date ='2010-05-18' limit 0,50;
