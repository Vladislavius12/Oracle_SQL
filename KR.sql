/* 
Создать таблицы.
Факультет:
-	Код факультета
-	Факультет
Деканат:
-	Код деканата
-	Аудитория
-	Номер телефона
Сотрудники:
-	Код сотрудника
-	Фамилия Имя Отчество
-	Должность 

Самостоятельно определить столбцы для обеспечения связи. Правило связей: каждый факультет имеет только один деканат. 
В каждом деканате работает несколько сотрудников, совмещения должностей на разных факультетах запрещены. 
Один из сотрудников является деканом факультета, все сотрудники подчиняются декану.
-	Значение поля  «Аудитория» - трехзначное число, где первая цифра – номер этажа

*/

CREATE TABLE FACULTY 
( 
CODE VARCHAR2 (45) NOT NULL PRIMARY KEY, 
TITLE VARCHAR2 (45) NOT NULL 
); 
 
CREATE TABLE DECANATS 
( 
CODE VARCHAR2 (45) NOT NULL PRIMARY KEY, 
AUDITORIYA NUMBER (3,0) NOT NULL, 
PHONE VARCHAR2 (20) NOT NULL, 
FACULTY_CODE VARCHAR2 (45) UNIQUE NOT NULL 
); 
 
CREATE TABLE EMPLOYEE 
( 
CODE VARCHAR2 (40) NOT NULL PRIMARY KEY, 
FIO VARCHAR2 (100) NOT NULL, 
DOLGNOST VARCHAR2 (45) NOT NULL, 
DECANAT_CODE VARCHAR2 (45) NOT NULL 
); 
 
ALTER TABLE DECANATS ADD CONSTRAINT FK_1 FOREIGN KEY 
(FACULTY_CODE) REFERENCES FACULTY (CODE); 
 
ALTER TABLE EMPLOYEE ADD CONSTRAINT FK_2 FOREIGN KEY 
(DECANAT_CODE) REFERENCES DECANATS (CODE); 
 
ALTER TABLE DECANATS ADD CONSTRAINT AUDITORIYA_check CHECK 
(floor(AUDITORIYA/100) < 7); 
ALTER TABLE DECANATS ADD CONSTRAINT PHONE_CHECK CHECK 
(REGEXP_LIKE(PHONE,'^([+]?[\s0-9]+)?(\d{3}|[(]?[0-9]+[)])?([-]?[\s]?[0-9])+$')); 

--Задача 1
CREATE OR REPLACE PROCEDURE DECANATS_REORGAN (mycursor OUT 
SYS_REFCURSOR) 
IS 
BEGIN 
 for METODIST in ( 
 SELECT emp.CODE as emp FROM EMPLOYEE emp 
 INNER JOIN DECANATS dc ON emp.DECANAT_CODE = dc.CODE 
 GROUP BY dc.CODE 
 having count(*) = ( 
 SELECT MAX(COUNT(emp.CODE)) FROM EMPLOYEE emp 
 INNER JOIN DECANATS dc ON emp.DECANAT_CODE = dc.CODE 
 group by dc.CODE) 
 ) 
 loop 
 update Employee set DECANAT_CODE = to_char(to_number(DECANAT_CODE) + 1) 
where CODE = METODIST.emp; 
 end loop; 
 OPEN mycursor FOR 
 SELECT emp.FIO, emp.DECANAT_CODE FROM EMPLOYEE emp 
 INNER JOIN DECANATS dc ON emp.DECANAT_CODE = dc.CODE 
 GROUP BY dc.CODE having count(*) = ( 
 SELECT MAX(COUNT(emp.CODE)) FROM EMPLOYEE emp 
 INNER JOIN DECANATS dc ON emp.DECANAT_CODE = dc.CODE 
 group by dc.CODE); 
END; 
/ 
--Задача 2
CREATE OR REPLACE FUNCTION GetMetodistCount (FACULTY_CODE IN VARCHAR2) 
RETURN NUMBER IS METODIST_COUNT NUMBER; 
BEGIN 
 SELECT floor(count(*) / 5) into METODIST_COUNT 
 FROM DECANATS 
 WHERE FACULTY_CODE = FACULTY_CODE; 
 RETURN METODIST_COUNT; 
END getMetodistCount; 
/ 
--Задача 3
CREATE TRIGGER EMPLOYEE_BEFORE_INSERT BEFORE INSERT ON EMPLOYEE 
FOR EACH ROW 
DECLARE 
 empl_count varchar2(10); 
BEGIN 
 SELECT count(CODE) INTO empl_count FROM EMPLOYEE 
 Where EMPLOYEE.DECANAT_CODE = :new.DECANAT_CODE; 
 IF empl_count > 15 
 THEN :new.DECANAT_CODE := :new.DECANAT_CODE + 1; 
 END IF; 
END; 
/ 
--Наполнение
insert into faculty values (1, 'FPMI'); 
insert into faculty values (2, 'MehMat'); 
insert into faculty values (3, 'Infa'); 
insert into faculty values (4, 'FPMI'); 
insert into faculty values (5, 'MehMat'); 
insert into faculty values (6, 'Infa'); 
select * from faculty; 
insert into decanats values (1,111,'+375112223344',1); 
insert into decanats values (2,634,'+375223344555',2); 
insert into decanats values (3,234,'+375223344555',3); 
insert into decanats values (4,334,'+375223344555',4); 
insert into decanats values (5,434,'+375223344555',5); 
insert into decanats values (6,534,'+375223344555',6); 
select * from decanats; 
insert into EMPLOYEE values (1,'decan','ned',1); 
insert into EMPLOYEE values (2,'prep1','m1',1); 
insert into EMPLOYEE values (3,'prep2','m2',1); 
insert into EMPLOYEE values (4,'prep3','m3',1); 
insert into EMPLOYEE values (5,'prep4','m4',2); 
insert into EMPLOYEE values (6,'prep5','m5',2); 
insert into EMPLOYEE values (7,'metod','m6',1); 
insert into EMPLOYEE values (8,'prep6','m7',1); 
insert into EMPLOYEE values (9,'prep7','m8',1); 
insert into EMPLOYEE values (10,'prep8','m9',1); 
insert into EMPLOYEE values (11,'prep9','m10',1); 
insert into EMPLOYEE values (12,'prep10','m11',1); 
insert into EMPLOYEE values (13,'prep11','m12',1); 
insert into EMPLOYEE values (14,'prep12','m13',1); 
insert into EMPLOYEE values (15,'prep13','m14',1); 
insert into EMPLOYEE values (16,'prep14','m15',1); 
insert into EMPLOYEE values (17,'prep15','m16',1); 
select * from EMPLOYEE; 
select getMetodistCount('1') from dual; 
SET SERVEROUTPUT ON 
declare result1 varchar2(20); 
begin 
result1 := getMetodistCount(1); 
Dbms_Output.Put_Line('The metodist count is ' || result1); 
end; 
/ 