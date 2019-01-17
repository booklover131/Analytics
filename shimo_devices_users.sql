SELECT a_num,b_num,c_num
FROM (
  SELECT COUNT(DISTINCT shimo_device_id) AS a_num
  FROM web.events
  WHERE ldate = '2018-12-05'
    AND event_type = '$pageview'
) aaa
  LEFT JOIN (
    SELECT COUNT(DISTINCT distinct_id) AS b_num
    FROM (
      SELECT distinct_id, COUNT(DISTINCT shimo_device_id)
      FROM web.events
      WHERE (ldate = '2018-12-05'
        AND event_type = '$pageview'
        AND distinct_id REGEXP '^[0-9]+$')
      GROUP BY distinct_id
      HAVING COUNT(DISTINCT shimo_device_id) >= 2
    ) bbb
  ) ccc
  ON 1 = 1
  LEFT JOIN (
    SELECT COUNT(DISTINCT shimo_device_id) AS c_numa
    FROM (
      SELECT shimo_device_id, COUNT(DISTINCT distinct_id)
      FROM web.events
      WHERE (ldate = '2018-12-05'
        AND event_type = '$pageview'
        AND distinct_id REGEXP '^[0-9]+$')
      GROUP BY shimo_device_id
      HAVING COUNT(DISTINCT distinct_id) >= 2
    ) ddd
  ) eee
  ON 1 = 1
