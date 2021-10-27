--Quation 1


SELECT min(yearid),max(yearid)
FROM  pitching 
WHERE yearid >= 1871 and yearid <2017

--Quation 2

SELECT DISTINCT(P.NAMEFIRST),
	P.NAMELAST,
	S.SCHOOLNAME,
	SUM(M.SALARY) OVER(PARTITION BY p.namefirst)
FROM PEOPLE AS P
INNER JOIN COLLEGEPLAYING AS CP ON P.PLAYERID = CP.PLAYERID
INNER JOIN SCHOOLS AS S ON CP.SCHOOLID = S.SCHOOLID
INNER JOIN SALARIES AS M ON P.PLAYERID = M.PLAYERID
WHERE S.SCHOOLNAME = 'Vanderbilt University'
GROUP BY P.NAMEFIRST,
	P.NAMELAST,
	S.SCHOOLNAME,
	M.SALARY
ORDER BY sum DESC

Quation 3

select s.schoolname,c.schoolid,p.namefirst,p.namelast,sr.salary
from schools as s
full join collegeplaying as c
on s.schoolid=c.schoolid
full join people as p
on c.playerid = p.playerid
full join salaries as sr
on p.playerid=sr.playerid
where schoolname ='Vanderbilt University'

Quation 4

WITH fa AS (SELECT yearid,
CASE 	WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS','1B','2B', '3B') THEN 'Infield'
		ELSE 'Battery' END AS position
FROM fielding
WHERE yearid = 2016)
SELECT fa.yearid, fa.position, SUM(f.po) AS totalpos
FROM fa
INNER JOIN fielding AS f
ON f.yearid = fa.yearid
GROUP BY fa.yearid, fa.position

SELECT CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	   		WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN yearid BETWEEN 2000 AND 2010 THEN '2000s'
			WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
			ELSE '1919 & Before' END AS decade,
SELECT ROUND((SUM(so::decimal)/SUM(g/2)), 2) AS strikeout_per_game,
	   ROUND((SUM(hr::decimal)/SUM(g/2)),2) AS homerun_per_game,
	   CONCAT(LEFT(CAST((yearid) AS VARCHAR(4)), 3), '0s') AS decade
FROM teams
WHERE yearid > 1919
GROUP BY decade, LEFT(CAST((yearid) AS VARCHAR(4)), 3)
ORDER BY decade

Quation 5

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
ORDER BY Decade

Question 6

WITH sb_successes AS (SELECT playerid,
				sb,
				cs,
			  	yearid,
			                SUM((sb) + (cs)) AS sb_attempt
	                                FROM batting
			GROUP BY playerid, yearid, sb, cs)
						
SELECT 	p.namefirst,
		p.namelast,
		ROUND((sba.sb::numeric / sba.sb_attempt::numeric) * 100, 2) AS sb_percent
FROM people AS p
LEFT JOIN sb_successes AS sba
ON sba.playerid = p.playerid
WHERE sba.sb_attempt >= 20
AND sba.yearid = 2016
GROUP BY p.namefirst, p.namelast, sb_percent
ORDER BY sb_percent DESC;	

Quation 7

problem 7a

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
white_check_mark
eyes
raised_hands



problem 7b

SELECT DISTINCT(NAME),
	YEARID AS YEAR,
	WSWIN, W,
	L
FROM TEAMS
WHERE YEARID BETWEEN 1970 AND 2016
	AND YEARID <> 1981
	AND WSWIN = 'Y'
ORDER BY W

problem 7c

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

Quation 8

select team,park,round(avg(attendance/games),2) as avg_attendance_per_game
from homegames
where year=2016 and games>=10
group by team,park
order by avg(attendance/games) ASC
LIMIT 5
--- final answer for number 8
SELECT distinct h.team, h.attendance, h.games, sum (h.attendance)/sum (h.games) AS Avg_attendance_per_game, p.park_name, name as team_name
FROM homegames as h INNER JOIN parks as p USING (park)
					INNER JOIN teams as t ON t.teamid = h.team and h.year = t.yearid			
