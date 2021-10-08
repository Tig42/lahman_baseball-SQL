-- 1.	What range of years for baseball games played does the provided database cover?

SELECT min (yearid), max (yearid)   
FROM teams;

-- 2.	Find the 
-- a.	name and height of the shortest player in the database. 
-- b.	How many games did he play in? 
-- c.	What is the name of the team for which he played?

SELECT distinct p.playerid, p.namegiven, min (p.height) as height, a.g_all as games_played, t.name as Team_name
FROM people as p INNER JOIN appearances as a ON p.playerid = a.playerid 
		INNER JOIN teams as t ON t.teamid = a.teamid
GROUP BY p.playerid, p.namegiven, a.g_all, t.name
ORDER BY min (p.height), a.g_all 
LIMIT 1;


-- 3.	Find all 
-- a.	players in the database who played at Vanderbilt University. 
-- b.	Create a list showing each player’s first and last names 
-- c.	as well as the total salary they earned in the major leagues. 
-- d.	Sort this list in descending order by the total salary earned. 
-- e.	Which Vanderbilt player earned the most money in the majors?



SELECT p.namefirst, namelast, schoolname, sum (sal.salary::int::money) as total_salary
FROM Schools as s INNER JOIN collegeplaying as cp using (schoolid) 
				  INNER JOIN people as p ON p.playerid = cp.playerid
				  INNER JOIN salaries as sal ON sal.playerid = p.playerid
WHERE schoolname = 'Vanderbilt University'
GROUP BY p.namelast, p.namefirst, schoolname
ORDER BY total_salary desc;


-- 4.	Using the fielding table, 
-- a.	group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
-- b.	Determine the number of putouts made by each of these three groups in 2016.

SELECT pos, CASE WHEN pos = 'OF' THEN 'Outfield' 
				 WHEN pos = 'P' THEN 'Battery'
				 WHEN pos = 'C' THEN 'Battery'
				 ELSE 'Infield' END as position, sum (po::numeric) AS total_putouts, yearid AS Year
FROM fielding
WHERE yearid = '2016'
GROUP BY pos, yearid;

-- 5.	Find the 
-- a.	average number of strikeouts per game by decade since 1920.
-- b.	Round the numbers you report to 2 decimal places. 
-- c.	Do the same for home runs per game. 
-- d.	Do you see any trends?

SELECT CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
		WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		WHEN yearid > 2010 THEN '2010s' END AS Decade,name as Team_name, 
		SUM (so) as strikeouts , sum (g) as games, ROUND ((sum (so)/sum (g::decimal)),2)::decimal as avg_strikeouts_per_game, sum (hr) as home_run, ROUND((sum (hr)/sum (g::decimal)),2) AS home_runs_pergame
FROM TEAMs
GROUP BY decade, name
ORDER BY decade, name, avg_strikeouts_per_game; 


-- 6.	Find the 
-- a.	player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
-- b.	Consider only players who attempted _at least_ 20 stolen bases.


SELECT namefirst, namelast, sb, cs, sum(sb + cs) as stolen_base_attempt, ROUND ((sb/ sum (sb+cs)::decimal),2) as percentage, yearID      
FROM batting as b INNER JOIN people as p ON b.playerid = p.playerid
WHERE yearID ='2016'
GROUP BY b.playerID, sb, cs, yearID, namefirst, namelast
HAVING sum (sb + cs) >= '20'
ORDER BY percentage desc
LIMIT 1; 


-- 7.	From 1970 – 2016, 
-- a.	what is the largest number of wins for a team that did not win the world series? 
-- b.	What is the smallest number of wins for a team that did win the world series? 
-- c.	Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
-- d.	Then redo your query, excluding the problem year. 
-- e.	How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?



-- a.	what is the largest number of wins for a team that did not win the world series? 
SELECT teamID, count (WSWin) as world_seris_wins, WsWin    
				   FROM teams
				   WHERE yearid between '1970' and '2016' and WsWin IS NOT NULL and WsWin = 'N'
				   GROUP BY teamID, wSWin
				   ORDER BY world_seris_wins desc
				   LIMIT 1;
				   
