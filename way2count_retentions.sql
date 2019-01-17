SELECT sumdate, SUM(diff1) AS diff1, SUM(diff3) AS diff3
  , SUM(diff7) AS diff7
FROM (
  SELECT b.sumdate AS sumdate, a.guid, DATE(a.LOGINDATE)
    , DATEDIFF(DATE(a.LOGINDATE), b.sumdate) AS diff
    , if(DATEDIFF(DATE(a.LOGINDATE), b.sumdate) = 1, 1, 0) AS diff1
    , if(DATEDIFF(DATE(a.LOGINDATE), b.sumdate) = 3, 1, 0) AS diff3
    , if(DATEDIFF(DATE(a.LOGINDATE), b.sumdate) = 7, 1, 0) AS diff7
  FROM login_daily_tab a, (
      SELECT DATE(t.REGDATE) AS sumdate, t.guid AS new_user_guid
      FROM regedit_tab t
      WHERE DATE(t.REGDATE) BETWEEN '2016-03-01' AND '2016-03-30'
      GROUP BY DATE(t.REGDATE), t.guid
      ORDER BY DATE(t.REGDATE)
    ) b          
  WHERE a.guid = b.new_user_guid
  GROUP BY b.sumdate, a.guid, DATE(a.LOGINDATE)
  ORDER BY a.guid, DATE(a.LOGINDATE)
) logdiffs
GROUP BY sumdate