WHERE year= '2016' and h.games > 10
GROUP BY h.attendance, h.team,  h.games, p.park_name, h.year, name
ORDER BY Avg_attendance_per_game desc
LIMIT 5;

Qiestion 9

WITH winners as (SELECT DISTINCT p.playerID
				 FROM people AS p
INNER JOIN managers m using (playerID)
INNER JOIN teams t on (m.teamid=t.teamid AND m.yearID= t.yearID)
INNER JOIN awardsManagers aw on (p.playerID=aw.playerID AND aw.yearID=t.yearID)
WHERE aw.awardID is not null
AND aw.awardid='TSN Manager of the Year'
AND (aw.lgID='AL')
INTERSECT
SELECT DISTINCT p.playerID
FROM people p
INNER JOIN managers m using (playerID)
INNER JOIN teams t on (m.teamid=t.teamid AND m.yearID= t.yearID)
INNER JOIN awardsManagers aw on (p.playerID=aw.playerID AND aw.yearID=t.yearID)
WHERE aw.awardID is not null
AND aw.awardid='TSN Manager of the Year'
AND (aw.lgID='NL'))
SELECT aw.playerid,
	   concat(p.nameGiven,' ',p.nameLast),
	   aw.yearid,
	   t.name
FROM awardsmanagers aw
JOIN winners using (playerid)
JOIN managers m on (aw.playerid=m.playerid and aw.yearid=m.yearid)
JOIN teams t on (t.teamid=m.teamid and t.yearid=aw.yearid)
JOIN people p on aw.playerid=p.playerid
WHERE aw.awardid='TSN Manager of the Year'

Quation 10

SELECT playerid, namefirst, namelast, MAX(sum_hr) AS career_high_hr
FROM batting AS b INNER JOIN (SELECT playerid, yearid, SUM(hr) AS sum_hr
						 	  FROM batting
						 	  GROUP BY playerid, yearid
						 	  ORDER BY sum_hr DESC) AS total_hr USING (playerid)
INNER JOIN people AS p USING (playerid)
WHERE b.yearid = 2016
AND EXTRACT(year FROM p.debut::date) <= 2006
GROUP BY playerid, namefirst, namelast, hr
HAVING SUM(hr) > 0
AND MAX(sum_hr) = hr
ORDER BY career_high_hr DESC

Quation 11

 with salary_wins as (SELECT DISTINCT s.teamid, s.yearid,t.w, SUM(salary)
--     		OVER(PARTITION BY t.teamid, t.yearid)::numeric::money as team_salary
--     FROM salaries AS s
--     inner join teams AS t
--    on s.teamid = t.teamid AND s.yearid = t.yearid AND s.lgid = t.lgid
--   WHERE t.yearid >= 2000
--   order by yearid , w desc)
--   SELECT yearid, CORR(salary_wins.w, salary_wins.team_salary::numeric)
--   from salary_wins
--   group by yearid
--   order by yearid

quation 12
part 1
WITH corr AS (SELECT t.yearid, t.name, t.w, (attendance/ghome) AS avg_attendance
				FROM teams AS t
				WHERE attendance IS NOT NULL
				AND ghome IS NOT NULL
				GROUP BY t.yearid, t.name, t.w, attendance, ghome
				ORDER BY yearid, name),
	corr2 AS	(SELECT corr.yearid, CORR(corr.w, corr.avg_attendance) AS correlation
				FROM corr
				GROUP BY corr.yearid
				ORDER BY corr.yearid)
SELECT AVG(correlation)
FROM corr2

part 2

WITH base AS (SELECT t.yearid, t.name, t.wswin, (attendance/ghome) AS avg_att, LEAD(attendance/ghome) OVER(PARTITION BY name ORDER BY yearid) AS lead_att
				FROM teams AS t
				WHERE attendance IS NOT NULL
				AND ghome IS NOT NULL
				GROUP BY t.yearid, t.name, t.wswin, attendance, ghome
				ORDER BY yearid, name),
	change AS (SELECT b.yearid, b.name, b.wswin, b.avg_att, b.lead_att, b.lead_att - b.avg_att AS att_change
				FROM base AS b
				WHERE b.wswin = 'Y')