-- b.	What is the smallest number of wins for a team that did win the world series? 			   
SELECT teamID, count (WSWin) as world_seris_wins, WsWin    
				   FROM teams
				   WHERE yearid between '1970' and '2016' and WsWin IS NOT NULL and WsWin = 'Y'
				   GROUP BY teamID, wSWin
				   ORDER BY world_seris_wins desc
				   LIMIT 1;
				   
-- c.	Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 

SELECT teamID, count (WSWin) as world_seris_wins, WsWin    
				   FROM teams
				   WHERE yearid between '1970' and '2016' and WsWin IS NOT NULL and WsWin = 'Y'
				   GROUP BY teamID, wSWin
				   ORDER BY world_seris_wins desc
				   LIMIT 1;

select yearid, name, max(w)
from teams
where yearid between 1970 and 2016 and wswin = 'N'
group by yearid, name
order by max desc;
-- or
select max(w)
from teams
where yearid between 1970 and 2016 and wswin = 'N';
/* What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year.
1981 Los Angeles Dodgers had 63 wins.  The low number of wins was due to a players' strike, which lasted from June 12 to July 31, and split the season into two halves. */
select yearid, name, min(w)
from teams
--where yearid between 1970 and 2016 and wswin = 'Y'  -- <<< includes 1981 strike season
where yearid between 1970 and 2016 and yearid not in (1981) and wswin = 'Y'  -- <<< excludes 1981 strike season
group by yearid, name
order by min;
-- or
select min(w)
from teams
where yearid between 1970 and 2016 and wswin = 'Y';

-- f.	What percentage of the time?

with winning_teams as (select yearid, max(w) as max_w
					from teams
					where yearid between 1970 and 2016
					and yearid <> 1981
					group by yearid
				  	order by yearid)
select sum(case when wswin = 'Y' then 1 else 0 end) as count_max_is_champ,
		avg(case when wswin = 'Y' then 1 else 0 end) as percent_max_is_champ
from winning_teams as wt
inner join teams as t
on wt.yearid = t.yearid and wt.max_w = t.w;


-- 8.	Using the attendance figures from the home games table, 
-- a.	find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games).
-- b.	Only consider parks where there were at least 10 games played. 
-- c.	Report the park name, team name, and average attendance. 

SELECT distinct h.team, h.attendance, sum (h.games), sum (h.attendance)/sum (h.games) AS Avg_attendance_per_game, p.park_name, name as team_name
FROM homegames as h INNER JOIN parks as p USING (park) 
					INNER JOIN teams as t ON t.teamid = h.team 	and h.year = t.yearid	
WHERE year= '2016' and h.games > 10
GROUP BY h.attendance, h.team,  h.games, p.park_name, h.year, name
ORDER BY Avg_attendance_per_game desc;


-- 8 d.	Repeat for the lowest 5 average attendance.

SELECT distinct h.team, h.attendance, h.games, sum (h.attendance)/sum (h.games) AS Avg_attendance_per_game, p.park_name, name as team_name
FROM homegames as h INNER JOIN parks as p USING (park) 
					INNER JOIN teams as t ON t.teamid = h.team and h.year = t.yearid			
WHERE year= '2016' and h.games > 10
GROUP BY h.attendance, h.team,  h.games, p.park_name, name
ORDER BY Avg_attendance_per_game;


-- 9.	Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
-- a.	Give their full name and the teams that they were managing when they won the award.

WITH NL_award as (SELECT a.playerid, p.namefirst, p.namelast, a.awardid, t.name as Team, a.lgid
					FROM  AwardsManagers as a INNER JOIN people as p using (playerid)
					INNER JOIN managers as m using (playerid)
					INNER JOIN teams as t on t.teamid = m.teamid and t.lgid = m.lgid and t.yearid = m.yearid and t.lgid = a.lgid 					 and t.yearid = a.yearid
				    WHERE awardid = 'TSN Manager of the Year' and a.lgid = 'NL')
SELECT distinct a.playerid, p.namefirst, p.namelast, a.awardid, t.name, a.lgid, NL.lgid, NL.team
FROM NL_award as NL
INNER JOIN AwardsManagers as a using (playerid)
INNER JOIN people as p using (playerid)
INNER JOIN managers as m using (playerid)
INNER JOIN teams as t
	on t.teamid = m.teamid and t.lgid = m.lgid and t.yearid = m.yearid and
		t.lgid = a.lgid and t.yearid = a.yearid
