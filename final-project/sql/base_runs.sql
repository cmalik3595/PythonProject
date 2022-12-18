-- ===== === ===== === ===== === ===== === ===== === ===== === =====
-- 
-- Creates several "base run" tables.
-- https://en.wikipedia.org/wiki/Base_runs
-- https://en.wikipedia.org/wiki/Total_bases had to be calculated.
-- 2 equations are used:
--   0: first listed in wiki
--   1: second listed in wiki
-- Differences and ratios between these stats are also calculated.
--
-- ===== === ===== === ===== === ===== === ===== === ===== === =====

SET default_storage_engine=MyISAM;



-- BSR ROLL career

DROP TEMPORARY TABLE IF EXISTS t_lookup_career;
CREATE TEMPORARY TABLE t_lookup_career AS
	SELECT
		w.game_id,
		tbc.team_id,
		tbc.homeTeam,
		tbc.win,
		SUM(tbc.Hit) AS h,
		SUM(tbc.Walk) AS bb,
		SUM(tbc.Home_Run) AS hr,
		SUM((1*tbc.Single) + (2*tbc.`Double`) + (3*tbc.Triple) + (4*tbc.Home_Run)) AS tb,
		SUM(tbc.atBat) AS ab,
		SUM(tbc.Hit_By_Pitch) AS hbp,
		SUM(tbc.Intent_Walk) AS ibb,
		SUM(tbc.caughtStealing2B+tbc.caughtStealing3B+tbc.caughtStealingHome) AS cs,
		SUM(tbc.stolenBase2B +tbc.stolenBase3B +tbc.stolenBaseHome) AS sb,
		SUM(tbc.Grounded_Into_DP) AS gidp,
		COUNT(tbc.game_id) AS g
	FROM window_career w
	JOIN team_batting_counts tbc 
	ON w.prior_game = tbc.game_id
		AND w.team_id = tbc.team_id
	GROUP BY game_id, team_id;



DROP TABLE IF EXISTS bsr_career;
CREATE TABLE bsr_career AS
	SELECT
		h.game_id,
		h.team_id AS home_id,
		h.homeTeam AS is_home,
		h.win,
		h.simple AS home_simple,
		h.offshoot AS home_offshoot,
		a.simple as away_simple,
		a.offshoot AS away_offshoot,
		h.simple - a.simple AS simple_diff,
		h.simple / a.simple AS simple_ratio,
		h.offshoot - a.offshoot AS offshoot_diff,
		h.offshoot / a.offshoot AS offshoot_ratio
	FROM (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_career
				WHERE homeTeam = 1
			) h
		) h
	) h
	JOIN (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_career
				WHERE homeTeam = 0
			) a
		) a
	) a
	ON h.game_id = a.game_id
	GROUP BY game_id;



-- BSR ROLL 10

DROP TEMPORARY TABLE IF EXISTS t_lookup_10;
CREATE TEMPORARY TABLE t_lookup_10 AS
	SELECT
		w.game_id,
		tbc.team_id,
		tbc.homeTeam,
		tbc.win,
		SUM(tbc.Hit) AS h,
		SUM(tbc.Walk) AS bb,
		SUM(tbc.Home_Run) AS hr,
		SUM((1*tbc.Single) + (2*tbc.`Double`) + (3*tbc.Triple) + (4*tbc.Home_Run)) AS tb,
		SUM(tbc.atBat) AS ab,
		SUM(tbc.Hit_By_Pitch) AS hbp,
		SUM(tbc.Intent_Walk) AS ibb,
		SUM(tbc.caughtStealing2B+tbc.caughtStealing3B+tbc.caughtStealingHome) AS cs,
		SUM(tbc.stolenBase2B +tbc.stolenBase3B +tbc.stolenBaseHome) AS sb,
		SUM(tbc.Grounded_Into_DP) AS gidp,
		COUNT(tbc.game_id) AS g
	FROM window_roll10 w
	JOIN team_batting_counts tbc 
	ON w.prior_game = tbc.game_id
		AND w.team_id = tbc.team_id
	GROUP BY game_id, team_id;



DROP TABLE IF EXISTS bsr_roll10;
CREATE TABLE bsr_roll10 AS
	SELECT
		h.game_id,
		h.team_id AS home_id,
		h.homeTeam AS is_home,
		h.win,
		h.simple AS home_simple,
		h.offshoot AS home_offshoot,
		a.simple as away_simple,
		a.offshoot AS away_offshoot,
		h.simple - a.simple AS simple_diff,
		h.simple / a.simple AS simple_ratio,
		h.offshoot - a.offshoot AS offshoot_diff,
		h.offshoot / a.offshoot AS offshoot_ratio
	FROM (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_10
				WHERE homeTeam = 1
			) h
		) h
	) h
	JOIN (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_10
				WHERE homeTeam = 0
			) a
		) a
	) a
	ON h.game_id = a.game_id
	GROUP BY game_id;



-- BSR ROLL 160

