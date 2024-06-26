WITH nba_games_data AS (
SELECT DISTINCT
    dedup.game_id,
    dedup.team_abbreviation AS team,
    CASE
        WHEN games.home_team_id = dedup.team_id AND home_team_wins = 1 THEN 1
        WHEN games.visitor_team_id = dedup.team_id AND home_team_wins = 0 THEN 1
        WHEN home_team_wins IS NULL THEN NULL
    ELSE NULL
    END AS match_won, -- The team that won
    games.game_date_est AS game_date
FROM bootcamp.nba_game_details_dedup AS dedup
JOIN bootcamp.nba_games AS games
    ON games.game_id = dedup.game_id
),
streak_wins_over_90 AS (
  SELECT *,
        SUM(match_won) OVER (PARTITION BY team ORDER BY game_date ASC ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS ninety_days_wins_streak -- Rolling sum over the last 90 game 
  FROM nba_games_data
)
SELECT 
    team,
    -- team that won the most games in a 90-game streak
    MAX(ninety_days_wins_streak) AS max_wins_streak,
    -- determine the end date of the longest 90-day streak
    MAX_BY(game_date, ninety_days_wins_streak) AS end_streak_date
FROM streak_wins_over_90
GROUP BY team
ORDER BY max_wins_streak DESC
LIMIT 1
