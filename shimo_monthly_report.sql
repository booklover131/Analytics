--注册个人用户按注册渠道，区间新增

SELECT trunc(register_time,'MM') AS shimo_month,
       concat('注册个人用户数-',reg_from) AS metric_names,
       count(DISTINCT id) AS nums
FROM
  (SELECT id,
          team_id,
          register_time
   FROM default.users
   WHERE ldate = to_date(date_add(now(), -1))
     AND status IN (0,
                    1)
     AND team_id IS NULL)aa
INNER JOIN
  (SELECT user_id,
          reg_from
   FROM default.invite_info
   WHERE ldate = to_date(date_add(now(), -1)))bb ON aa.id=bb.user_id
GROUP BY shimo_month,
         metric_names
UNION ALL --注册企业用户按企业注册渠道，区间新增

SELECT trunc(register_time,'MM')AS shimo_month,
       concat(team_version,'用户数') AS metric_names,
       count(DISTINCT id) AS nums
FROM
  (SELECT id,
          register_time,
          CASE
              WHEN aaa.team_id IS NOT NULL THEN '钉钉企业版'
              WHEN bbb.team_id IS NOT NULL THEN '企业微信版'
              ELSE '主站企业版'
          END AS team_version
   FROM
     (SELECT id,
             team_id,
             register_time
      FROM default.users
      WHERE ldate = to_date(date_add(now(), -1))
        AND status IN (0,
                       1)
        AND team_id IS NOT NULL)cc
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.dingtalk_corps
      WHERE ldate = to_date(date_add(now(), -1)) ) aaa ON cc.team_id = aaa.team_id
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.wework_corp
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON cc.team_id = bbb.team_id)fuck2
GROUP BY shimo_month,
         metric_names
UNION ALL -- 注册企业数按注册渠道，区间新增

SELECT trunc(createdat,'MM')AS shimo_month,
       concat(team_version,'企业数') AS metric_names,
       count(DISTINCT id) AS nums
FROM
  (SELECT id,
          createdat,
          CASE
              WHEN aaa.team_id IS NOT NULL THEN '钉钉企业版'
              WHEN bbb.team_id IS NOT NULL THEN '企业微信版'
              ELSE '主站企业版'
          END AS team_version
   FROM default.teams
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.dingtalk_corps
      WHERE ldate = to_date(date_add(now(), -1)) ) aaa ON teams.id = aaa.team_id
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.wework_corp
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON teams.id = bbb.team_id
   WHERE ldate = to_date(date_add(now(), -1)))fuck1
GROUP BY shimo_month,
         metric_names
UNION ALL --付费个人用户按用户注册渠道，区间新增

SELECT trunc(created_at,'MM') AS shimo_month,
       concat('付费个人用户数-',reg_from) AS metric_names,
       count(DISTINCT id) AS nums
FROM
  (SELECT id,
          team_id
   FROM default.users
   WHERE ldate = to_date(date_add(now(), -1))
     AND status IN (0,
                    1)
     AND team_id IS NULL)aa
INNER JOIN
  (SELECT user_id,
          reg_from
   FROM default.invite_info
   WHERE ldate = to_date(date_add(now(), -1)))bb ON aa.id=bb.user_id
INNER JOIN
  (SELECT target_id,
          created_at
   FROM default.orders
   WHERE ldate = to_date(date_add(now(), -1))
     AND target_type=1
     AND is_paid=1)cc ON aa.id=cc.target_id
GROUP BY shimo_month,
         metric_names
UNION ALL --付费企业按企业注册渠道，区间新增

SELECT trunc(created_at,'MM')AS shimo_month,
       concat(team_version,'付费企业数') AS metric_names,
       count(DISTINCT id) AS nums
FROM
  (SELECT teams.id,
          teams.createdat,
          CASE
              WHEN aaa.team_id IS NOT NULL THEN '钉钉企业版'
              WHEN bbb.team_id IS NOT NULL THEN '企业微信版'
              ELSE '主站企业版'
          END AS team_version
   FROM default.teams
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.dingtalk_corps
      WHERE ldate = to_date(date_add(now(), -1)) ) aaa ON teams.id = aaa.team_id
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.wework_corp
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON teams.id = bbb.team_id)fuck2
INNER JOIN
  (SELECT target_id,
          created_at
   FROM default.orders
   WHERE ldate = to_date(date_add(now(), -1))
     AND target_type=2
     AND is_paid=1)dd ON fuck2.id=dd.target_id
