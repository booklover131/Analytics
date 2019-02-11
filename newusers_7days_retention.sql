SELECT xxx.reg_day,
       count(DISTINCT xxx.id) AS reg_day_users,
       ndv(CASE
               WHEN yyy.active_day>xxx.reg_day
                    AND datediff(active_day,reg_day)=7
                    AND yyy.shimo_user_id IS NOT NULL THEN yyy.shimo_user_id
               ELSE NULL
           END) AS active_day_users
FROM
  (SELECT DISTINCT id,
                   trunc(register_time,'DD') AS reg_day
   FROM default.users
   WHERE ldate=date_add(to_date(now()),-1)
     AND users.status IN (0,
                          1)
     AND register_time>='2019-01-14'
     AND last_visit IS NOT NULL)xxx
LEFT JOIN
  (SELECT DISTINCT ldate AS active_day,
                   shimo_user_id
   FROM web.active_users
   WHERE ldate>='2019-01-14'
     AND is_login='登录' )yyy ON xxx.id=cast(yyy.shimo_user_id AS int)
GROUP BY xxx.reg_day
ORDER BY xxx.reg_day DESC
