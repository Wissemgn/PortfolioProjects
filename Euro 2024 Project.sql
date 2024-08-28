
--Objective: To evaluate and compare the performance of the teams throughout the tournament.
--Analysis: Number of matches played, number of goals scored, 
--          and match results (wins, losses, ties).
--Visualisation: Bar or line graphs showing team performance over time.



select * from PortfolioProject.dbo.game_events


--Total matches
SELECT count(distinct fixture_id) as Total_Matches FROM PortfolioProject.dbo.game_events


--Total matches played for each team
SELECT team_name, COUNT(distinct fixture_id) AS matches_played
FROM PortfolioProject.dbo.game_events
GROUP BY team_name;



--Total goals per team
select 
  team_name,
  count(*) as total_goals_scored
 from PortfolioProject.dbo.goals
 group by team_name
 ORDER BY total_goals_scored DESC


-- Analysis of Yellow and Red Cards by Team
SELECT team_name, 
       SUM(CASE WHEN event_type = 'Yellowcard' THEN 1 ELSE 0 END) AS yellow_cards,
       SUM(CASE WHEN event_type = 'Redcard' THEN 1 ELSE 0 END) AS red_cards
FROM PortfolioProject.dbo.game_events
GROUP BY team_name
ORDER BY yellow_cards desc



--Number of Wins, Losses and Ties per Team
WITH MatchResults AS (
    SELECT
        fixture_id,
        team_name,
        -- Extraction des scores pour l'équipe
        CAST(SUBSTRING(result, 1, CHARINDEX('-', result) - 1) AS INT) AS team_score,
        -- Extraction des scores pour l'adversaire
        CAST(SUBSTRING(result, CHARINDEX('-', result) + 1, LEN(result)) AS INT) AS opponent_score
    FROM PortfolioProject.dbo.game_events
)
SELECT
    team_name,
    SUM(CASE WHEN team_score > opponent_score THEN 1 ELSE 0 END) AS victories,
    SUM(CASE WHEN team_score < opponent_score THEN 1 ELSE 0 END) AS defeats,
    SUM(CASE WHEN team_score = opponent_score THEN 1 ELSE 0 END) AS draws
FROM MatchResults
GROUP BY team_name
ORDER BY victories desc;





