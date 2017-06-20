SELECT  user_id, username, registered, viewed, explored, certified, completed,
        cc_by_ip, countryLabel, continent, city, region, un_economic_group, un_developing_nation,
        LoE, YoB, gender, grade, passing_grade, start_time, nvideos_unique_viewed, nvideos_total_watched
        ndays_act, language, mode
FROM [ubcxdata:UBCx__Marketing1x__3T2015.person_course]
WHERE cc_by_ip IS NOT NULL
LIMIT 10000
