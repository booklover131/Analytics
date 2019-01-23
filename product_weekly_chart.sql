SELECT shimo_week,
       metrics_name,
       shimo_nums
FROM
  (SELECT to_date(date_add(createdat,1 - CASE
                                             WHEN dayofweek(createdat) = 1 THEN 7
                                             ELSE dayofweek(createdat) - 1
                                         END)) AS shimo_week,
          concat('注册企业数-',team_version)AS metrics_name,
          count(DISTINCT id) AS shimo_nums
   FROM
     (SELECT id,
             name,
             createdat,
             TYPE,
             mobile,
             city,
             CASE
                 WHEN aaa.team_id IS NOT NULL THEN '钉钉企业版'
                 WHEN bbb.team_id IS NOT NULL THEN '企业微信版'
                 ELSE '主站企业版'
             END AS team_version
      FROM teams
      LEFT JOIN
        (SELECT DISTINCT team_id
         FROM dingtalk_corps
         WHERE ldate = to_date(date_add(now(), -1)) ) aaa ON teams.id = aaa.team_id
      LEFT JOIN
        (SELECT DISTINCT team_id
         FROM wework_corp
         WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON teams.id = bbb.team_id
      WHERE ldate = to_date(date_add(now(), -1))) AS expr_qry
   GROUP BY metrics_name,
            shimo_week
   UNION ALL SELECT date_add(to_date(created_at),1-CASE
                                                       WHEN dayofweek(created_at) = 1 THEN 7
                                                       ELSE dayofweek(created_at) - 1
                                                   END) AS shimo_week,
                    concat('注册用户数-',reg_from) AS metrics_name,
                    count(DISTINCT user_id) AS shimo_nums
   FROM default.invite_info
   WHERE ldate=date_sub(to_date(now()),1)
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT to_date(date_add(register_time,1 - CASE
                                                           WHEN dayofweek(register_time) = 1 THEN 7
                                                           ELSE dayofweek(register_time) - 1
                                                       END)) AS shimo_week,
                    '注册用户总数' AS metrics_name,
                    count(DISTINCT aaa.id) AS shimo_nums
   FROM
     (SELECT DISTINCT id,
                      register_time,
                      last_visit,
                      team_id
      FROM DEFAULT.users
      WHERE ldate = to_date(date_add(now(), -1))
        AND status IN (0,
                       1) ) aaa
   INNER JOIN
     (SELECT DISTINCT user_id,
                      reg_from,
                      reg_way
      FROM invite_info
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON aaa.id = bbb.user_id
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT to_date(date_add(register_time,1 - CASE
                                                           WHEN dayofweek(register_time) = 1 THEN 7
                                                           ELSE dayofweek(register_time) - 1
                                                       END)) AS shimo_week,
                    '注册企业用户数' AS metrics_name,
                    count(DISTINCT CASE
                                       WHEN team_id IS NOT NULL THEN aaa.id
                                       ELSE NULL
                                   END) AS shimo_nums
   FROM
     (SELECT DISTINCT id,
                      register_time,
                      last_visit,
                      team_id
      FROM DEFAULT.users
      WHERE ldate = to_date(date_add(now(), -1))
        AND status IN (0,
                       1) ) aaa
   INNER JOIN
     (SELECT DISTINCT user_id,
                      reg_from,
                      reg_way
      FROM invite_info
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON aaa.id = bbb.user_id
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT to_date(date_add(register_time,1 - CASE
                                                           WHEN dayofweek(register_time) = 1 THEN 7
                                                           ELSE dayofweek(register_time) - 1
                                                       END)) AS shimo_week,
                    '注册个人用户数' AS metrics_name,
                    count(DISTINCT CASE
                                       WHEN team_id IS NULL THEN aaa.id
                                       ELSE NULL
                                   END) AS shimo_nums
   FROM
     (SELECT DISTINCT id,
                      register_time,
                      last_visit,
                      team_id
      FROM DEFAULT.users
      WHERE ldate = to_date(date_add(now(), -1))
        AND status IN (0,
                       1) ) aaa
   INNER JOIN
     (SELECT DISTINCT user_id,
                      reg_from,
                      reg_way
      FROM invite_info
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON aaa.id = bbb.user_id
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT to_date(date_add(register_time,1 - CASE
                                                           WHEN dayofweek(register_time) = 1 THEN 7
                                                           ELSE dayofweek(register_time) - 1
                                                       END)) AS shimo_week,
                    '注册有效用户数' AS metrics_name,
                    count(DISTINCT CASE
                                       WHEN last_visit IS NOT NULL THEN aaa.id
                                       ELSE NULL
                                   END) AS shimo_nums
   FROM
     (SELECT DISTINCT id,
                      register_time,
                      last_visit,
                      team_id
      FROM DEFAULT.users
      WHERE ldate = to_date(date_add(now(), -1))
        AND status IN (0,
                       1) ) aaa
   INNER JOIN
     (SELECT DISTINCT user_id,
                      reg_from,
                      reg_way
      FROM invite_info
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON aaa.id = bbb.user_id
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT date_add(ldate,1-CASE
                                         WHEN dayofweek(ldate) = 1 THEN 7
                                         ELSE dayofweek(ldate) - 1
                                     END) AS shimo_week,
                    '活跃设备数' AS metrics_name,
                    count(DISTINCT shimo_device_id) AS shimo_nums
   FROM web.active_users
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT date_add(ldate,1-CASE
                                         WHEN dayofweek(ldate) = 1 THEN 7
                                         ELSE dayofweek(ldate) - 1
                                     END) AS shimo_week,
                    '活跃用户数' AS metrics_name,
                    count(DISTINCT CASE
                                       WHEN is_login='登录' THEN shimo_user_id
                                       ELSE NULL
                                   END) AS active_users
   FROM web.active_users
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT date_add(ldate,1-CASE
                                         WHEN dayofweek(ldate) = 1 THEN 7
                                         ELSE dayofweek(ldate) - 1
                                     END) AS shimo_week,
                    '活跃企业数' AS metrics_name,
                    count(DISTINCT team_id) AS active_teams
   FROM web.active_users
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT date_add(ldate,1-CASE
                                         WHEN dayofweek(ldate) = 1 THEN 7
                                         ELSE dayofweek(ldate) - 1
                                     END) AS shimo_week,
                    concat('活跃用户数-',active_source) AS metrics_name,
                    count(DISTINCT shimo_user_id) AS shimo_nums
   FROM web.active_users
   GROUP BY active_source,
            date_add(ldate,1-CASE
                                 WHEN dayofweek(ldate) = 1 THEN 7
                                 ELSE dayofweek(ldate) - 1
                             END) )fuck
WHERE shimo_week IS NOT NULL
  AND shimo_week>=weeks_sub(now(),4)
ORDER BY shimo_week DESC
