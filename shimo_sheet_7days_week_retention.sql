--表格活跃用户次周留存
SELECT aaa.active_start_week,
       count(DISTINCT aaa.shimo_user_id) AS start_week_users,
       ndv(CASE
               WHEN bbb.active_end_week>aaa.active_start_week
                    AND weekofyear(active_end_week)-weekofyear(active_start_week)=1
                    AND bbb.shimo_user_id IS NOT NULL THEN bbb.shimo_user_id
               ELSE NULL
           END) AS end_week_users
FROM
  (SELECT DISTINCT trunc(ldate,'WW') AS active_start_week,
                   shimo_user_id
   FROM web.sheet_active_users
   WHERE is_login='登录' )aaa
LEFT JOIN
  (SELECT DISTINCT trunc(ldate,'WW') AS active_end_week,
                   shimo_user_id
   FROM web.sheet_active_users
   WHERE is_login='登录' )bbb ON aaa.shimo_user_id=bbb.shimo_user_id
GROUP BY aaa.active_start_week
ORDER BY aaa.active_start_week DESC

--表格新增用户次周留存
SELECT aaa.active_start_week,
       count(DISTINCT aaa.id) AS start_week_users,
       ndv(CASE
               WHEN bbb.active_end_week>aaa.active_start_week
                    AND weekofyear(active_end_week)-weekofyear(active_start_week)=1
                    AND bbb.shimo_user_id IS NOT NULL THEN bbb.shimo_user_id
               ELSE NULL
           END) AS end_week_users
FROM
  (SELECT DISTINCT id,
                   trunc(register_time,'WW') AS active_start_week
   FROM
     (SELECT DISTINCT id,
                      register_time
      FROM default.users
      WHERE ldate=date_add(to_date(now()),-1)
        AND users.status IN (0,
                             1))xxx
   LEFT JOIN
     (SELECT DISTINCT shimo_user_id,
                      ldate
      FROM web.sheet_active_users
      WHERE is_login='登录')yyy ON xxx.id= cast(yyy.shimo_user_id AS INT)
   WHERE yyy.shimo_user_id IS NOT NULL
     AND trunc(register_time,'WW')=trunc(ldate,'WW'))aaa
LEFT JOIN
  (SELECT DISTINCT trunc(ldate,'WW') AS active_end_week,
                   shimo_user_id
   FROM web.sheet_active_users
   WHERE is_login='登录' )bbb ON aaa.id=cast(bbb.shimo_user_id AS int)
GROUP BY aaa.active_start_week
ORDER BY aaa.active_start_week DESC

