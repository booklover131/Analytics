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
                             END)
   UNION ALL --协作空间周访问PV
 SELECT to_date(date_add(ldate,1 - CASE
                                       WHEN dayofweek(ldate) = 1 THEN 7
                                       ELSE dayofweek(ldate) - 1
                                   END)) AS shimo_week,
        '协作空间-周访问PV' AS metric_name,
        sum(pvs) AS nums
   FROM web.space_pvs
   GROUP BY shimo_week,
            metric_name
   UNION ALL ---协作空间周访问UV
 SELECT to_date(date_add(ldate,1 - CASE
                                       WHEN dayofweek(ldate) = 1 THEN 7
                                       ELSE dayofweek(ldate) - 1
                                   END)) AS shimo_week,
        '协作空间-周访问UV' AS metric_name,
        count(DISTINCT shimo_device_id) AS nums
   FROM web.space_active_users
   GROUP BY shimo_week,
            metric_name
   UNION ALL --截止每周末，有协作空间的企业，平均每个企业的使用量
SELECT shit.shimo_week,
       '截止周末-每企业平均使用空间容量(mb)' AS metrics_name,
       (shit.nums/fucker4.teams) AS nums --协作空间，截止到每周末，累计使用量
FROM
     (SELECT shimo_week,
             metrics_name,
             sum(nums) OVER (PARTITION BY metrics_name
                             ORDER BY shimo_week ASC) AS nums
      FROM
        (SELECT to_date(date_add(create_time,1 - CASE
                                                     WHEN dayofweek(create_time) = 1 THEN 7
                                                     ELSE dayofweek(create_time) - 1
                                                 END)) AS shimo_week,
                CASE
                    WHEN team_id IS NOT NULL THEN '企业用户-累计至周末-新建协作空间容量(mb)'
                    ELSE '个人用户-累计至周末-新建协作空间容量(mb)'
                END AS metrics_name,
                sum(SIZE)/(1024*1024) AS nums
         FROM
           (SELECT DISTINCT id,
                            from_unixtime(created_at) AS create_time,
                            created_by,
                            SIZE
            FROM shimo.svc_file
            WHERE ldate = to_date(date_add(now(), -1))
              AND TYPE=1
              AND sub_type=2)xxx
         LEFT JOIN
           (SELECT DISTINCT id,
                            team_id
            FROM default.users
            WHERE ldate = to_date(date_add(now(), -1)) ) yyy ON xxx.created_by=yyy.id
         GROUP BY shimo_week,
                  metrics_name)fuckerer)shit
   LEFT JOIN --截止周末，有创建协作空间的企业记录

     (--记录去重，当前日期只要一条够了，如果shimo_week记录每周只有一条，那么不用去重
SELECT DISTINCT shimo_week,
                teams
      FROM --筛出每周，首次出现的企业，然后做sum累计，不能直接where 标记行号直接筛，会导致时间列消失（比如部分日期下都不是第一次出现的企业）

        (SELECT shimo_week,
                sum(if(is_first_week=1,1,0)) OVER(
                                                  ORDER BY shimo_week ASC) AS teams
         FROM --按企业分组，按记录出现周给记录打标记

           (SELECT shimo_week,
                   team_id,
                   row_number() OVER(PARTITION BY team_id
                                     ORDER BY shimo_week ASC) AS is_first_week
            FROM --找出每周，有新建记录的企业

              (SELECT to_date(date_add(create_time,1 - CASE
                                                           WHEN dayofweek(create_time) = 1 THEN 7
                                                           ELSE dayofweek(create_time) - 1
                                                       END)) AS shimo_week,
                      team_id
               FROM
                 (SELECT id,
                         from_unixtime(created_at) AS create_time,
                         created_by,
                         SIZE
                  FROM shimo.svc_file
                  WHERE ldate = to_date(date_add(now(), -1))
                    AND TYPE=1
                    AND sub_type=2)xxx
               LEFT JOIN
                 (SELECT DISTINCT id,
                                  team_id
                  FROM default.users
                  WHERE ldate = to_date(date_add(now(), -1))
                    AND team_id IS NOT NULL) yyy ON xxx.created_by=yyy.id
               WHERE team_id IS NOT NULL)fucker1)fucker2)fucker3
      ORDER BY shimo_week DESC)fucker4 ON shit.shimo_week=fucker4.shimo_week
   ORDER BY shit.shimo_week DESC
   UNION ALL --协作空间，截止到每周末，累计使用量
 SELECT shimo_week,
        metrics_name,
        sum(nums) OVER (PARTITION BY metrics_name
                        ORDER BY shimo_week ASC) AS nums
   FROM
     (SELECT to_date(date_add(create_time,1 - CASE
                                                  WHEN dayofweek(create_time) = 1 THEN 7
                                                  ELSE dayofweek(create_time) - 1
                                              END)) AS shimo_week,
             CASE
                 WHEN team_id IS NOT NULL THEN '企业用户-累计至周末-新建协作空间容量(mb)'
                 ELSE '个人用户-累计至周末-新建协作空间容量(mb)'
             END AS metrics_name,
             sum(SIZE)/(1024*1024) AS nums
      FROM
        (SELECT DISTINCT id,
                         from_unixtime(created_at) AS create_time,
                         created_by,
                         SIZE
         FROM shimo.svc_file
         WHERE ldate = to_date(date_add(now(), -1))
           AND TYPE=1
           AND sub_type=2)xxx
      LEFT JOIN
        (SELECT DISTINCT id,
                         team_id
         FROM default.users
         WHERE ldate = to_date(date_add(now(), -1)) ) yyy ON xxx.created_by=yyy.id
      GROUP BY shimo_week,
               metrics_name)fucker_v1
   UNION ALL --每周新建协作空间占用容量，分个人用户和企业用户
 SELECT to_date(date_add(create_time,1 - CASE
                                             WHEN dayofweek(create_time) = 1 THEN 7
                                             ELSE dayofweek(create_time) - 1
                                         END)) AS shimo_week,
        CASE
            WHEN team_id IS NOT NULL THEN '企业用户-新建协作空间容量(mb)'
            ELSE '个人用户-新建协作空间容量(mb)'
        END AS metrics_name,
        sum(SIZE)/(1024*1024) AS nums
   FROM
     (SELECT DISTINCT id,
                      from_unixtime(created_at) AS create_time,
                      created_by,
                      SIZE
      FROM shimo.svc_file
      WHERE ldate = to_date(date_add(now(), -1))
        AND TYPE=1
        AND sub_type=2)xxx
   LEFT JOIN
     (SELECT DISTINCT id,
                      team_id
      FROM default.users
      WHERE ldate = to_date(date_add(now(), -1)) ) yyy ON xxx.created_by=yyy.id
   GROUP BY shimo_week,
            metrics_name
   UNION ALL --截止周末，累计创建协作空间数，按账号类型
 SELECT shimo_week,
        metrics_name,
        sum(nums) over(PARTITION BY metrics_name
                       ORDER BY shimo_week ASC ) AS nums
   FROM
     (SELECT to_date(date_add(create_time,1 - CASE
                                                  WHEN dayofweek(create_time) = 1 THEN 7
                                                  ELSE dayofweek(create_time) - 1
                                              END)) AS shimo_week,
             CASE
                 WHEN team_id IS NOT NULL THEN '企业用户-累计新建协作空间数'
                 ELSE '个人用户-累计新建协作空间数'
             END AS metrics_name,
             count(DISTINCT xxx.id) AS nums
      FROM
        (SELECT id,
                from_unixtime(created_at) AS create_time,
                created_by,
                SIZE
         FROM shimo.svc_file
         WHERE ldate = to_date(date_add(now(), -1))
           AND TYPE=1
           AND sub_type=2)xxx
      LEFT JOIN
        (SELECT DISTINCT id,
                         team_id
         FROM default.users
         WHERE ldate = to_date(date_add(now(), -1)) ) yyy ON xxx.created_by=yyy.id
      GROUP BY shimo_week,
               metrics_name) aaa
   UNION ALL --周新增协作空间数，按账号类型
 SELECT to_date(date_add(create_time,1 - CASE
                                             WHEN dayofweek(create_time) = 1 THEN 7
                                             ELSE dayofweek(create_time) - 1
                                         END)) AS shimo_week,
        CASE
            WHEN team_id IS NOT NULL THEN '企业用户-新建协作空间数'
            ELSE '个人用户-新建协作空间数'
        END AS metrics_name,
        count(DISTINCT xxx.id) AS nums
   FROM
     (SELECT id,
             from_unixtime(created_at) AS create_time,
             created_by,
             SIZE
      FROM shimo.svc_file
      WHERE ldate = to_date(date_add(now(), -1))
        AND TYPE=1
        AND sub_type=2)xxx
   LEFT JOIN
     (SELECT DISTINCT id,
                      team_id
      FROM default.users
      WHERE ldate = to_date(date_add(now(), -1)) ) yyy ON xxx.created_by=yyy.id
   GROUP BY shimo_week,
            metrics_name
   UNION ALL SELECT shit.shimo_week,
                    '截止周末-每企业平均新建空间数' AS metrics_name,
                    (nums/fucker4.teams) AS nums
   FROM --企业用户累计协作空间数

     (SELECT shimo_week,
             sum(nums) over(
                            ORDER BY shimo_week ASC) AS nums
      FROM
        (SELECT to_date(date_add(create_time,1 - CASE
                                                     WHEN dayofweek(create_time) = 1 THEN 7
                                                     ELSE dayofweek(create_time) - 1
                                                 END)) AS shimo_week,
                count(DISTINCT xxx.id) AS nums,
                ndv(team_id) AS teams
         FROM
           (SELECT id,
                   from_unixtime(created_at) AS create_time,
                   created_by,
                   SIZE
            FROM shimo.svc_file
            WHERE ldate = to_date(date_add(now(), -1))
              AND TYPE=1
              AND sub_type=2)xxx
         LEFT JOIN
           (SELECT DISTINCT id,
                            team_id
            FROM default.users
            WHERE ldate = to_date(date_add(now(), -1))
              AND team_id IS NOT NULL) yyy ON xxx.created_by=yyy.id
         WHERE team_id IS NOT NULL
         GROUP BY shimo_week) aaa)shit --累计创建企业数

   LEFT JOIN
     (SELECT to_date(date_add(ldate,-6)) AS week_end,
             count(DISTINCT id) AS teams
      FROM default.teams
      WHERE ldate IN (to_date(date_add(ldate,7 - CASE
                                                     WHEN dayofweek(ldate) = 1 THEN 7
                                                     ELSE dayofweek(ldate) - 1
                                                 END)))
      GROUP BY week_end)bbb ON shit.shimo_week=bbb.week_end --Method 1
