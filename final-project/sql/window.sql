-- ===== === ===== === ===== === ===== === ===== === ===== === =====
-- 
-- Creates several "windows" over different periods of game, team pairs.
--
-- ===== === ===== === ===== === ===== === ===== === ===== === =====

SET default_storage_engine=MyISAM;

-- Career window

DROP TABLE IF EXISTS window_career;
CREATE TABLE window_career AS
	SELECT
		l.game_id,
		l.team_id,
		r.game_id AS prior_game
	FROM prior_game l
	INNER JOIN prior_game r
		ON r.team_id = l.team_id
		AND r.prior_games < l.prior_games;

CREATE UNIQUE INDEX wc_game_team_prior ON window_career(game_id, team_id, prior_game);
-- CREATE UNIQUE INDEX wc_team_prior ON window_career(team_id, prior_game);
CREATE INDEX wc_game ON window_career(game_id);
CREATE INDEX wc_team ON window_career(team_id);
CREATE INDEX wc_prior ON window_career(prior_game);



-- Roll 10 window

DROP TABLE IF EXISTS window_roll10;
CREATE TABLE window_roll10 AS
	SELECT
		l.game_id,
		l.team_id,
		r.game_id AS prior_game
	FROM prior_game l
	INNER JOIN prior_game r
		ON r.team_id = l.team_id
		AND r.prior_games < l.prior_games
		AND l.prior_games - r.prior_games <= 10;

CREATE UNIQUE INDEX r10_game_team_prior ON window_roll10(game_id, team_id, prior_game);
-- CREATE UNIQUE INDEX r10_team_prior ON window_roll10(team_id, prior_game);
CREATE INDEX r10_game ON window_roll10(game_id);
CREATE INDEX r10_team ON window_roll10(team_id);
CREATE INDEX r10_prior ON window_roll10(prior_game);


-- Roll 160 window

DROP TABLE IF EXISTS window_roll160;
CREATE TABLE window_roll160 AS
	SELECT
		l.game_id,
		l.team_id,
		r.game_id AS prior_game
	FROM prior_game l
	INNER JOIN prior_game r
		ON r.team_id = l.team_id
		AND r.prior_games < l.prior_games
		AND l.prior_games - r.prior_games <= 160;

CREATE UNIQUE INDEX r160_game_team_prior ON window_roll160(game_id, team_id, prior_game);
-- CREATE UNIQUE INDEX r100_team_prior ON window_roll100(team_id, prior_game);
CREATE INDEX r160_game ON window_roll160(game_id);
CREATE INDEX r160_team ON window_roll160(team_id);
CREATE INDEX r160_prior ON window_roll160(prior_game);


-- Roll 320 window

DROP TABLE IF EXISTS window_roll320;
CREATE TABLE window_roll320 AS
	SELECT
		l.game_id,
		l.team_id,
		r.game_id AS prior_game
	FROM prior_game l
	INNER JOIN prior_game r
		ON r.team_id = l.team_id
		AND r.prior_games < l.prior_games
		AND l.prior_games - r.prior_games <= 320;

CREATE UNIQUE INDEX r320_game_team_prior ON window_roll320(game_id, team_id, prior_game);
-- CREATE UNIQUE INDEX r200_team_prior ON window_roll200(team_id, prior_game);
CREATE INDEX r320_game ON window_roll320(game_id);
CREATE INDEX r320_team ON window_roll320(team_id);
CREATE INDEX r320_prior ON window_roll320(prior_game);