SELECT AVG(c.att_change)
FROM change AS c

part 3

WITH base AS (SELECT t.yearid, t.name, t.divwin, t.wcwin, (attendance/ghome) AS avg_att, LEAD(attendance/ghome) OVER(PARTITION BY name ORDER BY yearid) AS lead_att
				FROM teams AS t
				WHERE attendance IS NOT NULL
				AND ghome IS NOT NULL
				GROUP BY t.yearid, t.name, t.divwin, t.wcwin, attendance, ghome
				ORDER BY yearid, name)
SELECT b.yearid, b.name, b.divwin, b.wcwin, b.avg_att, b.lead_att, b.lead_att - b.avg_att AS att_change
FROM base AS b
WHERE (b.divwin = 'Y' OR b.wcwin= 'Y')

part 4
WITH base AS (SELECT t.yearid, t.name, t.divwin, t.wcwin, (attendance/ghome) AS avg_att, LEAD(attendance/ghome) OVER(PARTITION BY name ORDER BY yearid) AS lead_att
				FROM teams AS t
				WHERE attendance IS NOT NULL
				AND ghome IS NOT NULL
				GROUP BY t.yearid, t.name, t.divwin, t.wcwin, attendance, ghome
				ORDER BY yearid, name)
SELECT b.yearid, b.name, b.divwin, b.wcwin, b.avg_att, b.lead_att, b.lead_att - b.avg_att AS att_change
FROM base AS b
WHERE (b.divwin = 'Y' OR b.wcwin= 'Y')


quation 13

WITH lpitch AS (SELECT DISTINCT pi.playerid, p.namefirst, p.namelast, p.throws
			FROM people AS p
			INNER JOIN pitching as pi
			ON pi.playerid = p.playerid
			WHERE p.throws = 'L')
SELECT p.namefirst, p.namelast, ap.awardid
FROM lpitch AS p
INNER JOIN awardsplayers AS ap
ON ap.playerid = p.playerid
WHERE ap.awardid = 'Cy Young Award'
-- 37 Winners
WITH rpitch AS (SELECT DISTINCT pi.playerid, p.namefirst, p.namelast, p.throws
			FROM people AS p
			INNER JOIN pitching as pi
			ON pi.playerid = p.playerid
			WHERE p.throws = 'R')
SELECT p.namefirst, p.namelast, ap.awardid
FROM rpitch AS p
INNER JOIN awardsplayers AS ap
ON ap.playerid = p.playerid
WHERE ap.awardid = 'Cy Young Award'
-- 75 winners
-- 37/(37+75) = 33%


WITH lpitch AS (SELECT DISTINCT pi.playerid, p.namefirst, p.namelast, p.throws
			FROM people AS p
			INNER JOIN pitching as pi
			ON pi.playerid = p.playerid
			WHERE p.throws = 'L')
SELECT p.namefirst, p.namelast, hof.inducted
FROM lpitch AS p
INNER JOIN halloffame AS hof
ON hof.playerid = p.playerid
WHERE hof.inducted = 'Y'
-- 22 Left Handed Inductees
WITH rpitch AS (SELECT DISTINCT pi.playerid, p.namefirst, p.namelast, p.throws
			FROM people AS p
			INNER JOIN pitching as pi
			ON pi.playerid = p.playerid
			WHERE p.throws = 'R')
SELECT p.playerid, p.namefirst, p.namelast, hof.inducted
FROM rpitch AS p
INNER JOIN halloffame AS hof
ON hof.playerid = p.playerid
WHERE hof.inducted = 'Y'
ORDER BY p.namefirst
-- 79 Right Handed Inductees
-- 22/(22+79)= 21.78%