WHERE a.lgid = 'AL' and a.awardid = 'TSN Manager of the Year';

			
-- 10.	Find all 
-- a.	players who hit their career highest number of home runs in 2016. 
-- b.	Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
-- c.	Report the players' first and last names and the number of home runs they hit in 2016

WITH accom_HR as (SELECT playerid, yearid, hr as homerun_2016, g as Games
				  FROM batting
				  WHERE yearid = '2016'
				  GROUP BY yearid, playerid,hr, g)
				  
SELECT distinct p.namefirst, p.namelast, ahr.homerun_2016, b.hr, round (sum ((finalgame::date - debut::date)::dec/365),1) as longevity, b.yearid
FROM batting as b INNER JOIN people as p USING (playerid) 
			      INNER JOIN accom_HR as ahr USING (playerid)
WHERE b.hr > 1 AND ahr.homerun_2016 > b.hr and b.yearid <> '2016'	  
GROUP BY  b.yearid, p.namefirst, p.namelast, b.hr, ahr.homerun_2016
HAVING round (sum ((finalgame::date - debut::date)::dec/365),1) >= 10 
ORDER BY ahr.homerun_2016 desc;

-- --
-- -----
SELECT distinct p.namefirst, p.namelast, b2.hr as hR_2016, b2.yearid, round (sum ((finalgame::date - debut::date)::dec/365),1) as longevity
FROM batting as b1 INNER JOIN batting as b2 USING (playerid)
				   INNER JOIN people as p USING (playerid)
WHERE b2.yearid = '2016' and b1.hr < b2.hr and b1.yearid <> '2016'
GROUP BY  p.namefirst, p.namelast, b1.playerid, b2.hr, b1.hr, b2.yearid, b1.yearid
HAVING round (sum ((finalgame::date - debut::date)::dec/365),1) >= 10 
ORDER BY b2.hr desc, b2.yearid;



-- 11.	 Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.


SELECT s.yearid, t.w as game_won, sum (s.salary::integer::money) as team_salary
FROM salaries as s INNER JOIN managers as m USING (yearid)
				   INNER JOIN teams as t ON m.teamid = t.teamid
WHERE s.yearid > '2000'
GROUP BY s.yearid, t.w
ORDER BY s.yearid;



-- 12.	In this question, you will explore the connection between number of wins and attendance
-- Does there appear to be any correlation between attendance at home games and number of wins?
-- Do teams that win the world series see a boost in attendance the following year? 
-- What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.


SELECT  max (w), max (attendance), ROUND (avg(w::integer),0) as avg_wins, ROUND (avg (attendance::integer),0) as avg_attendance, min (w), min (attendance)
FROM Teams
WHERE attendance IS NOT NULL






-- 13	It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. 

-- First, determine just how rare left-handed pitchers are compared with right-handed pitchers.

SELECT ROUND ((AVG (case WHEN throws = 'L' then 1 ELSE 0 end)*100),2) as Percentage_lefthand_players, ROUND ((AVG (case WHEN throws = 'R' then 1 ELSE 0 end)*100),2) as percentage_Righthand_players
FROM people
WHERE throws IS NOT NULL;


-- Are left-handed pitchers more likely to win the Cy Young Award?

SELECT awardid, ROUND (AVG (CASE WHEN throws = 'L' THEN 1 ELSE 0 END)*100,2) AS Percent_lefthand_pitcher, 
	   ROUND (AVG (CASE WHEN throws = 'R' THEN 1 ELSE 0 END)*100,2) AS percent_righthand_pitcher
FROM awardsplayers AS ap INNER JOIN people AS p USING (playerid)
WHERE awardid ILIKE '%Young%'
GROUP BY awardid;


-- Are they more likely to make it into the hall of fame?

SELECT distinct inducted,ROUND(AVG (CASE WHEN throws = 'L' THEN 1 ELSE 0 END)*100,2)AS lefthand_inductee, ROUND (AVG (CASE WHEN throws = 'R' THEN 1 ELSE 0 END)*100,2) AS righthand_inductee
FROM people AS p INNER JOIN halloffame as H ON h.playerid = p.playerid
WHERE THROWS IS NOT NULL and inducted = 'Y'
GROUP BY inducted 
ORDER BY inducted desc;





















