SELECT reg_day,
       test_id,
       group_id,
       count(DISTINCT user_id),
       sum(if(team_id IS NOT NULL,1,0))
FROM
  (SELECT user_id,
          reg_day,
          team_id,
          shimo_device_id,
          test_id,
          group_id,
          min(time_diff)
   FROM
     (SELECT DISTINCT id AS user_id,
                      team_id,
                      trunc(register_time,'DD') AS reg_day,
                      device_users.shimo_device_id,
                      test_id,
                      group_id,
                      unix_timestamp(register_time)- unix_timestamp(timestr) AS time_diff
      FROM --16号至24号的每日注册用户

        (SELECT id,
                register_time,
                team_id
         FROM default.users
         WHERE ldate='2019-04-01'
           AND register_time BETWEEN '2019-03-16 00:00:00' AND '2019-03-24 23:59:59'
           AND status IN (0,
                          1))reg_users
      LEFT JOIN --16号至24号之间设备和用户的映射关系

        (SELECT DISTINCT shimo_device_id,
                         shimo_user_id
         FROM web.active_users
         WHERE ldate>='2019-03-16'
           AND is_login='登录' )device_users ON reg_users.id=cast(shimo_user_id AS INT)
      LEFT JOIN --每日设备分流信息

        (SELECT DISTINCT timestr,
                         shimo_device_id,
                         test_id,
                         group_id
         FROM shimo.abtest
         WHERE ldate>='2019-03-16'
           AND test_id IN ('15',
                           '16') )ab_device ON ab_device.shimo_device_id=device_users.shimo_device_id
      WHERE device_users.shimo_device_id IS NOT NULL
        AND ab_device.shimo_device_id IS NOT NULL)detail_list
   WHERE time_diff>=0
   GROUP BY user_id,
            team_id,
            shimo_device_id,
            test_id,
            group_id,
            reg_day)xxxx
GROUP BY reg_day,
         test_id,
         group_id
ORDER BY reg_day DESC,
         test_id ASC,
         group_id ASC
