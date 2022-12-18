-- ===== === ===== === ===== === ===== === ===== === ===== === =====
-- 
-- Creates several "pythagorean expectation" tables.
-- https://en.wikipedia.org/wiki/Pythagorean_expectation
-- 3 equations are used:
--   pyth0: original eq. with 2.00 exponent
--   pyth1: original eq. with the ideal 1.83 exponent
--   pyth2: Smyth's revised eq.
-- Differences and rations between these stats are also calculated.
-- ===== === ===== === ===== === ===== === ===== === ===== === =====

SET default_storage_engine=MyISAM;

-- PYTH CAREER

DROP TEMPORARY TABLE IF EXISTS t_lookup_career;
CREATE TEMPORARY TABLE t_lookup_career AS
	SELECT
		cl.game_id,
		cl.team_id,
		tp.is_home,
		tp.home_won,
		SUM(cl.r) AS r,
		SUM(cl.ra) AS ra,
		COUNT(cl.game_id) AS g
	FROM (
		SELECT
			w.game_id,
			w.team_id,
			tp.r,
			tp.ra
		FROM window_career w
		JOIN team_performance tp 
		ON w.prior_game = tp.game_id
			AND w.team_id = tp.team_id
	) cl
	JOIN team_performance tp
	ON tp.game_id = cl.game_id
		AND tp.team_id = cl.team_id
	GROUP BY cl.game_id, cl.team_id;

	

DROP TABLE IF EXISTS pyth_career;
CREATE TABLE pyth_career AS
SELECT
	cp.*,
	cp.home_pyth0 - cp.away_pyth0 AS pyth0_diff,
	cp.home_pyth0 / cp.away_pyth0 AS pyth0_ratio,
	cp.home_pyth1 - cp.away_pyth1 AS pyth1_diff,
	cp.home_pyth1 / cp.away_pyth1 AS pyth1_ratio,
	cp.home_pyth2 - cp.away_pyth2 AS pyth2_diff,
	cp.home_pyth2 / cp.away_pyth2 AS pyth2_ratio
FROM (
SELECT
	game_id,
	home_won,
	home_id,
	away_id,
	(POWER(h_r, 2.00) / (POWER(h_r,2.00) + POWER(h_ra,2.00))) AS home_pyth0,
	(POWER(a_r, 2.00) / (POWER(a_r,2.00) + POWER(a_ra,2.00))) AS away_pyth0,
	(POWER(h_r, 1.83) / (POWER(h_r, 1.83) + POWER(h_ra, 1.83))) AS home_pyth1,
	(POWER(a_r, 1.83) / (POWER(a_r, 1.83) + POWER(a_ra, 1.83))) AS away_pyth1,
	(POWER(h_r, h_exp) / (POWER(h_r, h_exp) + POWER(h_ra, h_exp))) AS home_pyth2,
	(POWER(a_r, a_exp) / (POWER(a_r, a_exp) + POWER(a_ra, a_exp))) AS away_pyth2
FROM(
	SELECT
		h.game_id,
		h.home_won,
		h.team_id AS home_id,
		a.team_id AS away_id,
		h.r AS h_r,
		h.ra AS h_ra,
		h.g AS h_g,
		POWER(((h.r + h.ra) / h.g), 0.287) AS h_exp,
		a.r AS a_r,
		a.ra AS a_ra,
		a.g AS a_g,
		POWER(((a.r + a.ra) / a.g), 0.287) AS a_exp
	FROM (
		SELECT *
		FROM t_lookup_career
		WHERE is_home = 1
	) h
	JOIN (
		SELECT *
		FROM t_lookup_career
		WHERE is_home = 0
	) a
	ON h.game_id = a.game_id
) cp
) cp;


-- PYTH ROLL 10

DROP TEMPORARY TABLE IF EXISTS t_lookup_roll10;
CREATE TEMPORARY TABLE t_lookup_roll10 AS
	SELECT
		cl.game_id,
		cl.team_id,
		tp.is_home,
		tp.home_won,
		SUM(cl.r) AS r,
		SUM(cl.ra) AS ra,
		COUNT(cl.game_id) AS g
	FROM (
		SELECT
			w.game_id,
			w.team_id,
			tp.r,
			tp.ra
		FROM window_roll10 w
		JOIN team_performance tp 
		ON w.prior_game = tp.game_id
			AND w.team_id = tp.team_id
	) cl
	JOIN team_performance tp
	ON tp.game_id = cl.game_id
		AND tp.team_id = cl.team_id
	GROUP BY cl.game_id, cl.team_id;

	

