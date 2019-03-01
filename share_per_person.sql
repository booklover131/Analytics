SELECT ldate AS shimo_day,
       '人均分享次数' AS metric_names,
       avg(share_times) AS nums
FROM
  (SELECT ldate,
          shimo_user_id,
          count(*) AS share_times
   FROM shimo.share_event
   WHERE timestr BETWEEN '2019-02-01 00:00:00' AND '2019-02-28 23:59:59'
   GROUP BY ldate,
            shimo_user_id)fuck2
GROUP BY ldate
ORDER BY ldate DESC
