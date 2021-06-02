-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname)
as
Select distinct rooms.unswid, rooms.longname FROM Rooms,facilities,room_facilities
Where facilities.description='Air-conditioned' and room_facilities.facility=facilities.id
and room_facilities.room=rooms.id
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q2:
create or replace view Q2(unswid,name)
as
select distinct people.unswid,people.name
from People,course_staff,course_enrolments
where people.id=course_staff.staff
and course_staff.course=course_enrolments.course
and course_enrolments.student=
(select id from people where name='Hemma Margareta');
--... SQL statements, possibly using other views/functions defined by you ...


-- Q3:
Create or replace view Q3_1(unswid,name,semester) AS                                               
Select distinct people.unswid, people.name,courses.semester from PEOPLE,Students,Course_enrolments,Courses,Subjects
	WHERE students.id=people.id and course_enrolments.student=students.id and students.stype='intl'and course_enrolments.grade='HD' 
	and course_enrolments.course= courses.id and courses.subject=subjects.id
	AND subjects.code='COMP9024';
create or replace view q3_2(unswid,name,semester) AS
	Select distinct people.unswid, people.name,courses.semester from PEOPLE,Students,Course_enrolments,Courses,Subjects
	WHERE students.id=people.id and course_enrolments.student=students.id and students.stype='intl'and course_enrolments.grade='HD' 
	and course_enrolments.course= courses.id and courses.subject=subjects.id
	AND subjects.code='COMP9311';
create or replace view Q3(unswid, name)
as 
select distinct q3_1.unswid, q3_1.name from Q3_1, q3_2
WHERE q3_1.semester = q3_2.semester and q3_1.unswid = q3_2.unswid;


--... SQL statements, possibly using other views/functions defined by you ...

-- Q4:
create or replace view q4_1(student, count_hd) as
select student, count(grade) from course_enrolments where grade='HD' group by student;
create  or replace view q4_2(count) as
select count(grade) from course_enrolments where grade='HD';
create  or replace view q4_3(count_student) as
select count(distinct student) from Course_enrolments;
create or replace view Q4(num_student)
as
select count(student) from q4_1,q4_2,q4_3 where count_HD > (q4_2.count/q4_3.count_student);
--... SQL statements, possibly using other views/functions defined by you ...


--Q5:
create or replace view q5_1(course, count_mark) as select course, count(mark) from course_enrolments where mark is not null group by course;
create or replace view q5_2(course, count_mark) as select course, count_mark from q5_1 where q5_1.count_mark >= 20;

create or replace view q5_3(course, mark) as                                       
select course_enrolments.course, course_enrolments.mark from course_enrolments, q5_2,courses
where course_enrolments.course = q5_2.course and course_enrolments.course=courses.id;
create or replace view q5_4(course, max) as 
select course,max(mark)from q5_3 group by course;
create or replace view q5_5(course,subject,semester,max) as 
select q5_4.course,courses.subject,courses.semester, q5_4.max from courses, q5_4,subjects,semesters
where courses.id=q5_4.course and subjects.id=courses.subject and courses.semester=semesters.id;
create or replace view q5_6(course,semester,min_max) as select course,semester, min(max) from q5_5 group by course,semester;

create or replace view q5_7(semester,minmax) as 
select q5_6.semester, min(q5_6.min_max) from q5_6
group by semester;
create or replace view q5(code,name,semester) as
select subjects.code, subjects.name,semesters.name from subjects,semesters,courses,q5_7,q5_5
where
semesters.id=q5_7.semester and q5_5.subject = subjects.id and courses.subject=subjects.id and courses.id=q5_5.course 
and q5_5.max=q5_7.minmax and q5_7.semester=q5_5.semester;

--... SQL statements, possibly using other views/functions defined by you ...


-- Q6:
create or replace view q6_1 as
select distinct people.unswid from semesters,program_enrolments, stream_enrolments,streams,people,students
where students.stype='local' and semesters.year=2010 and semesters.term='S1' and streams.name='Management' 
and stream_enrolments.partof = program_enrolments.id 
and program_enrolments.student=students.id 
and streams.id=stream_enrolments.stream 
and program_enrolments.student=students.id 
and students.id=people.id
and program_enrolments.semester=semesters.id;

create or replace view q6_2 as
select distinct people.unswid from students,subjects,people,orgunits,courses,course_enrolments
where orgunits.name='Faculty of Engineering' and orgunits.id=subjects.offeredby 
and subjects.id=courses.subject 
and course_enrolments.student=students.id 
and courses.id=course_enrolments.course 	
and students.id=people.id;

