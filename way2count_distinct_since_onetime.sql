(--记录去重，当前日期只要一条够了，如果shimo_week记录每周只有一条，那么不用去重
SELECT DISTINCT shimo_week,
                teams
FROM
    --筛出每周，首次出现的企业，然后做sum累计，不能直接where 标记行号直接筛，会导致时间列消失（比如部分日期下都不是第一次出现的企业）
  (SELECT shimo_week,
          sum(if(is_first_week=1,1,0)) OVER(
                                            ORDER BY shimo_week ASC) AS teams
   FROM
    --按企业分组，按记录出现周给记录打标记
     (SELECT shimo_week,
             team_id,
             row_number() OVER(PARTITION BY team_id
                               ORDER BY shimo_week ASC) AS is_first_week
      FROM
        --找出每周，有新建记录的企业
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

--method 2，统计截止某个时间点的去重值
--找到某个时间点最大的一条，就是这个时间点下累计的去重用户数
SELECT shimo_week,
       max(nums) AS nums
FROM --按周，企业，找出截止这行记录的累计值（先转为数组然后统计数组元素长度）
  (SELECT shimo_week,
          team_id,
          size(collect_set(team_id) over(
                                         ORDER BY shimo_week ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS nums
   FROM 
     (SELECT DISTINCT to_date(date_add(create_time,1 - CASE
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
         WHERE ldate = to_date(date_add(current_date(), -1))
           AND TYPE=1
           AND sub_type=2)xxx
      LEFT JOIN
        (SELECT DISTINCT id,
                         team_id
         FROM default.users
         WHERE ldate = to_date(date_add(current_date(), -1))
           AND team_id IS NOT NULL) yyy ON xxx.created_by=yyy.id
      WHERE team_id IS NOT NULL)xxxxx)fucker1
GROUP BY shimo_week
ORDER BY shimo_week DESC

--method 3，有历史状态库版本字段，选中所要的版本字段
SELECT to_date(date_add(ldate,-6)) AS week_end,
          count(DISTINCT id) AS teams
   FROM default.teams
   WHERE ldate IN (to_date(date_add(ldate,7 - CASE
                                                  WHEN dayofweek(ldate) = 1 THEN 7
                                                  ELSE dayofweek(ldate) - 1
                                              END)))
   GROUP BY week_end
