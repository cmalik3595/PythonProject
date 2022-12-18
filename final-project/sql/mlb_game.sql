-- ===== === ===== === ===== === ===== === ===== === ===== === =====
-- 
-- Creates a cleaned version of the original game table,
-- removing any game containing a non-MLB team by inner joins.
-- (there appear to be a few international and university teams, 
-- probably exhibitions? These would probably affect our model.).
-- 
-- This effectively only removed 100 games from the dataset,
-- but we don't have *that* many games to go off of,
--   so we'll have to make them count.
--
-- ===== === ===== === ===== === ===== === ===== === ===== === =====

SET default_storage_engine=MyISAM;

DROP TABLE IF EXISTS mlb_game;
CREATE TABLE IF NOT EXISTS mlb_game AS
	SELECT * 
	FROM (
		SELECT game.*
		FROM game
		INNER JOIN league_division_team ldt 
			ON game.home_team_id = ldt.team_id
	) g 
	INNER JOIN league_division_team ldt2 
		ON g.away_team_id = ldt2.team_id
	ORDER BY g.local_date;