create or replace view Q6(num)
as
select count(*) from (select * from q6_1 except select * from q6_2) as result;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q7:
create or replace view q7_1(year,term,a_mark) as                                   
select semesters.year,semesters.term,cast(avg(course_enrolments.mark) as numeric(4,2)) 
from subjects,semesters,courses,course_enrolments 
where subjects.id=courses.subject 
and courses.id=course_enrolments.course 
and semesters.id=courses.semester 
and subjects.name='Database Systems' 
group by semesters.year,semesters.term;
create or replace view q7(year,term,average_mark) as select * from q7_1 where a_mark is not null;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q8: 
create or replace view q8_1(subject,course,year,term) as 
select subjects.id,courses.id,semesters.year,semesters.term 
from subjects,courses,semesters 
where courses.subject = subjects.id 
and courses.semester = semesters.id 
and semesters.year between 2004 and 2013 
and subjects.code like 'COMP93%' 
and semesters.term in ('S1','S2');
create or replace view q8_2(subject,year,count_term) as 
select distinct q8_1.subject, q8_1.year, count(distinct q8_1.term) from q8_1 group by subject,year;
create or replace view q8_3(subject,count_year) as 
select q8_2.subject, count(q8_2.year) from q8_2 where count_term = 2 group by subject;
create or replace view q8_4(student,subject,course,mark) as 
select people.id, q8_3.subject,courses.id,course_enrolments.mark 
from subjects, people,q8_3,courses,course_enrolments 
where people.id=course_enrolments.student 
and courses.id = course_enrolments.course 
and courses.subject = subjects.id 
and q8_3.subject = subjects.id 
and q8_3.count_year=10;
create or replace view q8_5 as select student, subject, min(mark) from q8_4 where mark is not null group by student, subject;
create or replace view q8_6(student,count_subject) as select q8_5.student,count(subject) from q8_5 where min<50 group by student;
create or replace view q8_7 as select count(distinct subject) from q8_4;


create or replace view Q8(zid, name)
as
select 'z'||people.unswid, people.name 
from q8_6,people,q8_7 
where people.id = q8_6.student and q8_6.count_subject = q8_7.count;

--... SQL statements, possibly using other views/functions defined by you ...


-- Q9:
create or replace view q9_1(student,course,program,degree,year,term) as 
select distinct people.id,courses.id, programs.id,program_degrees.abbrev,semesters.year,semesters.term 
from course_enrolments,programs,courses,program_degrees,program_enrolments,semesters,people 
where 
program_degrees.abbrev='BSc' 
and program_degrees.program=programs.id  
and courses.semester=semesters.id 
and semesters.year=2010 
and semesters.term='S2'
and people.id=course_enrolments.student
and course_enrolments.mark>=50 
and course_enrolments.course=courses.id
and program_degrees.program = program_enrolments.program
and course_enrolments.student = program_enrolments.student;

create or replace view q9_2(student,program,avg_mark) as 
select distinct q9_1.student,program_enrolments.program,avg(course_enrolments.mark) 
from q9_1,people,courses,course_enrolments,program_enrolments,semesters
where people.id=q9_1.student 
and course_enrolments.student=q9_1.student 
and courses.semester=program_enrolments.semester 
and semesters.year<2011 
and courses.semester=semesters.id 
and course_enrolments.course=courses.id 
and program_enrolments.student=course_enrolments.student 
and course_enrolments.mark >=50 
group by q9_1.student,program_enrolments.program;

create or replace view q9_3(student) as
select q9_1.student from q9_1
except
select distinct q9_2.student from q9_2
where avg_mark < 80;
create view q9_4(unswid, name, uoc) as select distinct people.unswid,people.name, programs.uoc, sum(subjects.uoc) 
from people,q9_3,courses,course_enrolments,programs,program_enrolments,subjects,semesters
where people.id=q9_3.student
and q9_3.student = course_enrolments.student 
and course_enrolments.course=courses.id
and courses.subject = subjects.id
and courses.semester=semesters.id
and courses.semester=program_enrolments.semester
and q9_3.student = program_enrolments.student
and program_enrolments.program = programs.id
and semesters.year < 2011 
and course_enrolments.mark >=50
group by people.unswid,people.name,programs.uoc;
create or replace view Q9(unswid, name)
as
select q9_4.unswid,q9_4.name from q9_4 where q9_4.sum >= q9_4.uoc;
--... SQL statements, possibly using other views/functions defined by you ...


-- Q10:
create or replace view q10_1(unswid, longname,class) as 
select distinct rooms.unswid,rooms.longname, classes.id from room_types,rooms,courses,semesters,classes
where 
semesters.year = 2011
and semesters.term='S1'
and room_types.description='Lecture Theatre'
and rooms.id=classes.room 
and classes.course=courses.id
and semesters.id = courses.semester
and room_types.id = rooms.rtype;

create or replace view q10_2(unswid,longname,count_class) as 
select q10_1.unswid,q10_1.longname,count(q10_1.class) from q10_1
group by unswid,longname;

create or replace view q10_3 as select * from q10_2 order by count_class desc;

create view q10_4(unswid,longname) as 
select distinct rooms.unswid,rooms.longname 
from rooms,classes,room_types 
where room_types.description = 'Lecture Theatre' 
and rooms.rtype = room_types.id;

create view q10_5(unswid,longname,count) as
select q10_4.unswid, q10_4.longname, COALESCE(q10_3.count_class,0)
from q10_4 left join q10_3 on q10_4.unswid = q10_3.unswid;
create view q10_6 as select * from q10_5 order by count DESC;

create or replace view Q10(unswid, longname, num, rank)
as
select q10_6.unswid,q10_6.longname,q10_6.count, rank() over (order by q10_6.count desc)
from q10_6;

--... SQL statements, possibly using other views/functions defined by you ...