LEFT JOIN --截止周末，有创建协作空间的企业记录

     (--记录去重，当前日期只要一条够了，如果shimo_week记录每周只有一条，那么不用去重
SELECT DISTINCT shimo_week,
                teams
      FROM --筛出每周，首次出现的企业，然后做sum累计，不能直接where 标记行号直接筛，会导致时间列消失（比如部分日期下都不是第一次出现的企业）

        (SELECT shimo_week,
                sum(if(is_first_week=1,1,0)) OVER(
                                                  ORDER BY shimo_week ASC) AS teams
         FROM --按企业分组，按记录出现周给记录打标记

           (SELECT shimo_week,
                   team_id,
                   row_number() OVER(PARTITION BY team_id
                                     ORDER BY shimo_week ASC) AS is_first_week
            FROM --找出每周，有新建记录的企业

              (SELECT to_date(date_add(create_time,1 - CASE
                                                           WHEN dayofweek(create_time) = 1 THEN 7
                                                           ELSE dayofweek(create_time) - 1
                                                       END)) AS shimo_week,
                      team_id
               FROM
                 (SELECT id,
                         from_unixtime(created_at) AS create_time,
                         created_by,
                         SIZE
                  FROM shimo.svc_file
                  WHERE ldate = to_date(date_add(now(), -1))
                    AND TYPE=1
                    AND sub_type=2)xxx
               LEFT JOIN
                 (SELECT DISTINCT id,
                                  team_id
                  FROM default.users
                  WHERE ldate = to_date(date_add(now(), -1))
                    AND team_id IS NOT NULL) yyy ON xxx.created_by=yyy.id
               WHERE team_id IS NOT NULL)fucker1)fucker2)fucker3
      ORDER BY shimo_week DESC)fucker4 ON shit.shimo_week=fucker4.shimo_week
   ORDER BY shit.shimo_week DESC)fuck
WHERE shimo_week IS NOT NULL
  AND shimo_week>=weeks_sub(now(),4)
ORDER BY shimo_week DESC