DROP TABLE IF EXISTS pyth_roll10;
CREATE TABLE pyth_roll10 AS
SELECT
	cp.*,
	cp.home_pyth0 - cp.away_pyth0 AS pyth0_diff,
	cp.home_pyth0 / cp.away_pyth0 AS pyth0_ratio,
	cp.home_pyth1 - cp.away_pyth1 AS pyth1_diff,
	cp.home_pyth1 / cp.away_pyth1 AS pyth1_ratio,
	cp.home_pyth2 - cp.away_pyth2 AS pyth2_diff,
	cp.home_pyth2 / cp.away_pyth2 AS pyth2_ratio
FROM (
SELECT
	game_id,
	home_won,
	home_id,
	away_id,
	(POWER(h_r, 2.00) / (POWER(h_r,2.00) + POWER(h_ra,2.00))) AS home_pyth0,
	(POWER(a_r, 2.00) / (POWER(a_r,2.00) + POWER(a_ra,2.00))) AS away_pyth0,
	(POWER(h_r, 1.83) / (POWER(h_r, 1.83) + POWER(h_ra, 1.83))) AS home_pyth1,
	(POWER(a_r, 1.83) / (POWER(a_r, 1.83) + POWER(a_ra, 1.83))) AS away_pyth1,
	(POWER(h_r, h_exp) / (POWER(h_r, h_exp) + POWER(h_ra, h_exp))) AS home_pyth2,
	(POWER(a_r, a_exp) / (POWER(a_r, a_exp) + POWER(a_ra, a_exp))) AS away_pyth2
FROM(
	SELECT
		h.game_id,
		h.home_won,
		h.team_id AS home_id,
		a.team_id AS away_id,
		h.r AS h_r,
		h.ra AS h_ra,
		h.g AS h_g,
		POWER(((h.r + h.ra) / h.g), 0.287) AS h_exp,
		a.r AS a_r,
		a.ra AS a_ra,
		a.g AS a_g,
		POWER(((a.r + a.ra) / a.g), 0.287) AS a_exp
	FROM (
		SELECT *
		FROM t_lookup_roll10
		WHERE is_home = 1
	) h
	JOIN (
		SELECT *
		FROM t_lookup_roll10
		WHERE is_home = 0
	) a
	ON h.game_id = a.game_id
) cp
) cp;

-- PYTH ROLL 160

DROP TEMPORARY TABLE IF EXISTS t_lookup_160;
CREATE TEMPORARY TABLE t_lookup_160 AS
	SELECT
		cl.game_id,
		cl.team_id,
		tp.is_home,
		tp.home_won,
		SUM(cl.r) AS r,
		SUM(cl.ra) AS ra,
		COUNT(cl.game_id) AS g
	FROM (
		SELECT
			w.game_id,
			w.team_id,
			tp.r,
			tp.ra
		FROM window_roll160 w
		JOIN team_performance tp 
		ON w.prior_game = tp.game_id
			AND w.team_id = tp.team_id
	) cl
	JOIN team_performance tp
	ON tp.game_id = cl.game_id
		AND tp.team_id = cl.team_id
	GROUP BY cl.game_id, cl.team_id;

	

DROP TABLE IF EXISTS pyth_roll160;
CREATE TABLE pyth_roll160 AS
SELECT
	cp.*,
	cp.home_pyth0 - cp.away_pyth0 AS pyth0_diff,
	cp.home_pyth0 / cp.away_pyth0 AS pyth0_ratio,
	cp.home_pyth1 - cp.away_pyth1 AS pyth1_diff,
	cp.home_pyth1 / cp.away_pyth1 AS pyth1_ratio,
	cp.home_pyth2 - cp.away_pyth2 AS pyth2_diff,
	cp.home_pyth2 / cp.away_pyth2 AS pyth2_ratio
