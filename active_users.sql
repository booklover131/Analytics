--全站活跃用户，活跃设备，企业id，活跃渠道
SELECT DISTINCT shimo_user_id,
                shimo_device_id,
                team_id,
                CASE
                    WHEN team_id IS NOT NULL THEN '企业用户'
                    ELSE '个人用户'
                END AS is_enterprise_user,
                ldate,
                active_source,
                is_login
FROM
  (--11.11后切石墨后的web侧日活跃
 SELECT DISTINCT distinct_id AS shimo_user_id,
                 shimo_device_id,
                 ldate,
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
                 CASE
                     WHEN distinct_id REGEXP '^[0-9]+$' THEN '登录'
                     ELSE '匿名'
                 END AS is_login
   FROM web.events
   WHERE event_type = '$pageview'
     AND ldate>'2018-11-11'
   UNION ALL --11.11前神策历史数据web侧日活跃
 SELECT DISTINCT distinct_id AS shimo_user_id,
                 user_id AS shimo_device_id ,
                 ldate,
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
                 CASE
                     WHEN distinct_id REGEXP '^[0-9]+$' THEN '登录'
                     ELSE '匿名'
                 END AS is_login
   FROM web.events
   WHERE event_type = '$pageview'
     AND ldate<='2018-11-11'
   UNION ALL --APP神策订阅数据日活跃+新版本数据仓库接收数据
 SELECT DISTINCT distinct_id AS shimo_user_id,
                 CASE
                     WHEN s_app_version IN ('2.10.6',
                                            '2.10.7') THEN shimo_device_id
                     ELSE user_id
                 END AS shimo_device_id,
                 ldate,
                 CASE
                     WHEN os = 'Android' THEN 'Android'
                     WHEN os = 'iOS' THEN 'IOS'
                     ELSE 'other_system'
                 END AS active_source,
                 CASE
                     WHEN distinct_id REGEXP '^[0-9]+$' THEN '登录'
                     ELSE '匿名'
                 END AS is_login
   FROM app.appevent
   WHERE event_type = '$AppStart'
   UNION ALL --小程序sdk打通后日活跃数据,含冷启动launch和热启动show
 SELECT DISTINCT shimo_user_id,
                 shimo_device_id,
                 ldate,
                 CASE
                     WHEN os = 'Android' THEN 'Android-小程序'
                     WHEN os = 'iOS' THEN 'IOS-小程序'
                     ELSE 'other_system'
                 END AS active_source,
                 CASE
                     WHEN shimo_user_id REGEXP '^[0-9]+$' THEN '登录'
                     ELSE '匿名'
                 END AS is_login
   FROM app.wxevents
   WHERE event_type IN ('$MPShow',
                        '$MPLaunch')
     AND ldate>='2018-12-07' ) aaa
LEFT JOIN
  (SELECT cast(id AS string) id,
          team_id
   FROM default.users
   WHERE ldate = '2018-12-13'
     AND team_id IS NOT NULL)bbb ON aaa.shimo_user_id=bbb.id
