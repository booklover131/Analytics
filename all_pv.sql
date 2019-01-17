--全站PV，活跃渠道，是否登录，是否企业用户，pv数

SELECT ldate,
       active_source,
       is_login,
       CASE
           WHEN team_id IS NOT NULL
                AND is_login='登录' THEN '企业用户'
           WHEN team_id IS NULL
                AND is_login='登录' THEN '个人用户'
           ELSE '未登录用户'
       END AS is_enterprise_user,
       sum(PV) AS PV
FROM
  (--11.11后切石墨后的web侧日活跃
 SELECT ldate,
        CASE
            WHEN user_agent REGEXP 'wxwork' THEN '企业微信'
            WHEN user_agent REGEXP 'dingtalk'
                 OR user_agent REGEXP 'DingTalk'THEN '钉钉'
            WHEN user_agent NOT LIKE '%wxwork%'
                 AND user_agent REGEXP 'MicroMessenger'
                 AND os = 'android' THEN 'Mobile_Android_个人微信'
            WHEN user_agent NOT LIKE '%wxwork%'
                 AND user_agent REGEXP 'MicroMessenger'
                 AND os = 'ios' THEN 'Mobile_IOS_个人微信'
            WHEN os = 'android' THEN 'Mobile_Android'
            WHEN os = 'ios' THEN 'Mobile_IOS'
            WHEN user_agent REGEXP 'Electron' THEN '桌面客户端Webview'
            ELSE 'Web'
        END AS active_source,
        distinct_id AS shimo_user_id,
        CASE
            WHEN distinct_id REGEXP '^[0-9]+$' THEN '登录'
            ELSE '匿名'
        END AS is_login,
        count(*) AS PV
   FROM web.events
   WHERE event_type = '$pageview'
     AND ldate>='2018-11-12'
   GROUP BY ldate,
            active_source,
            is_login,
            distinct_id
   UNION ALL --11.11前神策历史数据web侧日活跃
 SELECT ldate,
        CASE
            WHEN useragent REGEXP 'wxwork' THEN '企业微信'
            WHEN useragent REGEXP 'dingtalk'
                 OR useragent REGEXP 'DingTalk'THEN '钉钉'
            WHEN useragent NOT LIKE '%wxwork%'
                 AND useragent REGEXP 'MicroMessenger'
                 AND os = 'Android' THEN 'Mobile_Android_个人微信'
            WHEN useragent NOT LIKE '%wxwork%'
                 AND useragent REGEXP 'MicroMessenger'
                 AND os = 'iOS' THEN 'Mobile_IOS_个人微信'
            WHEN os = 'Android' THEN 'Mobile_Android'
            WHEN os = 'iOS' THEN 'Mobile_IOS'
            WHEN useragent REGEXP 'Electron' THEN '桌面客户端Webview'
            ELSE 'Web'
        END AS active_source,
        distinct_id AS shimo_user_id,
        CASE
            WHEN distinct_id REGEXP '^[0-9]+$' THEN '登录'
            ELSE '匿名'
        END AS is_login,
        count(*) AS PV
   FROM web.events
   WHERE event_type = '$pageview'
     AND ldate<='2018-11-11'
   GROUP BY ldate,
            active_source,
            is_login,
            distinct_id
   UNION ALL --APP神策订阅数据日活跃
 SELECT ldate,
        CASE
            WHEN os = 'Android' THEN 'Android'
            WHEN os = 'iOS' THEN 'IOS'
            ELSE 'other_system'
        END AS active_source,
        distinct_id AS shimo_user_id,
        CASE
            WHEN distinct_id REGEXP '^[0-9]+$' THEN '登录'
            ELSE '匿名'
        END AS is_login,
        count(*) AS PV
   FROM app.appevent
   WHERE event_type = '$AppStart'
   GROUP BY ldate,
            active_source,
            is_login,
            distinct_id
   UNION ALL --小程序sdk打通后日活跃数据,含冷启动launch和热启动show
 SELECT ldate,
        CASE
            WHEN os = 'Android' THEN 'Android-小程序'
            WHEN os = 'iOS' THEN 'IOS-小程序'
            ELSE 'other_system'
        END AS active_source,
        distinct_id AS shimo_user_id,
        CASE
            WHEN shimo_user_id REGEXP '^[0-9]+$' THEN '登录'
            ELSE '匿名'
        END AS is_login,
        count(*) AS PV
   FROM app.wxevents
   WHERE event_type IN ('$MPShow',
                        '$MPLaunch')
     AND ldate>='2018-12-07'
   GROUP BY ldate,
            active_source,
            is_login,
            distinct_id) aaa
LEFT JOIN
  (SELECT id,
          team_id
   FROM default.users
   WHERE ldate=date_add(to_date(now()),-1)
     AND team_id IS NOT NULL)bbb ON cast(aaa.shimo_user_id AS int)=bbb.id
GROUP BY ldate,
         active_source,
         is_login,
         is_enterprise_user
