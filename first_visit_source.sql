--计算企业用户首次访问渠道的相关取数sql
SELECT team_id,
       name,
       TYPE,
       value,
       first_visit_source
FROM
  (SELECT DISTINCT target_id AS team_id,
                   name,
                   TYPE,
                   mmm.id AS creator,
                   value
   FROM
     (SELECT target_id,
             value
      FROM
        (SELECT row_number() over (PARTITION BY target_id
                                   ORDER BY created_at ASC) AS row_nums,
                target_id,
                amount/100 AS value
         FROM default.orders
         WHERE ldate='2019-01-07'
           AND is_paid=1
           AND target_type=2)zzz
      WHERE row_nums=1)xxx
   LEFT JOIN
     (SELECT id,
             name,
             TYPE
      FROM default.teams
      WHERE ldate='2019-01-07')yyy ON xxx.target_id=yyy.id
   LEFT JOIN
     (SELECT id,
             team_id
      FROM default.users
      WHERE ldate='2019-01-07'
        AND team_role='creator'
        AND status IN (0,
                       1))mmm ON xxx.target_id=mmm.team_id
   WHERE yyy.id IS NOT NULL
     AND mmm.team_id IS NOT NULL)fuck1
LEFT JOIN
  (SELECT shimo_device_id,
          shimo_user_id
   FROM shimo_tmp.device_user_v2) fuck2 ON fuck1.creator=cast(fuck2.shimo_user_id AS int)
LEFT JOIN
  (SELECT DISTINCT shimo_device_id,
                   first_visit_source
   FROM shimo_tmp.device_first_source_v2)fuck3 ON fuck3.shimo_device_id=fuck2.shimo_device_id
WHERE fuck2.shimo_user_id IS NOT NULL
  AND fuck3.shimo_device_id IS NOT NULL


CREATE TABLE shimo_tmp.device_user_v2 stored AS PARQUET AS
SELECT shimo_device_id,
       shimo_user_id
FROM
  (SELECT row_number() OVER (PARTITION BY shimo_device_id,shimo_user_id
                             ORDER BY first_visit_time ASC) AS row_nums,
          shimo_device_id,
          shimo_user_id
   FROM shimo_tmp.visit_source_v2)zzz
WHERE row_nums=1




CASE WHEN team_id IS NOT NULL AND target_id IS NOT NULL THEN target_id ELSE null END


CREATE TABLE shimo_tmp.device_first_source_v2 stored AS parquet AS
SELECT DISTINCT shimo_device_id,
                first_visit_source,
                first_visit_time
FROM
  (SELECT row_number() OVER (PARTITION BY shimo_device_id
                             ORDER BY first_visit_time ASC) AS row_nums,
          shimo_device_id,
          first_visit_source,
          first_visit_time
   FROM shimo_tmp.visit_soure_v3)xxx
WHERE row_nums=1



CREATE TABLE shimo_tmp.fuck_v2 stored AS PARQUET AS
SELECT trunc(device_first_source_v2.first_visit_time,
             'DD') AS first_visit_day,
       device_first_source_v2.first_visit_source,
       device_first_source_v2.shimo_device_id,
       team_id,
       target_id
FROM device_first_source_v2
LEFT JOIN
  (SELECT shimo_tmp.device_user_v2.shimo_device_id,
          aaa.team_id,
          bbb.target_id
   FROM shimo_tmp.device_user_v2
   LEFT JOIN
     (SELECT xxx.id AS team_id,
             team_create,
             yyy.id AS creator_user_id,
             creator_create
      FROM
        (SELECT id,
                createdat AS team_create
         FROM default.teams
         WHERE ldate='2019-01-07')xxx
      LEFT JOIN
        (SELECT id,
                team_id,
                created_at AS creator_create
         FROM default.users
         WHERE ldate='2019-01-07'
           AND team_role='creator'
           AND status IN (0,
                          1))yyy ON xxx.id=yyy.team_id
      WHERE yyy.team_id IS NOT NULL )aaa ON cast(shimo_tmp.device_user_v2.shimo_user_id AS INT)=aaa.creator_user_id
   LEFT JOIN
     (SELECT target_id,
             to_date(min(created_at)) AS first_order_day
      FROM default.orders
      WHERE ldate='2019-01-07'
        AND is_paid=1
        AND target_type=2
      GROUP BY target_id)bbb ON aaa.team_id=bbb.target_id)nnn ON device_first_source_v2.shimo_device_id=nnn.shimo_device_id
WHERE nnn.shimo_device_id IS NOT NULL



--企业id，企业创建时间，创建者id，创建者注册时间
SELECT xxx.id AS team_id,
       team_create,
       yyy.id AS creator_user_id,
       creator_create
FROM
  (SELECT id,
          createdat AS team_create
   FROM default.teams
   WHERE ldate='2019-01-07')xxx
LEFT JOIN
  (SELECT id,
          team_id,
          created_at AS creator_create
   FROM default.users
   WHERE ldate='2019-01-07'
     AND team_role='creator' AND status in (0,1))yyy ON xxx.id=yyy.team_id





  --设备id，用户id。首次访问时间，首次访问渠道（sem|seo|其他网站跳转|直接访问|微信浏览器分享转发|微信端内直发）

SELECT distinct shimo_device_id,
       shimo_user_id,
       timestr,
       CASE
           WHEN user_agent REGEXP 'MicroMessenger'
                AND s_url regexp 'timeline|groupmessage|singlemessage' THEN if(s_referrer ='','微信端分享直链直接打开','微信浏览器内页面跳转')
           WHEN user_agent REGEXP 'MicroMessenger'
                AND s_url NOT regexp 'timeline|groupmessage|singlemessage' THEN if(s_referrer ='','微信端私聊群聊直接打开','微信浏览器内页面跳转')
           WHEN user_agent NOT REGEXP 'MicroMessenger'
                AND s_referrer !=''
                AND s_referrer regexp 'utm' THEN 'SEM'
           WHEN user_agent NOT REGEXP 'MicroMessenger'
                AND s_referrer !=''
                AND s_referrer NOT regexp 'utm' THEN if(s_referrer regexp 'baidu|google|bing|yahoo|sougou|360|so','自然搜索','其他网站跳转')
           WHEN user_agent NOT REGEXP 'MicroMessenger'
                AND s_referrer ='' THEN '直接打开'
           ELSE '未知'
       END AS first_visit_source
FROM --11.11后切石墨后的web侧日活跃

  (SELECT DISTINCT distinct_id AS shimo_user_id,
                   shimo_device_id,
                   timestr,
                   s_url,
                   s_referrer,
                   CASE
                       WHEN user_agent IS NOT NULL THEN user_agent
                       ELSE ''
                   END AS user_agent
   FROM web.events
   WHERE event_type = '$pageview'
     AND ldate>='2018-11-12'
   UNION ALL --11.11前神策历史数据web侧日活跃
 SELECT DISTINCT distinct_id AS shimo_user_id,
                 user_id AS shimo_device_id,
                 timestr,
                 s_url,
                 s_referrer,
                 CASE
                     WHEN user_agent IS NOT NULL THEN user_agent
                     ELSE ''
                 END AS user_agent
   FROM web.events
   WHERE event_type = '$pageview'
     AND ldate<='2018-11-11')ooo
GROUP BY shimo_device_id,
         shimo_user_id,
         first_visit_source
