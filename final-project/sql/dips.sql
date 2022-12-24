-- ===== === ===== === ===== === ===== === ===== === ===== === =====
-- 
-- Creates a DIPS table.
-- https://en.wikipedia.org/wiki/Defense_independent_pitching_statistics
--
-- ===== === ===== === ===== === ===== === ===== === ===== === =====

SET default_storage_engine=MyISAM;

DROP TABLE IF EXISTS t_pitcher_lookup;
CREATE TABLE t_pitcher_lookup AS
	SELECT
		w.game_id,
		w.team_id,
		pc.pitcher,
		pc.startingPitcher AS is_starting,
		pc.homeTeam AS is_home,
		pc.Home_Run AS hr,
		pc.Walk AS bb,
		pc.Hit_By_Pitch AS hbp,
		pc.Strikeout AS k,
		(pc.endingInning - pc.startingInning + 1) AS ip
	FROM window_roll160 w
	LEFT JOIN pitcher_counts pc 
		ON w.game_id = pc.game_id 
		AND w.team_id = pc.team_id;


DROP TABLE IF EXISTS pitcher_stats_roll160;
CREATE TABLE pitcher_stats_roll160
	SELECT
		*,
		3.00 + (((13 * hr) + 3*(bb + hbp) - (2 * k)) / ip) AS dice
	FROM (
		SELECT
			game_id,
			team_id,
			pitcher,
			is_starting,
			is_home,
			SUM(hr) AS hr,
			SUM(bb) AS bb,
			SUM(hbp) AS hbp,
			SUM(k) AS k,
			SUM(ip) AS ip,
			COUNT(pitcher) AS g
		FROM t_pitcher_lookup
		GROUP BY game_id, team_id, pitcher
	) ps;


DROP TABLE IF EXISTS starter_dips_roll160;
CREATE TABLE starter_dips_roll160 AS
	SELECT
		h.game_id,
		h.dice AS home_dice,
		h.hr AS home_hr,
		h.bb AS home_bb,
		h.hbp AS home_hbp,
		h.k AS home_k,
		h.ip AS home_ip,
		h.g AS home_g,
		a.dice AS away_dice,
		a.hr AS away_hr,
		a.bb AS away_bb,
		a.hbp AS away_hbp,
		a.k AS away_k,
		a.ip AS away_ip,
		a.g AS away_g,
		h.dice - a.dice AS dice_diff,
		h.hr - a.hr AS hr_diff,
		h.bb - a.bb AS bb_diff,
		h.hbp - h.hbp AS hbp_diff,
		h.k - a.k AS k_diff,
		h.ip - a.ip AS ip_diff,
		h.g - a.g AS g_diff,
		h.g / a.g AS g_ratio
	FROM (
		SELECT *
		FROM pitcher_stats_roll160
		WHERE is_starting = 1 AND is_home = 1
	) h
	JOIN (
		SELECT *
		FROM pitcher_stats_roll160
		WHERE is_starting = 1 AND is_home = 0
	) a 
	ON h.game_id = a.game_id;