FROM (
SELECT
	game_id,
	home_won,
	home_id,
	away_id,
	(POWER(h_r, 2.00) / (POWER(h_r,2.00) + POWER(h_ra,2.00))) AS home_pyth0,
	(POWER(a_r, 2.00) / (POWER(a_r,2.00) + POWER(a_ra,2.00))) AS away_pyth0,
	(POWER(h_r, 1.83) / (POWER(h_r, 1.83) + POWER(h_ra, 1.83))) AS home_pyth1,
	(POWER(a_r, 1.83) / (POWER(a_r, 1.83) + POWER(a_ra, 1.83))) AS away_pyth1,
	(POWER(h_r, h_exp) / (POWER(h_r, h_exp) + POWER(h_ra, h_exp))) AS home_pyth2,
	(POWER(a_r, a_exp) / (POWER(a_r, a_exp) + POWER(a_ra, a_exp))) AS away_pyth2
FROM(
	SELECT
		h.game_id,
		h.home_won,
		h.team_id AS home_id,
		a.team_id AS away_id,
		h.r AS h_r,
		h.ra AS h_ra,
		h.g AS h_g,
		POWER(((h.r + h.ra) / h.g), 0.287) AS h_exp,
		a.r AS a_r,
		a.ra AS a_ra,
		a.g AS a_g,
		POWER(((a.r + a.ra) / a.g), 0.287) AS a_exp
	FROM (
		SELECT *
		FROM t_lookup_160
		WHERE is_home = 1
	) h
	JOIN (
		SELECT *
		FROM t_lookup_160
		WHERE is_home = 0
	) a
	ON h.game_id = a.game_id
) cp
) cp;

-- PYTH ROLL320

DROP TEMPORARY TABLE IF EXISTS t_lookup_320;
CREATE TEMPORARY TABLE t_lookup_320 AS
	SELECT
		cl.game_id,
		cl.team_id,
		tp.is_home,
		tp.home_won,
		SUM(cl.r) AS r,
		SUM(cl.ra) AS ra,
		COUNT(cl.game_id) AS g
	FROM (
		SELECT
			w.game_id,
			w.team_id,
			tp.r,
			tp.ra
		FROM window_roll320 w
		JOIN team_performance tp 
		ON w.prior_game = tp.game_id
			AND w.team_id = tp.team_id
	) cl
	JOIN team_performance tp
	ON tp.game_id = cl.game_id
		AND tp.team_id = cl.team_id
	GROUP BY cl.game_id, cl.team_id;

	

DROP TABLE IF EXISTS pyth_roll320;
CREATE TABLE pyth_roll320 AS
SELECT
	cp.*,
	cp.home_pyth0 - cp.away_pyth0 AS pyth0_diff,
	cp.home_pyth0 / cp.away_pyth0 AS pyth0_ratio,
	cp.home_pyth1 - cp.away_pyth1 AS pyth1_diff,
	cp.home_pyth1 / cp.away_pyth1 AS pyth1_ratio,
	cp.home_pyth2 - cp.away_pyth2 AS pyth2_diff,
	cp.home_pyth2 / cp.away_pyth2 AS pyth2_ratio
FROM (
SELECT
	game_id,
	home_won,
	home_id,
	away_id,
	(POWER(h_r, 2.00) / (POWER(h_r,2.00) + POWER(h_ra,2.00))) AS home_pyth0,
	(POWER(a_r, 2.00) / (POWER(a_r,2.00) + POWER(a_ra,2.00))) AS away_pyth0,
	(POWER(h_r, 1.83) / (POWER(h_r, 1.83) + POWER(h_ra, 1.83))) AS home_pyth1,
	(POWER(a_r, 1.83) / (POWER(a_r, 1.83) + POWER(a_ra, 1.83))) AS away_pyth1,
	(POWER(h_r, h_exp) / (POWER(h_r, h_exp) + POWER(h_ra, h_exp))) AS home_pyth2,
	(POWER(a_r, a_exp) / (POWER(a_r, a_exp) + POWER(a_ra, a_exp))) AS away_pyth2
FROM(
	SELECT
		h.game_id,
		h.home_won,
		h.team_id AS home_id,
		a.team_id AS away_id,
		h.r AS h_r,
		h.ra AS h_ra,
		h.g AS h_g,
		POWER(((h.r + h.ra) / h.g), 0.287) AS h_exp,
		a.r AS a_r,
		a.ra AS a_ra,
		a.g AS a_g,
		POWER(((a.r + a.ra) / a.g), 0.287) AS a_exp
	FROM (
		SELECT *
		FROM t_lookup_320
		WHERE is_home = 1
	) h
	JOIN (
		SELECT *
		FROM t_lookup_320
		WHERE is_home = 0
	) a
	ON h.game_id = a.game_id
) cp
) cp;