DROP TEMPORARY TABLE IF EXISTS t_lookup_160;
CREATE TEMPORARY TABLE t_lookup_160 AS
	SELECT
		w.game_id,
		tbc.team_id,
		tbc.homeTeam,
		tbc.win,
		SUM(tbc.Hit) AS h,
		SUM(tbc.Walk) AS bb,
		SUM(tbc.Home_Run) AS hr,
		SUM((1*tbc.Single) + (2*tbc.`Double`) + (3*tbc.Triple) + (4*tbc.Home_Run)) AS tb,
		SUM(tbc.atBat) AS ab,
		SUM(tbc.Hit_By_Pitch) AS hbp,
		SUM(tbc.Intent_Walk) AS ibb,
		SUM(tbc.caughtStealing2B+tbc.caughtStealing3B+tbc.caughtStealingHome) AS cs,
		SUM(tbc.stolenBase2B +tbc.stolenBase3B +tbc.stolenBaseHome) AS sb,
		SUM(tbc.Grounded_Into_DP) AS gidp,
		COUNT(tbc.game_id) AS g
	FROM window_roll160 w
	JOIN team_batting_counts tbc 
	ON w.prior_game = tbc.game_id
		AND w.team_id = tbc.team_id
	GROUP BY game_id, team_id;



DROP TABLE IF EXISTS bsr_roll160;
CREATE TABLE bsr_roll160 AS
	SELECT
		h.game_id,
		h.team_id AS home_id,
		h.homeTeam AS is_home,
		h.win,
		h.simple AS home_simple,
		h.offshoot AS home_offshoot,
		a.simple as away_simple,
		a.offshoot AS away_offshoot,
		h.simple - a.simple AS simple_diff,
		h.simple / a.simple AS simple_ratio,
		h.offshoot - a.offshoot AS offshoot_diff,
		h.offshoot / a.offshoot AS offshoot_ratio
	FROM (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_160
				WHERE homeTeam = 1
			) h
		) h
	) h
	JOIN (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_160
				WHERE homeTeam = 0
			) a
		) a
	) a
	ON h.game_id = a.game_id
	GROUP BY game_id;



-- BSR ROLL 320

DROP TEMPORARY TABLE IF EXISTS t_lookup_320;
CREATE TEMPORARY TABLE t_lookup_320 AS
	SELECT
		w.game_id,
		tbc.team_id,
		tbc.homeTeam,
		tbc.win,
		SUM(tbc.Hit) AS h,
		SUM(tbc.Walk) AS bb,
		SUM(tbc.Home_Run) AS hr,
		SUM((1*tbc.Single) + (2*tbc.`Double`) + (3*tbc.Triple) + (4*tbc.Home_Run)) AS tb,
		SUM(tbc.atBat) AS ab,
		SUM(tbc.Hit_By_Pitch) AS hbp,
		SUM(tbc.Intent_Walk) AS ibb,
		SUM(tbc.caughtStealing2B+tbc.caughtStealing3B+tbc.caughtStealingHome) AS cs,
		SUM(tbc.stolenBase2B +tbc.stolenBase3B +tbc.stolenBaseHome) AS sb,
		SUM(tbc.Grounded_Into_DP) AS gidp,
		COUNT(tbc.game_id) AS g
	FROM window_roll320 w
	JOIN team_batting_counts tbc 
	ON w.prior_game = tbc.game_id
		AND w.team_id = tbc.team_id
	GROUP BY game_id, team_id;



DROP TABLE IF EXISTS bsr_roll320;
CREATE TABLE bsr_roll320 AS
	SELECT
		h.game_id,
		h.team_id AS home_id,
		h.homeTeam AS is_home,
		h.win,
		h.simple AS home_simple,
		h.offshoot AS home_offshoot,
		a.simple as away_simple,
		a.offshoot AS away_offshoot,
		h.simple - a.simple AS simple_diff,
		h.simple / a.simple AS simple_ratio,
		h.offshoot - a.offshoot AS offshoot_diff,
		h.offshoot / a.offshoot AS offshoot_ratio
	FROM (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_320
				WHERE homeTeam = 1
			) h
		) h
	) h
	JOIN (
		SELECT
			game_id,
			team_id,
			homeTeam,
			win,
			(((a0 * b0)/(b0 + c0)) + d0)/g AS simple,
			(((10 * b1)/(b1 + c1)) + d1)/g AS offshoot
		FROM (
			SELECT 
				game_id,
				team_id,
				homeTeam,
				win,
				(h + bb - hr) AS a0,
				(1.4 * tb - .6 * h - 3 * hr + .1 * bb) * 1.02 AS b0,
				(ab - h) AS c0,
				(hr) AS d0,
				(h + bb + hbp - hr - .5 * ibb) AS a1,
				(1.4 * tb - .6 * h - 3 * hr + .1 * (bb + hbp - ibb) + .9 * (sb-cs-gidp))*1.1 AS b1,
				(ab - h + cs + gidp) AS c1,
				(hr) AS d1,
				g
			FROM (
				SELECT *
				FROM t_lookup_320
				WHERE homeTeam = 0
			) a
		) a
	) a
	ON h.game_id = a.game_id
	GROUP BY game_id;
	