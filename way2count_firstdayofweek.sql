////取每周第一天和最后一天
////周六开始
////周一开始
select
 day
 ,dayofweek(day)                                                                    as dw1
 ,date_add(day,1 - dayofweek(day))                                                  as Su_s -- 周日_start
 ,date_add(day,7 - dayofweek(day))                                                  as Sa_e -- 周六_end
 ,case when dayofweek(day) = 1 then 7 else dayofweek(day) - 1 end                   as dw2
 ,date_add(day,1 - case when dayofweek(day) = 1 then 7 else dayofweek(day) - 1 end) as Mo_s -- 周一_start
 ,date_add(day,7 - case when dayofweek(day) = 1 then 7 else dayofweek(day) - 1 end) as Su_e -- 周日_end



//取现在时间的上周周一

to_date(
	date_add(
		current_date(), -6-(CASE  WHEN dayofweek(current_date())=1 
						 THEN dayofweek(current_date())=7
                         ELSE dayofweek(current_date())-1
                         END)
		)
	)

/*现在时间的上周周天*/

to_date(
	date_add(
		current_date(), 0-(CASE  WHEN dayofweek(current_date())=1 
						 THEN dayofweek(current_date())=7
                         ELSE dayofweek(current_date())-1
                         END)
		)
	)