GROUP BY shimo_month,
         metric_names
UNION ALL --新增文件按文件类型，区间新增

SELECT TRUNC(created_at, 'MONTH') AS shimo_month,
       CASE
           WHEN TYPE=1 THEN '新建文件数-文件夹'
           WHEN TYPE=0 THEN '新建文件数-老文档'
           WHEN TYPE=-1 THEN '新建文件数-老表格'
           WHEN TYPE=-2 THEN '新建文件数-新文档'
           WHEN TYPE IN(-3,
                        -4) THEN '新建文件数-新表格'
           WHEN TYPE=-5 THEN '新建文件数-幻灯片'
           WHEN TYPE=-6 THEN '新建文件数-传统文档'
           WHEN TYPE=-7 THEN '新建文件数-思维导图'
           ELSE '其他类型'
       END AS metric_names,
       count(DISTINCT id) AS nums
FROM default.shimo_files
WHERE created_at >= '2018-02-01 00:00:00'
  AND created_at <= '2019-02-01 00:00:00'
  AND ((name NOT IN ('欢迎使用石墨文档',
                     '欢迎在钉钉里使用石墨文档',
                     '示例-项目管理',
                     '示例-项目管理',
                     '示例-待办事项',
                     '示例-会议记录',
                     '财务数据整理示例',
                     '电影排片示例',
                     '项目管理示例',
                     '产品需求示例文档',
                     '会议记录示例文档',
                     '头脑风暴示例文档',
                     '欢迎来到石墨文档',
                     '表格功能示例',
                     '文档功能示例')
        AND name NOT LIKE '完成这三步,完全掌握石墨文档%')
       AND (ldate=to_date(subdate(now(),1))))
GROUP BY shimo_month,
         metric_names
UNION ALL -- 设备访问，按活跃渠道

SELECT TRUNC(ldate,'MM') AS shimo_month,
       concat('活跃设备数-',active_source) AS metric_names,
       count(DISTINCT shimo_device_id) AS nums
FROM web.active_users
GROUP BY shimo_month,
         metric_names --设备访问，按是否企业用户
UNION ALL
SELECT TRUNC(ldate,'MM') AS shimo_month,
       concat('活跃设备数-',is_enterprise_user) AS metric_names,
       count(DISTINCT shimo_device_id) AS nums
FROM web.active_users
GROUP BY shimo_month,
         metric_names
UNION ALL --活跃用户，按活跃渠道

SELECT TRUNC(ldate,'MM') AS shimo_month,
       concat('活跃用户数-',active_source) AS metric_names,
       count(DISTINCT shimo_user_id) AS nums
FROM web.active_users
WHERE is_login='登录'
GROUP BY shimo_month,
         metric_names
UNION ALL --活跃用户，按是否个人用户

SELECT TRUNC(ldate,'MM') AS shimo_month,
       concat('活跃用户数-',is_enterprise_user) AS metric_names,
       count(DISTINCT shimo_user_id)
FROM web.active_users
WHERE is_login='登录'
GROUP BY shimo_month,
         metric_names
UNION ALL --活跃企业

SELECT TRUNC(active_users.ldate,'MM') AS shimo_month,
       concat('活跃企业数-',team_version) AS metric_names,
       count(DISTINCT active_users.team_id)
FROM web.active_users
INNER JOIN
  (SELECT id,
          createdat,
          CASE
              WHEN aaa.team_id IS NOT NULL THEN '钉钉企业版'
              WHEN bbb.team_id IS NOT NULL THEN '企业微信版'
              ELSE '主站企业版'
          END AS team_version
   FROM default.teams
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.dingtalk_corps
      WHERE ldate = to_date(date_add(now(), -1)) ) aaa ON teams.id = aaa.team_id
   LEFT JOIN
     (SELECT DISTINCT team_id
      FROM default.wework_corp
      WHERE ldate = to_date(date_add(now(), -1)) ) bbb ON teams.id = bbb.team_id
   WHERE ldate = to_date(date_add(now(), -1)))fuck1 ON fuck1.id=cast(web.active_users.team_id AS int)
