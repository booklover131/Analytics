select to_date(first_visit_time),$utm_source, $utm_term,count(distinct distinct_id)
from
(
SELECT DISTINCT $utm_source, $utm_term, aaa.user_id, bbb.distinct_id, first_visit_time
	, reg_time
FROM (
	SELECT $utm_source, $utm_term, user_id, MIN(time) AS first_visit_time
	FROM events
	WHERE date BETWEEN '2018-03-01' AND '2018-10-31'
		AND $utm_source IN ('baidusem', 'sougousem', '360sem')
	GROUP BY $utm_source, user_id,$utm_term
) aaa
	LEFT JOIN (
		SELECT DISTINCT user_id, distinct_id
		FROM events
	) bbb
	ON aaa.user_id = bbb.user_id
	LEFT JOIN (
		SELECT distinct_id, time AS reg_time
		FROM events
		WHERE date >= '2018-03-01'
			AND event = 'signUp'
	) ccc
	ON bbb.distinct_id = ccc.distinct_id
WHERE (bbb.distinct_id IS NOT NULL
	AND ccc.reg_time IS NOT NULL
	AND datediff(reg_time, first_visit_time) >= 0
	AND datediff(reg_time, first_visit_time) <= 30))xxx
group by to_date(first_visit_time),$utm_source, $utm_term
order by to_date(first_visit_time) desc
