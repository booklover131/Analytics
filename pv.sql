INSERT INTO all_pv_tbl(pvcnt,active_source,is_login,ldate)
SELECT count(*) AS cnt,
       active_source,
       is_login,
       ldate
FROM
  (--11.11后切石墨后的web侧日活跃，访问了文档的
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
        CASE
            WHEN distinct_id REGEXP '^[0-9]+$' THEN '登录'
            ELSE '匿名'
        END AS is_login
   FROM web.events
   WHERE event_type = '$pageview'
     AND ldate>='2019-04-01' and ldate<='2019-04-09'
  )aaa
GROUP BY ldate,
         active_source,
         is_login
         
