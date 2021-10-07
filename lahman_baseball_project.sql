/*
## Lahman Baseball Database Exercise
- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
- you can find a data dictionary [here](http://www.seanlahman.com/files/database/readme2016.txt)

### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.

**Initial Questions**  */

-- 1. What range of years for baseball games played does the provided database cover?

SELECT MIN(yearid), MAX(yearid)
FROM teams;

/* 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?  */

SELECT CONCAT(namefirst, ' ', namelast) as name,
	p.playerid,
	namegiven,
	height as height_in_inches,
	SUM(a.g_all) as games_played,
	t.name as team_name
FROM people as p
LEFT JOIN appearances as a
ON p.playerid = a.playerid
LEFT JOIN teams as t
ON a.teamid = t.teamid AND a.yearid = t.yearid
GROUP BY p.playerid, namegiven, CONCAT(namefirst, ' ', namelast), height, team_name
ORDER BY height_in_inches
LIMIT 2;

/*
"name"			"playerid"	"namegiven"		"height_in_inches"	"games_played"	"team_name"
"Eddie Gaedel"	"gaedeed01"	"Edward Carl"	43					1				"St. Louis Browns"
"Bill Finley"	"finlebi01"	"William James"	63					13				"New York Giants"
*/

select playerid, yearid, g_all
from appearances
--where playerid = 'gaedeed01';


/* 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?  */

SELECT CONCAT(p.namefirst, ' ', p.namelast) as name,
	SUM(s.salary) as total_salary
	FROM people as p
LEFT JOIN salaries as s
ON p.playerid = s.playerid
LEFT JOIN collegeplaying as cp
ON p.playerid = cp.playerid
--USING playerid
WHERE s.salary IS NOT NULL AND cp.schoolid = 'vandy'
GROUP BY CONCAT(p.namefirst, ' ', p.namelast)
ORDER BY total_salary DESC;

 -- andrew's solution
 select distinct(c.playerid),
	p.namefirst,
	p.namelast,
	c.schoolid,
	sum(s.salary) as total_pro_salary
from collegeplaying as c
left join people as p
on c.playerid = p.playerid
left join salaries as s
on c.playerid = s.playerid
where c.schoolid = 'vandy' and s.salary is not null
group by c.playerid, p.namefirst, p.namelast, c.schoolid
order by total_pro_salary desc;

/* 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.  */

SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('P','C') THEN 'Battery'
	ELSE 'Infield' END as Position,
	SUM(po) as Putouts
FROM fielding
WHERE yearid = 2016
GROUP BY Position;

SELECT *
FROM FIELDING;

/* 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?  */

SELECT CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
		WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		WHEN yearid > 2010 THEN '2010s' END AS Decade,
		ROUND(SUM(so)::decimal/(SUM(g)/2),2) as avg_ko_per_game,
		ROUND(SUM(hr)::decimal/(SUM(g)/2),2) as homeruns_per_game		
FROM teams
GROUP BY Decade
ORDER BY Decade;

-- or

SELECT CASE WHEN yearid > 2010 THEN '2010s'
		WHEN yearid > 2000 THEN '2000s'
		WHEN yearid > 1990 THEN '1990s'
		WHEN yearid > 1980 THEN '1980s'
		WHEN yearid > 1970 THEN '1970s'
		WHEN yearid > 1960 THEN '1960s'
		WHEN yearid > 1950 THEN '1950s'
		WHEN yearid > 1940 THEN '1940s'
		WHEN yearid > 1930 THEN '1930s'
		WHEN yearid > 1920 THEN '1920s' END AS Decade,
		ROUND(SUM(so)::decimal/(SUM(g)/2),2) as avg_ko_per_game,
		ROUND(SUM(hr)::decimal/(SUM(g)/2),2) as homeruns_per_game		
FROM teams
GROUP BY Decade
ORDER BY Decade;

--- What is causing the null value in decade field?


