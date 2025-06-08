use sakila;

select * from actor;

-- root 계정만 새로운 데이터베이스 생성이 가능하다. 
-- 8 미만 버전에서는 잘못하면 한글이 깨진다. 한글 깨짐 방지 설정하기 
create database mydb; --  default character set utf8 collate utf8_general_ci;
use mydb; -- mydb 사용하기  ctrl-enter : 한줄씩 실행된다. 

 
create user 'user01'@'localhost'  identified by '1234'; 
grant all privileges  on mydb.* TO user01@localhost; 

use tuning;

-- 평상시에 workbenckh는 udate 하고 delete 명령어에 안전장치가 있어서 동작안함 
-- Edit - preferences - SQL editor (맨아래로 스크롤) 
--  Safe updates  ~~ 해제   

select count(1) from  사원;

select * from 급여 limit 10;

select * from 급여;


use mydb;
explain select * from emp;

-- emp 테이블에 primary key를 부여하자 . 부여될 필드가 중복되어서는 안되고 , not null 조건을
-- 만족해야 한다. 만일에 안될경우에는 primary조건에 위배되는 데이터를 삭제 후 primary key
-- 부여 가능   
alter table emp add primary key(empno); 

show index from emp;

explain select * from emp where empno=8000;
-- no matching row 
select empno from emp;

explain select * from emp where empno=7369;
-- primary key 
-- primary key는 아닌데 데이터 값이 중복되지 않는다 
-- null값은 가질 수 있다.
-- unique 제약조건을 주면 unique 인덱스를 만들 수 있다 
-- 예전) 사용자아이디-primary key로 많이 
-- 사용자아이디는 unique제약조건만 주고 일련번호 
-- 를primary key로 지정한다.
 
-- root 계정에만 권한이 있다 
select * from 
information_schema.table_constraints 
where table_name = '사원';

alter table dept 
add constraint primary key (deptno);

alter table emp add constraint 
fk_emp_dept foreign key(deptno)  
references dept(deptno);
-- || 없음 
select concat(ename, '님의 급여는', sal)
from emp;

-- ailasing 
select * from emp;

select a.empno, a.ename, a.sal 
from emp a;   



-- 테이블 17개 

SELECT * FROM EMP WHERE empno 
IN(7369, 7566, 7900);

-- in    = or = or = or 
-- any   부등호 or 부등호 or 부등호 or 
-- ALL   부등호 AND 부등호 and .....
-- exists - 서브쿼리를 실행한 결과 유무 
--         결과셋이 하나라도 있으면 True 반환 
--         없으면 False 
select a.ename , a.deptno
from emp a where exists (
select 'x' from dept
)
-- 국가기관 민원 



