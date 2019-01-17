--幻灯片日活跃设备-活跃用户-活跃渠道-是否登录-企业用户

SELECT DISTINCT shimo_user_id,
                shimo_device_id,
                cast(team_id AS string),
                active_source,
                guid,
                CASE
                    WHEN team_id IS NOT NULL THEN '企业用户'
                    ELSE '个人用户'
                END AS is_enterprise_user,
                is_login,
                ldate
FROM
  (--11.11后切石墨后的web侧日活跃，访问了思维导图的
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
                 END AS is_login,
                 split_part(s_url_path,'/',3) AS guid
   FROM web.events
   WHERE ldate>'2018-11-11'
     AND event_type = '$pageview'
     AND s_url_path REGEXP '/mindmaps'
     AND s_url NOT regexp 'preload'--访问页面url包含思维导图url ,不包含预加载

   UNION ALL --11.11前神策历史数据web侧日活跃，访问了思维导图的
 SELECT DISTINCT distinct_id AS shimo_user_id,
                 user_id AS shimo_device_id,
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
                 END AS is_login,
                 split_part(s_url_path,'/',3) AS guid
   FROM web.events
   WHERE ldate<='2018-11-11'
     AND event_type = '$pageview'
     AND s_url_path REGEXP '/mindmaps'
     AND s_url NOT regexp 'preload'
   UNION ALL --APP内webview数据，新增埋点事件，7号上线后正式环境有线上数据，12号以后数据保持相对稳定,上报至web.events表
 SELECT DISTINCT shimo_user_id,
                 shimo_device_id,
                 ldate,
                 CASE
                     WHEN os = 'android' THEN 'Android'
                     WHEN os = 'ios' THEN 'IOS'
                     ELSE 'other_system'
                 END AS active_source,
                 CASE
                     WHEN shimo_user_id REGEXP '^[0-9]+$' THEN '登录'
                     ELSE '匿名'
                 END AS is_login,
                 guid
   FROM web.events
   WHERE ldate >='2018-12-07'
     AND event_type = 'app_webview'
     AND cast(fileid AS int) IN --文件表，-7 思维导图

       (SELECT DISTINCT id
        FROM default.shimo_files
        WHERE ldate=date_add(to_date(now()),-1)
          AND TYPE IN (-7) )
   UNION ALL --小程序sdk打通后打开了思维导图的日活跃数据,19号上线打开文件的事件
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
                 END AS is_login,
                 guid
   FROM app.wxevents
   WHERE ldate>='2018-12-20'
     AND event_type = 'wx_openfile'
     AND cast(file_id AS int) IN
       (SELECT DISTINCT id
        FROM default.shimo_files
        WHERE ldate=date_add(to_date(now()),-1)
          AND TYPE IN (-7) )) aaa
LEFT JOIN
  (SELECT id,
          team_id
   FROM default.users
   WHERE ldate=date_add(to_date(now()),-1)
     AND team_id IS NOT NULL)bbb ON cast(aaa.shimo_user_id AS int)=bbb.id
