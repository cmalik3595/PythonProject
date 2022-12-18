-- ===== === ===== === ===== === ===== === ===== === ===== === =====
-- 
-- Creates a lookup table associating a teams total prior games,
--   for each game, team pair
-- This will be needed to calculate rolling statistics in SQL, 
--   and it makes sense to only do it once/create indexes for it.
--
-- ===== === ===== === ===== === ===== === ===== === ===== === =====

SET default_storage_engine=MyISAM;

DROP TEMPORARY TABLE IF EXISTS t_game_team;
CREATE TEMPORARY TABLE t_game_team AS
	SELECT 
		game_id,
		home_team_id AS team_id
	FROM mlb_game g
	
	UNION
	
	SELECT
		game_id,
		away_team_id AS team_id
	FROM mlb_game g;

CREATE UNIQUE INDEX tgt_game_team ON t_game_team(game_id, team_id);
CREATE INDEX tgt_game ON t_game_team(game_id);
CREATE INDEX tgt_team ON t_game_team(team_id);


DROP TABLE IF EXISTS prior_game;
CREATE TABLE prior_game AS
	SELECT
		l.game_id,
		l.team_id,
		IFNULL(COUNT(r.game_id), 0) AS prior_games
	FROM t_game_team l
	LEFT JOIN t_game_team r
		ON r.team_id = l.team_id
		AND r.game_id < l.game_id
GROUP BY game_id, team_id;

DROP TEMPORARY TABLE IF EXISTS t_game_team;

CREATE UNIQUE INDEX pg_game_team_prior ON prior_game(game_id, team_id, prior_games);
-- CREATE UNIQUE INDEX pg_game_prior ON prior_game(game_id, prior_games);
CREATE UNIQUE INDEX pg_team_prior ON prior_game(team_id, prior_games);
CREATE INDEX pg_game ON prior_game(game_id);
CREATE INDEX pg_team ON prior_game(team_id);
CREATE INDEX pg_prior ON prior_game(prior_games);