SELECT xxx.reg_day,
       count(DISTINCT xxx.id) AS reg_day_users,
       CASE
           WHEN aaa.team_id IS NOT NULL THEN '钉钉企业版'
           WHEN bbb.team_id IS NOT NULL THEN '企业微信版'
           ELSE '主站企业版'
       END AS team_version,
       ndv(CASE
               WHEN yyy.active_day>xxx.reg_day
                    AND datediff(active_day,reg_day)=7
                    AND yyy.shimo_user_id IS NOT NULL THEN yyy.shimo_user_id
               ELSE NULL
           END) AS active_day_users
FROM
  (SELECT DISTINCT id,
                   team_id,
                   trunc(register_time,'DD') AS reg_day
   FROM default.users
   WHERE ldate=date_add(to_date(now()),-1)
     AND users.status IN (0,
                          1)
     AND register_time>='2018-03-01'
     AND last_visit IS NOT NULL
     AND team_id IS NOT NULL)xxx
LEFT JOIN
  (SELECT DISTINCT team_id
   FROM dingtalk_corps
   WHERE ldate = to_date(date_add(now(), -1)) ) aaa ON xxx.team_id = aaa.team_id
LEFT JOIN
  (SELECT DISTINCT team_id
   FROM wework_corp
   WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON xxx.team_id = bbb.team_id
LEFT JOIN
  (SELECT DISTINCT ldate AS active_day,
                   shimo_user_id
   FROM web.active_users
   WHERE ldate>='2018-03-01'
     AND is_login='登录' )yyy ON xxx.id=cast(yyy.shimo_user_id AS int)
GROUP BY xxx.reg_day,
         team_version
ORDER BY xxx.reg_day DESC,
         team_version ASC
