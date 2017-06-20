
SELECT A.module_type,
       A.module_id as module_id,
	   A.user_id, 
       B.gender as gender,
	   B.mode, 
	   B.sum_dt as activity_level
FROM  

      (SELECT module_type,module_id,student_id as user_id, state
       FROM [ubcxdata:{course}.studentmodule]
       Where (module_type='video' And state Not Like '%00:00:00%') OR
             (module_type='problem' And state Like '%student_answers%') OR 
              module_type In ('openassessment', 'chapter','html')
         
       ORDER BY id 
      LIMIT {limit}) as A 

LEFT JOIN [ubcxdata:{course}.person_course] AS B 
  
ON  A.user_id = B.user_id