/* 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.  */

/* select playerid as player,
	round(sum(sb)::decimal/((sum(sb)+sum(cs)),2) --as steal_percentage
from batting
group by player; */

SELECT CONCAT(p.namefirst , ' ' , p.namelast) as full_name,
		round(sum(sb)::decimal/(sum(sb)+sum(cs)),2) as steal_percentage
		--max(sb)as max_stealing_bases
FROM batting as b inner join people as p
    on b.playerid=p.playerid
where yearid=2016 
--group by p.namefirst,p.namelast
group by CONCAT(p.namefirst , ' ' , p.namelast)
HAVING sum(sb)+sum(cs)>=20
ORDER BY steal_percentage DESC
LIMIT 1;
		  
select *
from batting


/* 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?

2001 Seattle Mariners had 116 wins. */


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

/* How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?  */

-- Josh's code
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
on wt.yearid = t.yearid and wt.max_w = t.w


-- scott's failed attempt
with most_wins as (select yearid, wswin, max(w)
					from teams
					where yearid between 1970 and 2016
					group by yearid, wswin
				  	order by yearid)
					


/* 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.  */

SELECT distinct h.team, h.attendance, h.games, sum (h.attendance)/sum (h.games) AS Avg_attendance_per_game, p.park_name, name as team_name
FROM homegames as h INNER JOIN parks as p USING (park)
					INNER JOIN teams as t ON t.teamid = h.team and h.year = t.yearid			
WHERE year= '2016' and h.games > 10
GROUP BY h.attendance, h.team,  h.games, p.park_name, h.year, name
ORDER BY Avg_attendance_per_game desc
LIMIT 5;

/* 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.  */

-- final code

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
WHERE a.lgid = 'AL' and a.awardid = 'TSN Manager of the Year'


-- Milton's code
WITH NL_award as (SELECT playerid, awardid, lgid
				  FROM AwardsManagers
				  WHERE awardid = 'TSN Manager of the Year' and lgid = 'NL')
SELECT distinct a.playerid, a.awardid, a.lgid, NL.lgid
FROM NL_award as NL INNER JOIN AwardsManagers as a using (playerid)
WHERE a.lgid = 'AL' and a.awardid = 'TSN Manager of the Year'

-- andrew's code

WITH NL_award as (SELECT playerid, awardid, lgid
				  FROM AwardsManagers
				  WHERE awardid = 'TSN Manager of the Year' and lgid = 'NL')
SELECT distinct a.playerid, p.namefirst, p.namelast, a.awardid, t.name, a.lgid, NL.lgid
FROM NL_award as NL
INNER JOIN AwardsManagers as a using (playerid)
INNER JOIN people as p using (playerid)
INNER JOIN managers as m using (playerid)
INNER JOIN teams as t
	on t.teamid = m.teamid and t.lgid = m.lgid and t.yearid = m.yearid and
		t.lgid = a.lgid and t.yearid = a.yearid
WHERE a.lgid = 'AL' and a.awardid = 'TSN Manager of the Year'

/* 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.  */

-- tigist
select playerid,yearid as year,lgid,max(hr)as highest_homeruns
from batting
where yearid=2016
group by playerid,yearid,lgid
order by highest_homeruns DESC

-- milton
SELECT p.namefirst, p.namelast, b.hr, round (sum ((finalgame::date - debut::date)::dec/365),1) as longevity, yearid
FROM batting as b INNER JOIN people as p USING (playerid)
WHERE yearid = '2016' and hr > 1
GROUP BY b.hr, namefirst, namelast, yearid
HAVING round (sum ((finalgame::date - debut::date)::dec/365),1) > 10
ORDER BY hr desc;

-- **Open-ended questions**

/* 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.  */

/* 12. In this question, you will explore the connection between number of wins and attendance.
    <ol type="a">
      <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
      <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
    </ol>  */


/* 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?  */
