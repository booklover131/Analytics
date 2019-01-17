SELECT aaa.id,
       aaa.name,
       aaa.TYPE,
       fuck2.duration,
       fuck2.paid_amount,
       fuck2.created_at,
       fuck2.member_count,
       fuck3.order_times,
       expired_at,
       team_users,
       bbb.member_count,
       seated_users,
       usaul_users,
       round(usaul_users/bbb.member_count,2) AS usaul_rate,
       datediff(trunc(expired_at,'DD'),to_date(now())) AS left_days,
       CASE
           WHEN bbb.member_count>=15 THEN 'A类用户'
           ELSE 'B类用户'
       END AS life_type,
       CASE
           WHEN usaul_users/bbb.member_count>=0.5 THEN '维护期'
           WHEN (usaul_users/bbb.member_count)>=0.4
                AND (usaul_users/bbb.member_count)<0.5 THEN '适应期'
           ELSE '学习期'
       END AS life_circle,
       (team_users-bbb.member_count) AS buy_potential
FROM --企业注册信息，固定不变信息

  (SELECT id,
          name,
          TYPE
   FROM default.teams
   WHERE ldate=date_add(to_date(now()),-1))aaa
INNER JOIN --首次付费信息，固定不变信息

  (SELECT target_id,
          duration,
          paid_amount,
          created_at,
          member_count
   FROM
     (SELECT row_number() OVER (PARTITION BY target_id
                                ORDER BY created_at ASC) AS row_nums,
             target_id,
             duration,
             amount/100 AS paid_amount,
             created_at,
             member_count
      FROM default.orders
      WHERE ldate=date_add(to_date(now()),-1)
        AND target_type=2
        AND is_paid=1)fuck1
   WHERE row_nums =1)fuck2 ON aaa.id= fuck2.target_id 
   --企业付费订单数
INNER JOIN
  (SELECT target_id,
          count(DISTINCT id) AS order_times
   FROM default.orders
   WHERE ldate=date_add(to_date(now()),-1)
     AND target_type=2
     AND is_paid=1
   GROUP BY target_id)fuck3 ON aaa.id=fuck3.target_id
INNER JOIN 
--当前付费状态信息，可变信息,每周一跑，取截止上周末的付费状态数据，企业到期时间，企业席位数

  (SELECT target_id,
          expired_at,
          member_count
   FROM default.membership
   WHERE ldate=date_add(to_date(now()),-1)
     AND target_type=2
     AND is_official=1
     AND trunc(expired_at,'dd')>ldate) bbb ON aaa.id=bbb.target_id
INNER JOIN
--企业当前用户数，席位上用户数
  (SELECT team_id,
          count(DISTINCT id) AS team_users,
          count(CASE
                    WHEN is_seat=1 THEN id
                    ELSE NULL
                END) AS seated_users
   FROM default.users
   WHERE ldate=date_add(to_date(now()),-1)
     AND team_id IS NOT NULL
   GROUP BY team_id)ccc ON aaa.id=ccc.team_id
INNER JOIN
--企业常用用户数，过去一个月的活跃天数大于等于8天的用户数
  (SELECT team_id,
          count(DISTINCT shimo_user_id) AS usaul_users
   FROM
     (SELECT shimo_user_id,
             team_id,
             count(DISTINCT ldate) AS visit_days
      FROM web.active_users
      WHERE ldate>=date_sub(to_date(now()),30)
        AND is_login='登录'
        AND is_enterprise_user='企业用户'
      GROUP BY shimo_user_id,
               team_id
      HAVING count(DISTINCT ldate)>=8)wtf1
   GROUP BY team_id)ddd ON aaa.id=cast(ddd.team_id AS int)