GROUP BY shimo_month,
         metric_names



--活跃设备人均打开文件次数
SELECT shimo_day,
       CASE
           WHEN TYPE=1 THEN '打开文件数-文件夹'
           WHEN TYPE=0 THEN '打开文件数-老文档'
           WHEN TYPE=-1 THEN '打开文件数-老表格'
           WHEN TYPE=-2 THEN '打开文件数-新文档'
           WHEN TYPE IN(-3,
                        -4) THEN '打开文件数-新表格'
           WHEN TYPE=-5 THEN '打开文件数-幻灯片'
           WHEN TYPE=-6 THEN '打开文件数-传统文档'
           WHEN TYPE=-7 THEN '打开文件数-思维导图'
           ELSE '其他类型'
       END AS metric_names,
       ndv(xx.guid)/(count(DISTINCT xx.guid)) AS nums
FROM
  (SELECT ldate AS shimo_day,
          shimo_device_id,
          split_part(s_url_path,'/',3) AS guid,
          count(*) AS open_times
   FROM web.events
   WHERE event_type='$pageview'
     AND ldate >='2019-01-01'
     AND ldate<'2019-02-01'
   GROUP BY shimo_day,
            shimo_device_id,
            guid)xx
INNER JOIN
  (SELECT DISTINCT guid,
                   TYPE
   FROM default.shimo_files
   WHERE ldate = to_date(date_add(now(), -1)))yy ON xx.guid=yy.guid
GROUP BY shimo_day,
         metric_names
UNION ALL --活跃设备人均协作次数，按文件类型

SELECT shimo_day,
       CASE
           WHEN TYPE=1 THEN '协作文件数-文件夹'
           WHEN TYPE=0 THEN '协作文件数-老文档'
           WHEN TYPE=-1 THEN '协作文件数-老表格'
           WHEN TYPE=-2 THEN '协作文件数-新文档'
           WHEN TYPE IN(-3,
                        -4) THEN '协作文件数-新表格'
           WHEN TYPE=-5 THEN '协作文件数-幻灯片'
           WHEN TYPE=-6 THEN '协作文件数-传统文档'
           WHEN TYPE=-7 THEN '协作文件数-思维导图'
           ELSE '其他类型'
       END AS metric_names,
       sum(coll_times)/count(DISTINCT user_id) AS nums
FROM
  (SELECT trunc(created_at,'DD') AS shimo_day,
          user_id,
          file_id,
          count(*) AS coll_times
   FROM default.permissions
   WHERE created_at >='2019-01-01'
     AND created_at<'2019-02-01'
   GROUP BY shimo_day,
            user_id,
            file_id )xx
INNER JOIN
  (SELECT DISTINCT id,
                   TYPE
   FROM default.shimo_files
   WHERE ldate = to_date(date_add(now(), -1)))yy ON xx.file_id=yy.id
GROUP BY shimo_day,
         metric_names

--top 100企业

SELECT yyy.team_id,
       name,
       TYPE,
       count(DISTINCT xxx.distinct_id) AS active_users,
       ndv(xxx.guid) AS open_files
FROM
  (SELECT DISTINCT ldate,
                   distinct_id,
                   split_part(s_url_path,'/',3) AS guid
   FROM web.events
   WHERE ldate>='2019-01-01'
     AND ldate <='2019-01-31'
     AND event_type='$pageview'
     AND distinct_id regexp '^[0-9]+$')xxx
INNER JOIN
  (SELECT id,
          team_id
   FROM default.users
   WHERE ldate = to_date(date_add(now(), -1))
     AND team_id IS NOT NULL)yyy ON cast(xxx.distinct_id AS int)=yyy.id
INNER JOIN
  (SELECT id,
          name,
          TYPE
   FROM default.teams
   WHERE ldate = to_date(date_add(now(), -1)))zz ON yyy.team_id=zz.id
GROUP BY yyy.team_id,
         name,
         TYPE
ORDER BY active_users DESC,
         open_files DESC
LIMIT 100

