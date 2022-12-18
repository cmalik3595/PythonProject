-- ===== === ===== === ===== === ===== === ===== === ===== === =====
-- 
-- Creates a table of several measure of how a team performed each game.
-- https://en.wikipedia.org/wiki/Pythagorean_expectation
-- 
-- ===== === ===== === ===== === ===== === ===== === ===== === =====

SET default_storage_engine=MyISAM;

DROP TABLE IF EXISTS team_performance;
CREATE TABLE team_performance AS
	SELECT
		i.game_id,
		g.home_team_id AS team_id,
		1 AS is_home,
		IF(i.home_score>i.away_score, 1, 0) AS home_won,
		i.home_score AS r,
		i.away_score AS ra,
		i.home_score - i.away_score AS r_diff,
		i.innings,
		IF(i.home_score=i.away_score, 1, 0) AS tie,
		IF(i.innings>9, 1, 0) AS overtime,
		IF((i.innings<9) AND ((i.home_score - i.away_score)>=10), 1, 0) AS away_mercy,
		IF((i.innings<9) AND ((i.home_score - i.away_score)<=-10), 1, 0) AS home_mercy,
		IF((i.innings<9) AND (ABS(i.home_score - i.away_score)<10), 1, 0) AS ended_early
	FROM (
		SELECT
			CAST(game_id AS INTEGER) AS game_id,
			MAX(inning.home_score) AS home_score,
			MAX(inning.away_score) AS away_score,
			MAX(inning.inning) AS innings
		FROM inning
		GROUP BY game_id
	) i
	JOIN mlb_game g
		ON i.game_id = g.game_id
	
	UNION 

	SELECT
		i.game_id,
		g.away_team_id AS team_id,
		0 AS is_home,
		IF(i.home_score>i.away_score, 1, 0) AS home_won,
		i.away_score AS r,
		i.home_score AS ra,
		i.home_score - i.away_score AS r_diff,
		i.innings,
		IF(i.home_score=i.away_score, 1, 0) AS tie,
		IF(i.innings>9, 1, 0) AS overtime,
		IF((i.innings<9) AND ((i.home_score - i.away_score)>=10), 1, 0) AS away_mercy,
		IF((i.innings<9) AND ((i.home_score - i.away_score)<=-10), 1, 0) AS home_mercy,
		IF((i.innings<9) AND (ABS(i.home_score - i.away_score)<10), 1, 0) AS ended_early
	FROM (
		SELECT
			CAST(game_id AS INTEGER) AS game_id,
			MAX(inning.home_score) AS home_score,
			MAX(inning.away_score) AS away_score,
			MAX(inning.inning) AS innings
		FROM inning
		GROUP BY game_id
	) i
	JOIN mlb_game g
		ON i.game_id = g.game_id;

CREATE UNIQUE INDEX tp_game_team ON team_performance(game_id, team_id);
CREATE INDEX tp_game ON team_performance(game_id);
CREATE INDEX tp_team ON team_performance(team_id);

