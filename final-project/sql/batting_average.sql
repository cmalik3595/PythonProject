# Batting Average = Total hits / total at-bats

# Make a table of players' total hits and at bats each game
# Join stats, we'll need it later
DROP TABLE IF EXISTS player_game_stats;

CREATE TABLE player_game_stats AS
	SELECT 
		bc.batter,
		bc.game_id, 
		date(g.local_date) AS local_date, 
		bc.atBat, 
		bc.Hit
	FROM batter_counts bc
	JOIN game g ON bc.game_id=g.game_id
	WHERE bc.atBat > 0
;


# Calculate historic BA from all games, for each player
DROP TABLE IF EXISTS player_historic_ba;

CREATE TABLE player_historic_ba AS
	SELECT batter, SUM(Hit)/SUM(atBat) AS ba
	FROM batter_counts
	WHERE atBat > 0
	GROUP BY batter
;


# Make a view of players' hits and bats by date
# Double headers exist, so this is necessary
DROP TABLE IF EXISTS player_date_stats;

CREATE TABLE player_date_stats AS
	SELECT batter, local_date, SUM(Hit) AS Hit, SUM(atBat) AS atBat
	FROM player_game_stats
	GROUP BY batter, local_date
;


# Calculate annual BA from daily stats
DROP TABLE IF EXISTS player_annual_ba;

CREATE TABLE player_annual_ba AS
	SELECT batter, YEAR(local_date) AS year, SUM(Hit)/SUM(atBat) AS ba
	FROM player_date_stats
	GROUP BY batter, YEAR(local_date)
;


# Add rolling per date
DROP VIEW IF EXISTS player_rolling_date_stats;
# Stack Overflow 508791 came in clutch with date_sub()
# This is also where I use the join-on-own-table hint
CREATE TABLE player_rolling_date_stats AS
	SELECT 
		pds1.batter, 
		pds1.local_date, 
		SUM(pds2.atBat) AS atBat, 
		SUM(pds2.Hit) AS Hit
	FROM player_date_stats AS pds1
	JOIN player_date_stats AS pds2
		ON pds2.local_date 
		BETWEEN DATE_SUB(pds1.local_date, INTERVAL 100 DAY) AND pds1.local_date
	GROUP BY pds1.batter, pds1.local_date
;


# Calculate rolling for each date
# Since we have the stats from the prior 100 days for each date,
DROP TABLE IF EXISTS player_rolling_ba_dates;

CREATE TABLE player_rolling_ba_dates AS
	SELECT batter, local_date, SUM(Hit)/SUM(atBat) AS ba
	FROM player_rolling_date_stats
	GROUP BY batter, local_date;
;


# Now join back to each game
DROP TABLE IF EXISTS player_rolling_ba;

CREATE TABLE player_rolling_ba AS
	SELECT pgs.batter, pgs.game_id, prbd.ba
	FROM player_game_stats pgs
	JOIN player_rolling_ba_dates prbd ON pgs.local_date=prbd.local_date
	
;
