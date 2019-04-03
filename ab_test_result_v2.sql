SELECT ab_day,
       test_id,
       group_id,
       count(DISTINCT shimo_device_id) AS ab_devices,
       count(DISTINCT if(time_diff>=0,user_id,NULL)) AS reg_users,
       count(DISTINCT if(time_diff>=0,CASE
                                          WHEN team_id IS NULL THEN user_id
                                          ELSE NULL
                                      END,NULL)) AS reg_personal_users
FROM
  (SELECT DISTINCT to_date(timestr) AS ab_day,
                   ab_device.shimo_device_id,
                   test_id,
                   group_id,
                   id AS user_id,
                   team_id,
                   unix_timestamp(register_time)- unix_timestamp(timestr) AS time_diff
   FROM
     (--16号后首次分流的设备对应的日期，设备，分组信息
 SELECT min(from_unixtime(unix_timestamp(regexp_replace(timestr,'T',' '))+28800,'yyyy-MM-dd HH:mm:ss')) AS timestr,
        shimo_device_id,
        test_id,
        group_id
      FROM shimo.low_abtest
      WHERE ldate>='2019-03-16'
        AND test_id IN ('15',
                        '16')
      GROUP BY shimo_device_id,
               test_id,
               group_id)ab_device
   LEFT JOIN
     (--活跃设备-活跃登录用户关联关系
 SELECT DISTINCT shimo_device_id,
                 shimo_user_id
      FROM web.active_users
      WHERE ldate>='2019-03-16'
        AND is_login='登录' )device_users ON ab_device.shimo_device_id=device_users.shimo_device_id
   LEFT JOIN
     (--16号后注册用户，注册时间，企业id
 SELECT id,
        register_time,
        team_id
      FROM default.users
      WHERE ldate='2019-04-01'
        AND register_time >= '2019-03-16 00:00:00'
        AND status IN (0,
                       1))reg_users ON reg_users.id=cast(shimo_user_id AS INT))detail_list
GROUP BY ab_day,
         test_id,
         group_id
ORDER BY ab_day DESC,
         test_id ASC,
         group_id ASC
