
-- ====================================================================================
-- == 3.1.1 ===========================================================================
-- ====================================================================================

-- * 명령문 : MySQL을 설치할 경우 설치되는 기본폴더이다.
-- 폴더 이동 명령어이나 설치시 자동으로 환경변수가 등록된다. 그래서 굳이 경로 이동을 할 필요는 없다 
-- 어디에 있던 동일한 방법으로 실행이 가능하다. 
-- mysql -u 계정명 -p 패스워드 --port 포트번호 
-- 반드시 패스워드나 포트번호를 주지는 않아도 된다. 단 포트번호가 기본포트번호인 3306이 아니라면 따로 주어야 한다 
-- mysql이 이미 설치되어 있거나 mariadb가 설치되어 있는 경우에는 포트번호가 다르게 설치될 수 있어서 설치시 주의를 해야 한다 
-- 
--  cd C:\Program Files\MySQL\MySQL Server 8.0\bin
--  Program Files\MySQL\MySQL Server 8.0\bin $ mysql -uroot -p --port 3306

* 결과
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.20 MySQL Community Server - GPL

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
====================================================================================
* SQL

show databases;  -- 시스템이 가지고 있는 데이터베이스를 보여준다. 
                 -- mysql이나 mssql은 데이터베이스를 만들어놓고 계정을 연결하는 방법을 취한다. 
                 -- 설치시 기본 예제를 설치했다면 그 예제들이 있다. 

* 결과
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.01 sec)


====================================================================================
== 3.1.3 ===========================================================================
====================================================================================

* 명령문  - 데이터파일을 이 폴더에 놓았을때 압축을 풀어서 파일을 가져다 이 폴더에 놓아야 한다 
cd c:\db_data

* 결과
c:\db_data>

##################################
명령문수정작업 == 데이터파일 읽어들이기
##################################
mysql -u root -p  < data_setting.sql

* 결과
INFO
LOADING emp.sql
INFO
LOADING dept.sql
INFO
LOADING emp_hist1.sql
INFO
LOADING emp_hist2.sql
INFO
LOADING grade.sql
INFO
LOADING sal1.sql
INFO
LOADING sal2.sql
INFO
LOADING sal3.sql
INFO
LOADING sal4.sql
INFO
LOADING sal5.sql
INFO
LOADING sal6.sql


====================================================================================
== 3.1.4 ===========================================================================
====================================================================================

* 명령문
mysql -uroot -p --port 3306
* 결과 : 없음
====================================================================================
* SQL
use tuning;
* 결과
Database changed
====================================================================================
* SQL
show tables;

* 결과
+-------------------+
| Tables_in_tunning |
+-------------------+
| 급여              |
| 부서              |
| 부서관리자        |
| 부서사원_매핑     |
| 사원              |
| 사원출입기록      |
| 직급              |
+-------------------+
7 rows in set (0.01 sec)

====================================================================================
* SQL 
select count(*) from 사원; 

* 결과
+----------+
| count(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.32 sec)

#테이블 구조를 확인하자 
desc 사원;
+--------------+---------------+------+-----+---------+-------+
| Field        | Type          | Null | Key | Default | Extra |
+--------------+---------------+------+-----+---------+-------+
| 사원번호     | int           | NO   | PRI | NULL    |       |
| 생년월일     | date          | NO   |     | NULL    |       |
| 이름         | varchar(14)   | NO   |     | NULL    |       |
| 성           | varchar(16)   | NO   |     | NULL    |       |
| 성별         | enum('M','F') | NO   | MUL | NULL    |       |
| 입사일자     | date          | NO   | MUL | NULL    |       |
+--------------+---------------+------+-----+---------+-------+

#데이터를 점검해보자 -- 데이터가 많으므로 앞의 10개만 확인해보자 
select * from 사원  limit 10; 

select * from 사원  order by 사원번호 desc limit 10; 

-- 10001 ~ 499999 범위에 데이터가 존재 한다 

select * from 사원 where 사원번호=100000;


#실행계획은 실제로 실행을 하는것은 아니므로 조건을 부여했을 경우의  상태를 보는데
#mysql은 쿼리 결과가 없을경우 에러가 나온다.  
#
explain select * from 사원 where 사원번호=100000;

MySQL [tuning]> explain select * from 사원 where 사원번호=100000;
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table  | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | 사원   | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.003 sec)

id: 쿼리의 실행 단계를 나타냅니다. 1이므로 단일 테이블 조회입니다.
select_type: SIMPLE은 JOIN이나 SUBQUERY가 없는 단순한 SELECT 문을 의미합니다.
table: 사원 테이블을 조회하고 있습니다.
partitions: NULL이므로 파티션을 사용하지 않는다는 의미입니다.
type: const → 가장 효율적인 조회 방식 중 하나로, 기본 키(Primary Key)를 사용한 고정된 값을 기반으로 한 조회입니다.
      유니크 인덱스 검색을 사용한다. 기본키가 unique 인덱스가 있을 경우에 나온다. 

possible_keys: PRIMARY → 사용 가능한 인덱스는 PRIMARY KEY입니다.
key: PRIMARY → 실제 사용된 인덱스도 PRIMARY KEY입니다.
key_len: 4 → 인덱스의 길이입니다. 일반적으로 INT 타입의 PRIMARY KEY는 4바이트입니다.
ref: const → 기본 키 값으로 조회하는 것이므로 참조 값은 const입니다.
rows: 1 → 조회할 것으로 예상되는 행 개수입니다. 기본 키 조회이므로 1개만 반환됩니다.
filtered: 100.00 → 필터링되는 비율로, 100%이므로 모든 행이 반환될 것임을 의미합니다.
Extra: NULL → 추가적인 작업이 필요하지 않다는 의미입니다.

====================================================================================
== 3.2.1 ===========================================================================
====================================================================================
* 인덱스 범위 검색  
EXPLAIN  SELECT * FROM 사원 WHERE 사원번호 BETWEEN 100001 AND 200000;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+-------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 20080 |   100.00 | Using where |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+-------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

type 이 range이다 범위검색을 말한다. 특정범위를 지정한다.   
====================================================================================
* SQL
show index from 사원; -- 인덱스 확인명령어 

+--------+------------+----------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table  | Non_unique | Key_name       | Seq_in_index | Column_name  | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+--------+------------+----------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원   |          0 | PRIMARY        |            1 | 사원번호       | A         |      299512 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원   |          1 | I_입사일자      |            1 | 입사일자       | A         |        4174 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원   |          1 | I_성별_성       |            1 | 성별          | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원   |          1 | I_성별_성       |            2 | 성            | A         |        3360 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+--------+------------+----------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
primary key - unque  인덱스 
입사일자, 성별성 성에 대해서 인덱스를 생성함 

모든 인덱스를 제거해보자 : 명령어 형태 
primary key의 경우 다른 테이블로 부터 참조중일 수 있으므로 참조부터 삭제해야 한다.  
primary key 삭제 
ALTER TABLE 테이블명 DROP PRIMARY KEY; 

alter table  사원 drop primary key
 
alter table 사원 drop index I_입사일자;


####################
복합 인덱스란 
###################
여러 개의 컬럼을 하나의 인덱스로 묶어 검색을 최적화하는 방식
I_성별_성 인덱스는 (성별, 성) 컬럼으로 이루어진 복합 인덱스이다. 
이 인덱스는 성별 컬럼을 먼저 정렬한 후, 같은 성별 내에서 성 컬럼을 정렬하는 방식으로 동작합니다.

일반 인덱스 삭제 

ALTER TABLE 테이블명 DROP INDEX 인덱스명;
DROP INDEX 인덱스명 ON 테이블명;

alter table 사원 drop index I_입사일자;
alter table 사원 drop index I_성별_성;

show index from 사원;


EXPLAIN SELECT * FROM 사원 WHERE 사원번호 = 10000;

EXPLAIN SELECT * FROM 사원 WHERE 사원번호 BETWEEN 100001 AND 200000;

* 결과
EXPLAIN SELECT * FROM 사원 WHERE 사원번호 BETWEEN 100001 AND 200000;
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원   | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299439 |    11.11 | Using where |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.001 sec)

필드명	값	설명
id	1	실행 순서를 나타냄. 단일 쿼리이므로 1.
select_type	SIMPLE	서브쿼리나 JOIN 없이 실행되는 기본적인 SELECT 문.
table	사원	조회 대상 테이블이 사원 테이블임.
type	range	인덱스를 활용한 범위 검색(성능이 좋은 편).
possible_keys	PRIMARY	사용 가능한 인덱스는 PRIMARY 키.
key	PRIMARY	실제 사용된 인덱스는 PRIMARY.
key_len	4	사용된 인덱스의 길이는 4바이트 (INT 타입의 PK).
ref	NULL	ref 값이 없으므로 특정 값을 기반으로 한 조인이 아님.
rows	20080	MySQL이 예상하는 검색해야 할 행 개수 (약 20,080개).
Extra	Using where	WHERE 조건을 사용하여 필터링함.

#### primary key 추가 ####################
ALTER TABLE 사원 ADD PRIMARY KEY (사원번호);
show index from 사원;

explain select * from 사원 where 사원번호=10000;

EXPLAIN SELECT * FROM 사원 WHERE 사원번호 BETWEEN 100001 AND 200000;

MySQL [tuning]> EXPLAIN SELECT * FROM 사원 WHERE 사원번호 BETWEEN 100001 AND 200000;
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원    | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299238 |    11.11 | Using where  |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+

1. id: 1
이 값은 실행 순서를 나타냅니다.값이 1이므로 서브쿼리 없이 단일 쿼리(SIMPLE)가 실행됩니다.
2. select_type: SIMPLE
서브쿼리나 UNION 없이 실행되는 기본적인 SELECT 문입니다.
3. table: 사원
사원 테이블을 대상으로 쿼리가 실행됩니다.
4. partitions: NULL
파티션이 사용되지 않았음을 의미합니다.
5. type: ALL (⚠️ 성능 저하 가능)
ALL은 테이블 전체를 스캔(Full Table Scan)하는 방식입니다.
이는 성능이 좋지 않으며, 인덱스를 사용하지 않고 모든 행을 확인하고 있다는 의미입니다.
ALL이 나오면 인덱스를 추가하거나 쿼리를 최적화하는 것이 좋습니다.
6. possible_keys: NULL
사용 가능한 인덱스가 없음을 의미합니다.
WHERE 절에 포함된 컬럼에 적절한 인덱스를 추가하면 성능이 개선될 수 있습니다.
7. key: NULL
실제 사용된 인덱스가 없다는 뜻입니다.
possible_keys가 NULL이므로 인덱스를 전혀 사용하지 않은 것입니다.
8. key_len: NULL
인덱스를 사용하지 않았기 때문에 NULL입니다.
9. ref: NULL
조인 시 어떤 컬럼을 기준으로 참조하는지 나타내지만, 현재 쿼리는 단일 테이블 조회이므로 NULL입니다.
10. rows: 299238
MySQL이 예상하는 조회 행의 개수입니다.
즉, 전체 299,238개의 레코드를 확인해야 하는 것으로 보입니다.
11. filtered: 11.11
WHERE 절 조건을 만족하는 행의 비율(%)입니다.
전체 데이터(299,238개) 중 약 11.11%만 최종적으로 결과에 포함됩니다.
299,238개의 11.11%는 약 33,270개의 행이 필터링되어 최종 결과에 남게 됩니다.
12. Extra: Using where
WHERE 절이 사용되었다는 의미입니다.
하지만 인덱스를 사용하지 않고 있기 때문에 성능이 좋지 않을 가능성이 큽니다.


#range 검색
explain select * from 사원 where 사원번호<100000;

MySQL [tuning]> explain select * from 사원 where 사원번호<100000;
+----+-------------+--------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
| id | select_type | table  | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+--------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원   | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 149601 |   100.00 | Using where |
+----+-------------+--------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+

explain select * from 사원 where 사원번호=100000 or  사원번호=100001 or  사원번호=100003;

#in 연산자도 범위 연산자이므로 range 검색을 진행한다. 
explain select * from 사원 where 사원번호 in (100000,20000, 300000);


explain select * from 사원 order by  사원번호;
-- index - 모든 인덱스를 순차검색한다 


explain select * from 사원 order by  사원번호 desc;
-- index - 모든 인덱스를 역으로 순차검색한다

alter table  사원 drop primary key;   -- 이 명령 삭제후 다시 수행 

alter table 사원 add primary key(사원번호);  -- 다시 추가한다 
show index from 사원;


-- ######### 일반인덱스 ################
-- 데이터가 unqiue 제약조건을 만족하지 못할경우에 일반 인덱스를 부여한다 

--  기본문법 : ALTER TABLE 테이블명 ADD INDEX 인덱스이름 (컬럼명);

alter table 사원 add index I_입사일자(입사일자);  -- 인덱스 추가하기 

show index from 사원; -- 인덱스 테이블 확인 명령어 

explain select * from 사원 where 입사일자='1989-08-24'; 
-- 인덱스의 경우에 주로 ref 방식으로 인덱스 검색을 한다 
-- 인덱스 테이블을 읽고 그걸 바탕으로 데이터테이블을 읽는다. 


ref 는 "참조(Reference) 조건을 이용한 인덱스 검색" 을 의미합니다.
ref 타입은 인덱스를 사용하여 특정 값을 검색하지만, 완전한 일치 검색이 아닌 부분 매칭이 포함될 때 발생한다. 
ref 에는 const 항목이 있음 

인덱스를 이용하여 데이터를 검색하지만, 완전한 유일 검색(Unique Lookup)이 아닌 경우
주로 일반 인덱스(INDEX), UNIQUE 인덱스에서 부분 일치 검색일 때 발생
비교 연산자 (=,  <=>)를 사용하여 인덱스 검색할 때 사용됨
일반적으로 성능이 좋음 (범위 검색보다 효율적)




-- 인덱스가 없으므로 full scan을 한다 
explain select * from 사원 where 이름='Tzvetan';
create index I_이름 on 사원(이름);
show index from 사원;
explain select * from 사원 where 이름='Tzvetan'; -- 인덱스 검색 

explain select * from 사원 where 이름 like 'Tz%'; -- range인덱스 

explain select * from 사원 where 이름 like '%tan'; -- not index full scan을 한다 

#####################
fulltext 인덱스 
#######################
-- fulltext 인덱스를 생성해야 한다. 
drop index I_이름 on 사원;

SHOW TABLE STATUS LIKE '사원';
-- full text 인덱스 만들기 
ALTER TABLE 사원 ADD FULLTEXT(이름);

explain SELECT *
FROM 사원
WHERE MATCH(이름) AGAINST('etan');

#최소 단어 길이	기본 4자 이상 (변경 가능: ft_min_word_len)
#불용어 목록	기본 리스트 존재 (stopwords)
#언어	MySQL의 기본 언어 분석기 사용 (Ngram도 설정 가능)

##############################
함수기반인덱스
함수 기반 인덱스(Function-based Index) 기능을 MySQL 8.0.13 이상에서부터 지원합니다.
##############################
show index from 사원;  -- 입사일자에 인덱스가 있음
select 입사일자 from 사원 limit 10; 

explain select * from 사원 where 입사일자='1985-01-01';

select substring(입사일자, 1,4) from 사원 limit 5;

explain select * from 사원 where substring(입사일자, 1,4)='1985'; -- 필드에 함수를 사용함, full scan을 한다 

1.별도의 컬럼을 반드시 추가해야 한다 
ALTER TABLE 사원
ADD COLUMN 입사연도 VARCHAR(4) GENERATED ALWAYS AS (substring(입사일자,1,4)) STORED;

alter table 사원 drop column 입사연도;
 
2. 추가된 컬럼으로 인덱스를 만든다 
create index I_함수인덱스 on 사원(입사연도); 

STORED 또는 VIRTUAL 가상 컬럼만 인덱스 가능
지원 함수	일반적인 문자열, 수학 함수 가능 (LOWER, UPPER, ABS, DATE() 등)
성능	조건절에 동일한 함수 사용 시 인덱스 사용 가능

-- 함수인덱스를 탄다 
explain select * from 사원 where substring(입사일자, 1,4)='1985'; -- 필드에 함수를 사용함, full scan을 한다 

-- 자주 사용하는 필드 WHERE 조건절이나 ORDER BY에서 없는건 고려 조차 하지 않는다. 
-- 지나치게 인덱스가 많을 경우에는 시스템 성능이 저하된다. 
-- 데이터가 많지 않은데도 속도가 느릴경우에는 프로그램 코드가 잘못되어 있을 경우가 더 많다
-- 쿼리는 가급적 한번에 가져와야 한다. UNION 등을 적절히 활용하는 것이 좋다. 
-- 쿼리에서의 함수 사용은 전체 성능 저하를 가져온다. 외부 루프에서만 함수를 사용하자. 

########## NULL값도 인덱스 검색이 된다. 
explain select * from 사원 WHERE 입사일자 IS NULL;

explain select * from 사원 order by 사원번호;

explain select * from 사원 order by 사원번호 desc;

====================================================================================
== 3.2.2 ===========================================================================
====================================================================================
* SQL

조인의 경우 - 실행계획, ansi 조인은 아니다.  
MySQL에서의 join이고 표준은 아니다. 

#전체 조인의 경우 아주 많은 시간이 필요하다 
EXPLAIN SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
FROM 사원, 급여
where 사원.사원번호 = 급여.사원번호;


MySQL [tuning]> EXPLAIN SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
    -> FROM 사원, 급여
    -> where 사원.사원번호 = 급여.사원번호;
+----+-------------+--------+------------+------+---------------+---------+---------+----------------------------+--------+----------+-------+
| id | select_type | table  | partitions | type | possible_keys | key     | key_len | ref                        | rows   | filtered | Extra |
+----+-------------+--------+------------+------+---------------+---------+---------+----------------------------+--------+----------+-------+
|  1 | SIMPLE      | 사원   | NULL       | ALL  | PRIMARY       | NULL    | NULL    | NULL                       | 299423 |   100.00 | NULL  |
|  1 | SIMPLE      | 급여   | NULL       | ref  | PRIMARY       | PRIMARY | 4       | tuning.사원.사원번호         |      9 |   100.00 | NULL  |
+----+-------------+--------+------------+------+---------------+---------+---------+----------------------------+--------+----------+-------+
2 rows in set, 1 warning (0.002 sec)

사원테이블의 전체 데이터와 급여테이블에서의 primary key를 상대로 join을 진행한다. 

 1) Nested Loop Join (중첩 루프 조인, 기본 방식)
MySQL에서 기본적으로 사용하는 조인 방식
한 테이블을 읽고(outer loop), 다른 테이블에서 해당 행과 일치하는 값을 찾음(inner loop).
인덱스가 있으면 성능이 향상되지만, 없으면 느림.

🔹 2) Block Nested Loop Join (BNL, 블록 중첩 루프 조인)
MySQL이 인덱스를 사용할 수 없을 때 적용.
한 테이블을 메모리에 블록 단위로 로드한 후, 다른 테이블과 비교하여 JOIN.
JOIN BUFFER를 사용하여 성능을 최적화.

 3) Index Nested Loop Join (인덱스 중첩 루프 조인)
Nested Loop Join을 사용할 때 두 번째 테이블에 인덱스가 있으면 최적화됨.
첫 번째 테이블의 행을 하나씩 읽고, 두 번째 테이블의 인덱스를 사용하여 빠르게 매칭.


4) Hash join 

MySQL 8.0 이상에서 INNER JOIN 또는 LEFT JOIN을 수행할 때 해시 조인(Hash Join)이 자동으로 선택될 수 있음.

두 테이블 모두 FULL SCAN(ALL) 중이며, 조인 키에 인덱스가 없을 경우 해시 조인을 선택함.

작은 테이블(사원) 데이터를 메모리에 로드한 뒤, 큰 테이블(급여)의 데이터를 검사하면서 해시 테이블을 사용하여 빠르게 매칭.




 MySQL의 Hash Join 동작 방식
🔹 (1) MySQL 기본 조인 방식: Nested Loop Join
MySQL은 기본적으로 Nested Loop Join을 사용하여 조인을 수행.

하지만 두 테이블 모두 풀 스캔(ALL) 상태이면 성능이 저하될 가능성이 큼.

이럴 때 해시 조인(Hash Join)이 대안으로 선택됨.

🔹 (2) MySQL Hash Join 작동 방식
**사원 테이블(작은 테이블)**을 메모리에 로드하고, 해시 테이블을 생성.

급여 테이블(큰 테이블)을 순회하면서 해시 테이블을 검색하여 매칭되는 데이터를 찾음.

메모리를 사용하지만 큰 데이터셋을 조인할 때 성능이 개선될 가능성이 있음.



##############  두개의 join 방식 성능 테스트 ################


SELECT E.ENAME, D.DNAME
FROM EMP E
JOIN DEPT D ON D.DEPTNO = E.DEPTNO;

-- 더 빠름 
SELECT E.ENAME, D.DNAME
FROM DEPT D
JOIN EMP E ON D.DEPTNO = E.DEPTNO;

###########
실행계획 
###########



1) 옵티마이저를 이용한 해쉬조인 
SET optimizer_switch = 'hash_join=on';

EXPLAIN FORMAT=TRADITIONAL
SELECT *
FROM big_table1 A
JOIN big_table2 B ON A.id = B.id;

2) 힌트를 이용한 해쉬조인 
SELECT /*+ HASH_JOIN(B) */ *
FROM A
JOIN B ON A.id = B.id;

-- join 튜닝 연습 쿼리 

-- =========================
-- 실습: MySQL 조인 전략 비교
-- =========================


create database mydb2 default character set utf8 collate utf8_general_ci;
use mydb2; 

-- 1. 테이블 생성

DROP TABLE IF EXISTS emp;
DROP TABLE IF EXISTS dept;

CREATE TABLE dept (
  deptno INT PRIMARY KEY,
  dname VARCHAR(50)
);

CREATE TABLE emp (
  empno INT PRIMARY KEY,
  ename VARCHAR(50),
  deptno INT
);

-- 2. 데이터 삽입
INSERT INTO dept VALUES
(10, 'ACCOUNTING'), (20, 'RESEARCH'),
(30, 'SALES'), (40, 'OPERATIONS'), (50, 'IT');


-- 0~10까지 생성하기 
      SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
      UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
      UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9

INSERT INTO emp
SELECT
  empno,
  CONCAT('EMP', empno),
  FLOOR(1 + (RAND() * 5)) * 10  -- 부서 랜덤
FROM (
  SELECT @row := @row + 1 AS empno
  FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
       (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
         (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c,
         (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d,
        (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e,
       (SELECT @row := 0) r
) AS tmp;

select count(*) from emp;

select * from emp limit 30;



-- 3. Nested Loop Join 확인
EXPLAIN FORMAT=TRADITIONAL
SELECT *
FROM dept d
JOIN emp e ON d.deptno = e.deptno;

+----+-------------+-------+------------+--------+---------------+---------+---------+----------------+--------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref            | rows   | filtered | Extra       |
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------+--------+----------+-------------+
|  1 | SIMPLE      | e     | NULL       | ALL    | NULL          | NULL    | NULL    | NULL           | 100104 |   100.00 | Using where |
|  1 | SIMPLE      | d     | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | mydb2.e.deptno |      1 |   100.00 | NULL        |
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------+--------+----------+-------------+

-- 4. Hash Join 활성화 및 실행 (MySQL 8.0.18+)
SET optimizer_switch = 'hash_join=on';

EXPLAIN FORMAT=TRADITIONAL
SELECT /*+ HASH_JOIN(e) */ *
FROM dept d
JOIN emp e ON d.deptno = e.deptno;
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------+--------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref            | rows   | filtered | Extra       |
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------+--------+----------+-------------+
|  1 | SIMPLE      | e     | NULL       | ALL    | NULL          | NULL    | NULL    | NULL           | 100104 |   100.00 | Using where |
|  1 | SIMPLE      | d     | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | mydb2.e.deptno |      1 |   100.00 | NULL        |
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------+--------+----------+-------------+
2 rows in set, 1 warning (0.002 sec)


##################################
실행계획(EXPLAIN) 상 차이가 없는 이유
##################################
1. MySQL 옵티마이저의 "Hint 무시" 또는 "해시 조인 조건 불충족"
/*+ HASH_JOIN() */ 힌트를 써도 옵티마이저가 무시할 수 있음음.
optimizer_switch='hash_join=on' 을 켜도 조건이 맞지 않으면 사용 안 함

JOIN 조건이 =` (equi-join) 가 아니거나,
OUTER JOIN, ON 절 없이 USING 등 비표준 구문일 때

EXPLAIN FORMAT=TRADITIONAL 은 “Hash Join” 이라는 표현을 직접적으로 보여주지 않기도 해요.
MySQL 8.0.19+ 이상에서는 EXPLAIN FORMAT=JSON 또는 EXPLAIN ANALYZE 를 써야 내부 전략까지 볼 수 있습니다.

EXPLAIN FORMAT=JSON
SELECT *
FROM dept d
JOIN emp e ON d.deptno = e.deptno;

EXPLAIN FORMAT=JSON
SELECT /*+ HASH_JOIN(e) */ *
FROM dept d
JOIN emp e ON d.deptno = e.deptno;

EXPLAIN ANALYZE
SELECT *
FROM dept d
JOIN emp e ON d.deptno = e.deptno;

| -> Nested loop inner join  (cost=13598 rows=125130) (actual time=1.96..393 rows=100000 loops=1)
    -> Table scan on d  (cost=0.75 rows=5) (actual time=0.0783..0.0988 rows=5 loops=1)
    -> Index lookup on e using idx_emp_deptno (deptno=d.deptno)  (cost=717 rows=25026) (actual time=3.23..76.9 rows=20000 loops=5)
 |

1. Nested loop inner join 전체 실행 시간
시작 시각: 1.96ms
종료 시각: 393ms
총 실행 시간 = 393 - 1.96 = 391.04ms

2. Table scan on d
실제로 1번만 실행되고,
0.0783 ~ 0.0988ms → 소요 시간 약 0.0205ms

3. Index lookup on e
5번 반복(loops=5)
각 loop마다 소요 시간: 76.9 - 3.23 = 73.67ms

전체 반복 시간: 5 × 73.67 = 약 368.35ms

항목	소요 시간
dept 테이블 Full Scan	약 0.02ms
emp  테이블 Index Lookup (5회)	약 368.35ms
전체 조인 소요 시간	약 391.04ms

EXPLAIN  ANALYZE
SELECT /*+ HASH_JOIN(e) */ *
FROM dept d
JOIN emp e ON d.deptno = e.deptno;


#######중요 : 힌트를 준다고 해서 반드시 옵티마이저가 힌트를 따라 하지 않는다. hash join은 대용량 데이터의
경우에 유리하다. 힌트는 권유일뿐 반드시 따라하지는 않는다 



-- 함수만들기 
drop function if exists GetDept;
DELIMITER $$

CREATE FUNCTION GetDept(ideptno INT) 
RETURNS VARCHAR(20) 
DETERMINISTIC
BEGIN
    DECLARE vdname VARCHAR(20);
    
    -- 부서명을 조회하여 변수에 저장
    SELECT DNAME INTO vdname 
    FROM DEPT 
    WHERE DEPTNO = ideptno;
    
    -- 결과 반환
    RETURN vdname;
END $$
DELIMITER ;

select getdept(deptno), ename from emp;


-- 부서별 평균 급여 조회
SELECT DNAME, AVG(sal) AS AVG_sal
FROM EMP E
JOIN DEPT D ON E.DEPTNO = D.DEPTNO
GROUP BY DNAME;

-- 직책별 직원 수 조회
SELECT JOB, COUNT(*) AS EMP_COUNT
FROM EMP
GROUP BY JOB;














-- 두 테이블로부터 primary key를 삭제한 후 다시 확인해보자 
-- 데이터 양이 많을 경우 index 삭제나 생성시 시간이 많이 걸린다. 
alter table 사원 drop primary key;

EXPLAIN SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
FROM 사원, 급여
where 사원.사원번호 = 급여.사원번호;


MySQL [tuning]> EXPLAIN SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
    -> FROM 사원, 급여
    -> where 사원.사원번호 = 급여.사원번호;
+----+-------------+--------+------------+------+---------------+------+---------+------+---------+----------+--------------------------------------------+
| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows    | filtered | Extra                                      |
+----+-------------+--------+------------+------+---------------+------+---------+------+---------+----------+--------------------------------------------+
|  1 | SIMPLE      | 사원   | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  299088 |   100.00 | NULL                                       |
|  1 | SIMPLE      | 급여   | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 2836780 |    10.00 | Using where; Using join buffer (hash join) |
+----+-------------+--------+------------+------+---------------+------+---------+------+---------+----------+--------------------------------------------+
2 rows in set, 1 warning (0.003 sec)

filtered는 해당 테이블에서 WHERE 조건을 만족하는 예상 행 비율(%)을 나타냅니다.
즉, filtered 값이 높을수록 필터링된 데이터의 비율이 높다는 의미입니다.


-- 실제 실행시간 예측
EXPLAIN ANALYZE SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
FROM 사원, 급여
where 사원.사원번호 = 급여.사원번호;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN
                                                                                                                                                                   |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -> Inner hash join (`급여`.`사원번호` = `사원`.`사원번호`)  (cost=84.8e+9 rows=84.8e+9) (actual time=1170..8827 rows=2.84e+6 loops=1)
    -> Table scan on 급여  (cost=2.84 rows=2.84e+6) (actual time=9.05..4535 rows=2.84e+6 loops=1)
    -> Hash
        -> Table scan on 사원  (cost=30173 rows=299088) (actual time=0.076..491 rows=300024 loops=1)
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



MySQL이 Hash Join을 선택하는 조건
기본적으로 MySQL은 Nested Loop Join을 사용하지만, 다음과 같은 조건이 충족되면 Hash Join을 선택할 수 있습니다.

조인하는 두 테이블 중 적어도 하나가 FULL SCAN(ALL) 상태

인덱스가 없거나, 잘못된 인덱스를 사용 중이면 발생.

테이블 크기가 크고 조인 키에 대한 인덱스가 없음

WHERE A.col = B.col 조건에서 A.col 또는 B.col이 인덱스를 가지고 있지 않다면 MySQL이 해시 조인을 선택.

MySQL 8.0 이상에서 조인 버퍼(join_buffer_size)가 충분할 경우

MySQL은 기본적으로 조인 버퍼를 사용하여 해시 조인을 수행할 수 있음.

join_buffer_size가 충분하지 않으면 해시 조인이 비효율적일 수 있음.


############## 실제 실행시간 확인하기 ###############################
1) EXPLAIN ANALYZE 사용 (MySQL 8.0+)
MySQL 8.0.18부터 EXPLAIN ANALYZE를 사용하면 실제 실행 시간을 포함한 실행 계획을 확인할 수 있습니다.

EXPLAIN ANALYZE 
SELECT * FROM 사원 WHERE 사원번호 = 1001;

2) SQL 실행 후 SHOW PROFILE 사용 (MySQL 5.7, 8.0)-- 이전버전
MySQL 5.7과 8.0에서는 SHOW PROFILE을 사용하여 실행 시간을 확인할 수 있습니다.

SET profiling = 1; -- 프로파일링 활성화

SELECT * FROM 사원 WHERE 사원번호 = 1001; -- 실행할 쿼리

SHOW PROFILES; -- 실행된 쿼리 목록 확인
SHOW PROFILE FOR QUERY 1; -- 특정 쿼리의 실행 시간 확인

3) Performance Schema에서 실행 시간 확인 -- 현재버전 
MySQL 8.0에서는 performance_schema를 사용하여 실행 시간을 분석할 수 있습니다.

SELECT EVENT_ID, TIMER_START, TIMER_END, TIMER_WAIT
FROM performance_schema.events_statements_history_long
ORDER BY EVENT_ID DESC
LIMIT 1;
#############################################################

primary key를 추가한다 
alter table 사원 add primary key (사원번호);

외부키를 추가한다 
ALTER TABLE 자식테이블 
ADD CONSTRAINT 외래키이름 
FOREIGN KEY (자식컬럼) 
REFERENCES 부모테이블 (부모컬럼) 
ON DELETE CASCADE 
ON UPDATE CASCADE;

쿼리) 
EXPLAIN 
SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
FROM 사원, 급여
WHERE 사원.사원번호 = 10001
AND 사원.사원번호 = 급여.사원번호;

MySQL [tuning]> EXPLAIN
    -> SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
    -> FROM 사원, 급여
    -> WHERE 사원.사원번호 = 10001
    -> AND 사원.사원번호 = 급여.사원번호;
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+---------+----------+-------------+
| id | select_type | table  | partitions | type  | possible_keys | key     | key_len | ref   | rows    | filtered | Extra       |
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+---------+----------+-------------+
|  1 | SIMPLE      | 사원   | NULL       | const | PRIMARY       | PRIMARY | 4       | const |       1 |   100.00 | NULL        |
|  1 | SIMPLE      | 급여   | NULL       | ALL   | NULL          | NULL    | NULL    | NULL  | 2836780 |    10.00 | Using where |
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+---------+----------+-------------+
2 rows in set, 1 warning (0.005 sec)




외부키를 추가한다
alter table 급여 add constraint fk_사원번호  foreign key 급여(사원번호) REFERENCES 사원(사원번호);

EXPLAIN 
SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
FROM 사원, 급여
WHERE 사원.사원번호 = 10001
AND 사원.사원번호 = 급여.사원번호;

MySQL [tuning]> EXPLAIN
    -> SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
    -> FROM 사원, 급여
    -> WHERE 사원.사원번호 = 10001
    -> AND 사원.사원번호 = 급여.사원번호;
+----+-------------+--------+------------+-------+-----------------+-----------------+---------+-------+------+----------+-------+
| id | select_type | table  | partitions | type  | possible_keys   | key             | key_len | ref   | rows | filtered | Extra |
+----+-------------+--------+------------+-------+-----------------+-----------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | 사원   | NULL       | const | PRIMARY         | PRIMARY         | 4       | const |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | 급여   | NULL       | ref   | fk_사원번호      | fk_사원번호       | 4       | const |   17 |   100.00 | NULL  |
+----+-------------+--------+------------+-------+-----------------+-----------------+---------+-------+------+----------+-------+
2 rows in set, 1 warning (0.007 sec)




EXPLAIN 
SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
FROM 사원, 급여
WHERE 사원.사원번호 = 10001
AND 사원.사원번호 = 급여.사원번호;


+----+-------------+--------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table  | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | 사원   | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | 급여   | NULL       | ref   | PRIMARY       | PRIMARY | 4       | const |   17 |   100.00 | NULL  |
+----+-------------+--------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
2 rows in set, 1 warning (0.004 sec)

[사원]테이블의 [사원번호] 에도 primary key가 있고 [급여] 테이블의 [사원번호]에는 foreign key가 있다. 
ref필드의 const 가  foreign key를 참조하고 있음을 의미한다. 


#########  서브쿼리가 있을 경우에 

EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉,
       (SELECT MAX(부서번호) 
        FROM 부서사원_매핑 as 매핑 WHERE 매핑.사원번호 = 사원.사원번호) 카운트
FROM 사원 A, 급여 B
WHERE 사원.사원번호 = 10001
AND 사원.사원번호 = 급여.사원번호;


* 결과
+----+--------------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+------------------------------+
| id | select_type        | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra                        |
+----+--------------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+------------------------------+
|  1 | PRIMARY            | 사원  | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL                         |
|  1 | PRIMARY            | 급여  | NULL       | ref   | PRIMARY       | PRIMARY | 4       | const |   17 |   100.00 | NULL                         |
|  2 | DEPENDENT SUBQUERY | NULL  | NULL       | NULL  | NULL          | NULL    | NULL    | NULL  | NULL |     NULL | Select tables optimized away |
+----+--------------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+------------------------------+
3 rows in set, 2 warnings (0.01 sec)


join을 해도 subquery가 없으면 select_type가 simple가 나온다

EXPLAIN
SELECT A.사원번호, A.이름, A.성, B.연봉
FROM 사원 A
left outer join 급여 B on A.사원번호=B.사원번호
WHERE A.사원번호 = 10001;

+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | A     | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | B     | NULL       | ref   | PRIMARY       | PRIMARY | 4       | const |   17 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+


EXPLAIN
SELECT A.사원번호, A.이름, A.성, B.연봉,
       (SELECT MAX(부서번호) 
        FROM 부서사원_매핑 as C WHERE C.사원번호 = A.사원번호) 카운트
FROM 사원 A
left outer join 급여 B on A.사원번호=B.사원번호
WHERE A.사원번호 = 10001;


====================================================================================

* SQL
EXPLAIN 
SELECT * FROM 사원 WHERE 사원번호 = 100000;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
1 row in set (0.00 sec)

====================================================================================

* SQL
EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
FROM 사원,
     (SELECT 사원번호, 연봉
      FROM 급여
      WHERE 연봉 > 80000) AS 급여
WHERE 사원.사원번호 = 급여.사원번호
AND 사원.사원번호 BETWEEN 10001 AND 10010;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref                  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL                 |   10 |   100.00 | Using where |
|  1 | SIMPLE      | 급여  | NULL       | ref   | PRIMARY       | PRIMARY | 4       | tuning.사원.사원번호 |    9 |    33.33 | Using where |
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성,
       (SELECT MAX(부서번호) 
        FROM 부서사원_매핑 as 매핑 WHERE 매핑.사원번호 = 사원.사원번호) 카운트
FROM 사원
WHERE 사원.사원번호 = 100001;

* 결과
+----+--------------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+------------------------------+
| id | select_type        | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra                        |
+----+--------------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+------------------------------+
|  1 | PRIMARY            | 사원  | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL                         |
|  2 | DEPENDENT SUBQUERY | NULL  | NULL       | NULL  | NULL          | NULL    | NULL    | NULL  | NULL |     NULL | Select tables optimized away |
+----+--------------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+------------------------------+
2 rows in set, 2 warnings (0.00 sec)

====================================================================================
######  union 연산시 #############################################3
* SQL
EXPLAIN
SELECT 사원1.사원번호, 사원1.이름, 사원1.성
FROM 사원 as 사원1
WHERE 사원1.사원번호 = 100001
UNION ALL
SELECT 사원2.사원번호, 사원2.이름, 사원2.성
FROM 사원 as 사원2
WHERE 사원2.사원번호 = 100002;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | PRIMARY     | 사원1 | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
|  2 | UNION       | 사원2 | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================


EXPLAIN 
SELECT 사원1.사원번호, 사원1.이름, 사원1.성
FROM 사원 as 사원1
WHERE 사원1.사원번호 = 100001
UNION 
SELECT 사원2.사원번호, 사원2.이름, 사원2.성
FROM 사원 as 사원2
WHERE 사원2.사원번호 = 100002;


MySQL [tuning]> EXPLAIN
    -> SELECT 사원1.사원번호, 사원1.이름, 사원1.성
    -> FROM 사원 as 사원1
    -> WHERE 사원1.사원번호 = 100001
    -> UNION
    -> SELECT 사원2.사원번호, 사원2.이름, 사원2.성
    -> FROM 사원 as 사원2
    -> WHERE 사원2.사원번호 = 100002;
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+
| id | select_type  | table      | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra           |
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+
|  1 | PRIMARY      | 사원1      | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL            |
|  2 | UNION        | 사원2      | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL            |
|  3 | UNION RESULT | <union1,2> | NULL       | ALL   | NULL          | NULL    | NULL    | NULL  | NULL |     NULL | Using temporary |
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+


* SQL
EXPLAIN ANALYZE
SELECT 사원1.사원번호, 사원1.이름, 사원1.성
FROM 사원 as 사원1
WHERE 사원1.사원번호 = 100001
UNION ALL
SELECT 사원2.사원번호, 사원2.이름, 사원2.성
FROM 사원 as 사원2
WHERE 사원2.사원번호 = 100002;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | PRIMARY     | 사원1 | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
|  2 | UNION       | 사원2 | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================


EXPLAIN ANALYZE
SELECT 사원1.사원번호, 사원1.이름, 사원1.성
FROM 사원 as 사원1
WHERE 사원1.사원번호 = 100001
UNION 
SELECT 사원2.사원번호, 사원2.이름, 사원2.성
FROM 사원 as 사원2
WHERE 사원2.사원번호 = 100002;


MySQL [tuning]> EXPLAIN
    -> SELECT 사원1.사원번호, 사원1.이름, 사원1.성
    -> FROM 사원 as 사원1
    -> WHERE 사원1.사원번호 = 100001
    -> UNION
    -> SELECT 사원2.사원번호, 사원2.이름, 사원2.성
    -> FROM 사원 as 사원2
    -> WHERE 사원2.사원번호 = 100002;
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+
| id | select_type  | table      | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra           |
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+
|  1 | PRIMARY      | 사원1      | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL            |
|  2 | UNION        | 사원2      | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL            |
|  3 | UNION RESULT | <union1,2> | NULL       | ALL   | NULL          | NULL    | NULL    | NULL  | NULL |     NULL | Using temporary |
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+


######### 그룹함수 ############################
* SQL
EXPLAIN  
SELECT (SELECT COUNT(*)
        FROM 부서사원_매핑 as 매핑
        ) as 카운트,
       (SELECT MAX(연봉)
        FROM 급여
        ) as 급여;

* 결과
+----+-------------+-------+------------+-------+---------------+------------+---------+------+---------+----------+----------------+
| id | select_type | table | partitions | type  | possible_keys | key        | key_len | ref  | rows    | filtered | Extra          |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+---------+----------+----------------+
|  1 | PRIMARY     | NULL  | NULL       | NULL  | NULL          | NULL       | NULL    | NULL |    NULL |     NULL | No tables used |
|  3 | SUBQUERY    | 급여  | NULL       | ALL   | NULL           | NULL       | NULL    | NULL | 2838731 |   100.00 | NULL           |
|  2 | SUBQUERY    | 매핑  | NULL       | index | NULL           | I_부서번호 | 12      | NULL |  331143 |   100.00 | Using index    |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+---------+----------+----------------+
3 rows in set, 1 warning (0.00 sec)




##############  서브쿼리와 join과 함수의 차이 #############################

explain 
select A.사원번호, A.이름, C.부서명 
from 사원 A 
left outer join 부서사원_매핑 B  on A.사원번호=B.사원번호 
left outer join 부서 C on B.부서번호=C.부서번호;

+----+-------------+-------+------------+--------+---------------+---------+---------+----------------------+--------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref                  | rows   | filtered | Extra       |
+----+-------------+-------+------------+--------+---------------+---------+---------+-----------------------+--------+----------+-------------+
|  1 | SIMPLE      | A     | NULL       | ALL    | NULL          | NULL    | NULL    | NULL                 | 299423 |   100.00 | NULL        |
|  1 | SIMPLE      | B     | NULL       | ref    | PRIMARY       | PRIMARY | 4       | tuning.A.사원번호     |      1 |   100.00 | Using index |
|  1 | SIMPLE      | C     | NULL       | eq_ref | PRIMARY       | PRIMARY | 12      | tuning.B.부서번호     |      1 |   100.00 | NULL        |
+----+-------------+-------+------------+--------+---------------+---------+---------+-----------------------+--------+----------+-------------+


explain 
SELECT A.사원번호, A.이름,
       (
        SELECT C.부서명 
        FROM 부서 C 
        WHERE C.부서번호 = (SELECT B.부서번호 
                            FROM 부서사원_매핑 B 
                            WHERE B.사원번호 = A.사원번호
                            LIMIT 1)
       ) AS 부서명
FROM 사원 A; 

+----+--------------------+-------+------------+--------+---------------+---------+---------+-----------------------+--------+----------+-------------+
| id | select_type        | table | partitions | type   | possible_keys | key     | key_len | ref                   | rows   | filtered | Extra       |
+----+--------------------+-------+------------+--------+---------------+---------+---------+-----------------------+--------+----------+-------------+
|  1 | PRIMARY            | A     | NULL       | ALL    | NULL          | NULL    | NULL    | NULL                  | 299423 |   100.00 | NULL        |
|  2 | DEPENDENT SUBQUERY | C     | NULL       | eq_ref | PRIMARY       | PRIMARY | 12      | func                  |      1 |   100.00 | Using where |
|  3 | DEPENDENT SUBQUERY | B     | NULL       | ref    | PRIMARY       | PRIMARY | 4       | tuning.A.사원번호     |      1 |   100.00 | Using index |
+----+--------------------+-------+------------+--------+---------------+---------+---------+-----------------------+--------+----------+-------------+
3 rows in set, 2 warnings (0.010 sec)

explain analyze 
select A.사원번호, A.이름, C.부서명 
from 사원 A 
left outer join 부서사원_매핑 B  on A.사원번호=B.사원번호 
left outer join 부서 C on B.부서번호=C.부서번호;


-> Nested loop left join  (cost=728023 rows=331230) (actual time=15.8..4095 rows=331603 loops=1)
    -> Nested loop left join  (cost=363669 rows=331230) (actual time=3.67..2722 rows=331603 loops=1)
        -> Table scan on A  (cost=30999 rows=299423) (actual time=3.17..462 rows=300024 loops=1)
        -> Covering index lookup on B using PRIMARY (사원번호=a.`사원번호`)  (cost=1 rows=1.11) (actual time=0.00554..0.0071 rows=1.11 loops=300024)
    -> Single-row index lookup on C using PRIMARY (부서번호=b.`부서번호`)  (cost=1 rows=1) (actual time=0.0037..0.00375 rows=1 loops=331603)
 

actual time=0.00554..0.0071 rows=1.11 loops=300024
0.00554ms → 첫 번째 행을 찾는 데 걸린 시간
0.0071ms → 마지막 행까지 처리하는 데 걸린 총 시간
rows=1.11 → 평균적으로 1.11개의 행이 반환됨
loops=300024 → 이 연산이 300024번 반복 실행됨

즉, 이 작업은 평균적으로 0.0071ms 안에 완료되지만, 첫 번째 결과는 0.00554ms만에 반환된다는 의

주요 실행 시간 요소
각 단계별 실제 실행 시간 (actual time):

사원 테이블(A) 스캔:
actual time = 3.17..462 ms

즉, 전체 테이블을 읽는 데 462ms 소요됨.
부서사원_매핑(B) 인덱스 조회:

actual time = 0.00554..0.0071 ms

한 번의 조회당 0.0071ms가 걸림.
이 작업이 300024번 반복됨.

전체 시간 = 0.0071 ms × 300024 = 2130 ms

부서(C) 인덱스 조회:

actual time = 0.0037..0.00375 ms

한 번의 조회당 0.00375ms가 걸림.

이 작업이 331603번 반복됨.

전체 시간 = 0.00375 ms × 331603 = 1244 ms

최종 조인(Nested Loop Left Join):

actual time = 15.8..4095 ms

즉, 쿼리 전체 실행 시간은 4095ms(약 4초)

🔹3. 전체 실행 시간 계산
대략적인 전체 실행 시간은 다음과 같이 계산할 수 있음:

(사원 테이블 스캔 시간) 
+ (부서사원_매핑 조회 시간) 
+ (부서 조회 시간) 
= 462 ms + 2130 ms + 1244 ms 
= 약 3836 ms (3.8초)
'
'

explain analyze
SELECT A.사원번호, A.이름,
       (
        SELECT C.부서명 
        FROM 부서 C 
        WHERE C.부서번호 = (SELECT B.부서번호 
                            FROM 부서사원_매핑 B 
                            WHERE B.사원번호 = A.사원번호
                            LIMIT 1)
       ) AS 부서명
FROM 사원 A; 

| -> Table scan on A  (cost=30998 rows=299423) (actual time=0.442..282 rows=300024 loops=1)
-> Select #2 (subquery in projection; dependent)
    -> Filter: (c.`부서번호` = (select #3))  (cost=0.35 rows=1) (actual time=0.0347..0.0348 rows=1 loops=300024)
        -> Single-row index lookup on C using PRIMARY (부서번호=(select #3))  (cost=0.35 rows=1) (actual time=0.0246..0.0246 rows=1 loops=300024)
        -> Select #3 (subquery in condition; dependent)
            -> Limit: 1 row(s)  (cost=0.361 rows=1) (actual time=0.00709..0.00715 rows=1 loops=900072)
                -> Covering index lookup on B using PRIMARY (사원번호=a.`사원번호`)  (cost=0.361 rows=1.11) (actual time=0.00672..0.00672 rows=1 loops=900072)
                 |
+--

🔹1. 실행 계획 분석 (단계별)
🛠 실행 흐름
사원(A) 테이블을 Full Table Scan 수행

sql
복사
편집
-> Table scan on A  (cost=30998 rows=299423) (actual time=0.442..282 rows=300024 loops=1)
풀 스캔 발생 (actual time=0.442..282ms)

전체 300024개의 행을 읽음.

사원번호 컬럼에 인덱스가 있더라도, 이 단계에서 사용되지 않음.

각 사원번호(A.사원번호)에 대해 부서(B)를 조회하는 서브쿼리 실행

sql
복사
편집
-> Select #3 (subquery in condition; dependent)
     -> Limit: 1 row(s)  (cost=0.361 rows=1) (actual time=0.00709..0.00715 rows=1 loops=900072)
사원(A)의 각 행(300024개) 에 대해 서브쿼리가 실행됨 (총 900072번 수행됨)

즉, B 테이블을 900072번 조회하는 비효율적인 쿼리 발생

actual time=0.0071ms × 900072 loops ≈ 6.4초 추가됨

각 부서번호(B.부서번호)에 대해 부서(C) 조회 (Index Lookup)

sql
복사
편집
-> Single-row index lookup on C using PRIMARY (부서번호=(select #3)) 
   (cost=0.35 rows=1) (actual time=0.0246..0.0246 rows=1 loops=300024)
부서(B)에서 부서번호를 찾은 후, 부서(C)에서 1번의 Index Lookup 수행

이 과정도 300024번 반복됨

actual time=0.0246ms × 300024 loops ≈ 7.4초 추가됨

🔹2. 실행 시간 총합 계산
단계	수행 횟수	실행 시간 (1회)	예상 전체 시간
사원(A) 테이블 스캔	1회	282ms	282ms
서브쿼리 실행 (B 조회)	900072회	0.0071ms	6.4초
부서(C) 조회 (Index Lookup)	300024회	0.0246ms	7.4초
최종 예상 총 실행 시간			약 14초

특히나 mysql에서는 서브쿼리에 대한 자동 캐싱이 지원되지 않아서 join을 우선적으로 고려해야 한다. 



mysql은 서브쿼리가 자동 캐싱되지 않는다. 가급적 join으로 해결하는것이 바람직하다 
서브쿼리를 매번 실행하는 대신 임시 테이블을 활용하면 성능이 향상됨
WITH (Common Table Expressions, CTE) 활용 (MySQL 8.0 이상)
MySQL 8.0부터 지원되는 **CTE(Common Table Expression, WITH문)**를 사용하면 서브쿼리 결과를 재사용할 수 있음.

WITH temp_salary AS (
    SELECT 사원번호, 연봉 FROM 급여
)
SELECT 사원.사원번호, temp_salary.연봉
FROM 사원
JOIN temp_salary ON 사원.사원번호 = temp_salary.사원번호;


explain 
WITH 부서정보 AS (
    SELECT B.사원번호, C.부서명
    FROM 부서사원_매핑 B
    JOIN 부서 C ON B.부서번호 = C.부서번호
)
SELECT A.사원번호, A.이름, 부서정보.부서명
FROM 사원 A
LEFT JOIN 부서정보 ON A.사원번호 = 부서정보.사원번호;

+----+-------------+-------+------------+--------+------------------------+---------+---------+-----------------------+--------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys          | key     | key_len | ref                   | rows   | filtered | Extra       |
+----+-------------+-------+------------+--------+------------------------+---------+---------+-----------------------+--------+----------+-------------+
|  1 | SIMPLE      | A     | NULL       | ALL    | NULL                   | NULL    | NULL    | NULL                  | 299423 |   100.00 | NULL        |
|  1 | SIMPLE      | B     | NULL       | ref    | PRIMARY,I_부서번호     | PRIMARY | 4       | tuning.A.사원번호     |      1 |   100.00 | Using index |
|  1 | SIMPLE      | C     | NULL       | eq_ref | PRIMARY                | PRIMARY | 12      | tuning.B.부서번호     |      1 |   100.00 | NULL        |
+----+-------------+-------+------------+--------+------------------------+---------+---------+-----------------------+--------+----------+-------------+


########################
함수만들기 
########################
DELIMITER //

CREATE FUNCTION 함수이름(매개변수 데이터타입) 
RETURNS 반환타입
DETERMINISTIC
BEGIN
    -- 함수 로직
    RETURN 값;
END //

DELIMITER ;

DELIMITER // → 기본적으로 MySQL은 ;를 명령어 구분자로 사용하기 때문에, 이를 //로 변경하여 여러 줄의 SQL을 작성할 수 있도록 함.
RETURNS 반환타입 -> 함수가 반환할 데이터 타입을 지정 (INT, VARCHAR, DECIMAL 등).
DETERMINISTIC -> 같은 입력이면 항상 같은 결과를 반환하는 함수임을 의미함.
              -> 오직 쿼리 최적화 과정에서 "안전한 함수"로 인식될 뿐, 실행 속도를 개선하는 캐싱 기능이 기본적으로 제공되지는 않음.
RETURN 값; -> 최종 결과를 반환.


select * from 사원 limit 10;

select * from 부서사원_매핑 where 사원번호 = 100001; 

MySQL [tuning]>  select distinct 부서번호 from 부서;
+--------------+
| 부서번호     |
+--------------+
| d001         |
| d002         |
| d003         |
| d004         |
| d005         |
| d006         |
| d007         |
| d008         |
| d009         |
+--------------+
9 rows in set (0.003 sec)

select 부서명 from 부서 where 부서번호='d001';


DELIMITER //
DROP FUNCTION IF EXISTS GetBusuname;
CREATE FUNCTION GetBusuname(sawon INT)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
    DECLARE department VARCHAR(255);
    DECLARE department_name VARCHAR(255);

    -- 사원의 부서번호 조회
    SELECT 부서번호 INTO department 
    FROM 부서사원_매핑 
    WHERE 사원번호 = sawon 
    LIMIT 1;

    -- 부서번호를 이용해 부서명 조회
    SELECT 부서명 INTO department_name 
    FROM 부서 
    WHERE 부서번호 = department 
    LIMIT 1;

    return department_name;
end//

DELIMITER ;

#실행해보기 
select GetBusuname(사원번호), 사원번호, 이름 from 사원 limit 10;
====================================================================================
explain 
select GetBusuname(사원번호), 사원번호, 이름 from 사원;
    -> select GetBusuname(사원번호), 사원번호, 이름 from 사원;
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------+
| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------+
|  1 | SIMPLE      | 사원   | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299423 |   100.00 | NULL  |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------+
1 row in set, 1 warning (0.002 sec)

explain analyze
select GetBusuname(사원번호), 사원번호, 이름 from 사원;
+------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                        |
+------------------------------------------------------------------------------------------------+
| -> Table scan on 사원  (cost=30998 rows=299423) (actual time=1.22..302 rows=300024 loops=1)
   
################ 실제 실행시간 체크하기 ##############
#실행계획만으로는 시간을 알 수 없다. ###################
###################################################

SET profiling = 1; -- 실행시간 체크 활성화 
select GetBusuname(사원번호), 사원번호, 이름 from  사원 limit 1000;  -- 오래걸림 

SHOW PROFILES;

select A.사원번호, A.이름, C.부서명 
from 사원 A 
left outer join 부서사원_매핑 B  on A.사원번호=B.사원번호 
left outer join 부서 C on B.부서번호=C.부서번호
limit 1000;

SHOW PROFILES;
SHOW PROFILE FOR QUERY 아이디;

################################################
가급적 join으로 해결하라 
join => sub query => function 순임 
#################################################


#################################
인덱스가 무력화 되는경우 
#################################
1. 값의 분포도가 고르지 않을 경우에 
select distinct 성별 from 사원;

create index idx_성별 on 사원(성별);
show index from 사원;
+--------+------------+----------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table  | Non_unique | Key_name       | Seq_in_index | Column_name  | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+--------+------------+----------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원   |          0 | PRIMARY        |            1 | 사원번호     | A         |      299423 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원   |          1 | I_입사일자     |            1 | 입사일자     | A         |        4689 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원   |          1 | idx_성별       |            1 | 성별         | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+--------+------------+----------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+

explain select * from 사원  where 성별='M';
+----+-------------+--------+------------+------+---------------+------------+---------+-------+--------+----------+-------+
| id | select_type | table  | partitions | type | possible_keys | key        | key_len | ref   | rows   | filtered | Extra |
+----+-------------+--------+------------+------+---------------+------------+---------+-------+--------+----------+-------+
|  1 | SIMPLE      | 사원   | NULL       | ref  | idx_성별       | idx_성별    | 1       | const | 149711 |   100.00 | NULL  |
+----+-------------+--------+------------+------+---------------+------------+---------+-------+--------+----------+-------+

explain SELECT * FROM 사원 IGNORE INDEX (idx_성별) WHERE 성별 = 'M';
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원   | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299423 |    50.00 | Using where |
+----+-------------+--------+------------+------+---------------+------+---------+------+--------+----------+-------------+

explain analyze select * from 사원  where 성별='M';  -- 684 
explain analyze SELECT * FROM 사원 IGNORE INDEX (idx_성별) WHERE 성별 = 'M';


테이블 풀 검색 vs 인덱스 사용
테이블 풀 검색 (Full Table Scan)

모든 행을 읽음: MySQL은 인덱스 없이 테이블의 모든 행을 읽어서 조건에 맞는 데이터만 필터링합니다.

느린 성능: 테이블의 크기가 커질수록 검색 시간이 선형적으로 증가합니다. 예를 들어, 1백만 개의 행이 있다면 1백만 번의 검색을 해야 합니다.

적합한 경우: 테이블이 작을 때나, 쿼리가 일부 조건에만 해당하는 데이터를 모두 읽어야 할 때 사용될 수 있습니다.

인덱스를 사용할 때

빠른 검색: 인덱스는 데이터에 빠르게 접근할 수 있도록 돕습니다. 인덱스는 데이터가 정렬된 형태로 저장되므로, 원하는 데이터를 이진 탐색을 통해 빠르게 찾을 수 있습니다.

검색 효율성: 인덱스를 사용하면 검색 속도가 매우 빠름. 특히 조건이 인덱스를 활용할 수 있다면, 불필요한 데이터를 스캔하지 않고 바로 원하는 데이터를 찾을 수 있습니다.

적합한 경우: 검색할 데이터가 많고, 조건이 인덱스에 맞는 경우 (예: WHERE, JOIN, ORDER BY, GROUP BY 조건에 인덱스를 사용 가능할 때).

왜 인덱스가 빠른가요?
인덱스는 이진 탐색 또는 트리 구조를 사용하여 데이터를 빠르게 찾을 수 있도록 설계되어 있습니다. 예를 들어, B-트리(Balanced Tree)나 해시 테이블을 사용하는 인덱스는 검색 성능이 매우 효율적입니다.

디스크 I/O 최적화: 인덱스를 사용하면 전체 테이블을 스캔할 필요 없이, 인덱스를 통해 관련된 데이터 페이지만 읽을 수 있어 I/O 작업이 줄어듭니다.

부분 검색 가능: 인덱스는 데이터가 정렬되어 있기 때문에 범위 검색이나 특정 조건에 맞는 데이터를 빠르게 찾을 수 있습니다.

* SQL
EXPLAIN
SELECT 사원.사원번호, 급여.연봉
FROM 사원,
       (SELECT 사원번호, MAX(연봉) as 연봉
        FROM 급여
        WHERE 사원번호 BETWEEN 10001 AND 20000 ) as 급여
WHERE 사원.사원번호 = 급여.사원번호;

* 결과
+----+-------------+------------+------------+--------+---------------+---------+---------+-------+--------+----------+-------------+
| id | select_type | table      | partitions | type   | possible_keys | key     | key_len | ref   | rows   | filtered | Extra       |
+----+-------------+------------+------------+--------+---------------+---------+---------+-------+--------+----------+-------------+
|  1 | PRIMARY     | <derived2> | NULL       | system | NULL          | NULL    | NULL    | NULL  |      1 |   100.00 | NULL        |
|  1 | PRIMARY     | 사원       | NULL       | const  | PRIMARY       | PRIMARY | 4       | const |      1 |   100.00 | Using index |
|  2 | DERIVED     | 급여       | NULL       | range  | PRIMARY       | PRIMARY | 4       | NULL  | 184756 |   100.00 | Using where |
+----+-------------+------------+------------+--------+---------------+---------+---------+-------+--------+----------+-------------+
3 rows in set, 1 warning (0.05 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 'M' as 성별, MAX(입사일자) as 입사일자
FROM 사원 as 사원1
WHERE 성별 = 'M'
UNION ALL
SELECT 'F' as 성별, MIN(입사일자) as 입사일자
FROM 사원 as 사원2
WHERE 성별 = 'F';

* 결과
+----+-------------+-------+------------+------+---------------+-----------+---------+-------+--------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key       | key_len | ref   | rows   | filtered | Extra |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------+--------+----------+-------+
|  1 | PRIMARY     | 사원1 | NULL       | ref  | I_성별_성     | I_성별_성 | 1       | const | 149578 |   100.00 | NULL  |
|  2 | UNION       | 사원2 | NULL       | ref  | I_성별_성     | I_성별_성 | 1       | const | 149578 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------+--------+----------+-------+
2 rows in set, 1 warning (0.01 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원_통합.* 
FROM ( 
      SELECT MAX(입사일자) as 입사일자
      FROM 사원 as 사원1
      WHERE 성별 = 'M' 
      
	  UNION 

      SELECT MIN(입사일자) as 입사일자
      FROM 사원 as 사원2
      WHERE 성별 = 'M' 
    ) as 사원_통합; 

* 결과
+------+--------------+------------+------------+------+---------------+-----------+---------+-------+--------+----------+-----------------+
| id   | select_type  | table      | partitions | type | possible_keys | key       | key_len | ref   | rows   | filtered | Extra           |
+------+--------------+------------+------------+------+---------------+-----------+---------+-------+--------+----------+-----------------+
|  1   | PRIMARY      | <derived2> | NULL       | ALL  | NULL          | NULL      | NULL    | NULL  |      2 |   100.00 | NULL            |
|  2   | DERIVED      | 사원1      | NULL       | ref  | I_성별_성     | I_성별_성 | 1       | const | 149578 |   100.00 | NULL            |
|  3   | UNION        | 사원2      | NULL       | ref  | I_성별_성     | I_성별_성 | 1       | const | 149578 |   100.00 | NULL            |
| NULL | UNION RESULT | <union2,3> | NULL       | ALL  | NULL          | NULL      | NULL    | NULL  |   NULL |     NULL | Using temporary |
+------+--------------+------------+------------+------+---------------+-----------+---------+-------+--------+----------+-----------------+
4 rows in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 관리자.부서번호,
       ( SELECT 사원1.이름
         FROM 사원 AS 사원1
         WHERE 성별= 'F'
         AND 사원1.사원번호 = 관리자.사원번호

         UNION ALL
 
         SELECT 사원2.이름
         FROM 사원 AS 사원2
         WHERE 성별= 'M'
         AND 사원2.사원번호 = 관리자.사원번호
       ) AS 이름
FROM 부서관리자 AS 관리자;

* 결과
+----+--------------------+--------+------------+--------+-------------------+------------+---------+------------------------+------+----------+-------------+
| id | select_type        | table  | partitions | type   | possible_keys     | key        | key_len | ref                    | rows | filtered | Extra       |
+----+--------------------+--------+------------+--------+-------------------+------------+---------+------------------------+------+----------+-------------+
|  1 | PRIMARY            | 관리자 | NULL       | index  | NULL              | I_부서번호 | 12      | NULL                   |   24 |   100.00 | Using index |
|  2 | DEPENDENT SUBQUERY | 사원1  | NULL       | eq_ref | PRIMARY,I_성별_성 | PRIMARY    | 4       | tuning.관리자.사원번호 |    1 |    50.00 | Using where |
|  3 | DEPENDENT UNION    | 사원2  | NULL       | eq_ref | PRIMARY,I_성별_성 | PRIMARY    | 4       | tuning.관리자.사원번호 |    1 |    50.00 | Using where |
+----+--------------------+--------+------------+--------+-------------------+------------+---------+------------------------+------+----------+-------------+
3 rows in set, 3 warnings (0.01 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 관리자.부서번호,
       ( SELECT 사원1.이름
         FROM 사원 AS 사원1
         WHERE 성별= 'F'
         AND 사원1.사원번호 = 관리자.사원번호

         UNION ALL

         SELECT 사원2.이름
         FROM 사원 AS 사원2
         WHERE 성별= 'M'
         AND 사원2.사원번호 = 관리자.사원번호
       ) AS 이름
FROM 부서관리자 AS 관리자;

* 결과
+----+--------------------+--------+------------+--------+-------------------+------------+---------+------------------------+------+----------+-------------+
| id | select_type        | table  | partitions | type   | possible_keys     | key        | key_len | ref                    | rows | filtered | Extra       |
+----+--------------------+--------+------------+--------+-------------------+------------+---------+------------------------+------+----------+-------------+
|  1 | PRIMARY            | 관리자 | NULL       | index  | NULL              | I_부서번호 | 12      | NULL                   |   24 |   100.00 | Using index |
|  2 | DEPENDENT SUBQUERY | 사원1  | NULL       | eq_ref | PRIMARY,I_성별_성 | PRIMARY    | 4       | tuning.관리자.사원번호 |    1 |    50.00 | Using where |
|  3 | DEPENDENT UNION    | 사원2  | NULL       | eq_ref | PRIMARY,I_성별_성 | PRIMARY    | 4       | tuning.관리자.사원번호 |    1 |    50.00 | Using where |
+----+--------------------+--------+------------+--------+-------------------+------------+---------+------------------------+------+----------+-------------+
3 rows in set, 3 warnings (0.00 sec)

====================================================================================
* SQL
SELECT *
FROM 사원
WHERE 사원번호 = (SELECT ROUND(RAND()*1000000));

* 결과
출력값은 없거나, 매번 다른 값이 조회됨

====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 사원번호 = (SELECT ROUND(RAND()*1000000));

* 결과
+----+----------------------+-------+------------+------+---------------+------+---------+------+--------+----------+----------------+
| id | select_type          | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra          |
+----+----------------------+-------+------------+------+---------------+------+---------+------+--------+----------+----------------+
|  1 | PRIMARY              | 사원  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299157 |   100.00 | Using where    |
|  2 | UNCACHEABLE SUBQUERY | NULL  | NULL       | NULL | NULL          | NULL | NULL    | NULL |   NULL |     NULL | No tables used |
+----+----------------------+-------+------------+------+---------------+------+---------+------+--------+----------+----------------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 사원번호 IN (SELECT 사원번호 FROM 급여 WHERE 시작일자>'2020-01-01' );

* 결과
+----+--------------+-------------+------------+--------+---------------------+---------------------+---------+----------------------+---------+----------+--------------------------+
| id | select_type  | table       | partitions | type   | possible_keys       |key                 | key_len | ref                  | rows    | filtered | Extra                    |
+----+--------------+-------------+------------+--------+---------------------+---------------------+---------+----------------------+---------+----------+--------------------------+
|  1 | SIMPLE       | 사원        | NULL       | ALL    | PRIMARY             |NULL                | NULL    | NULL                 |  299157 |   100.00 | Using where              |
|  1 | SIMPLE       | <subquery2> | NULL       | eq_ref | <auto_distinct_key> |<auto_distinct_key> | 4       | tuning.사원.사원번호 |       1 |   100.00 | NULL                     |
|  2 | MATERIALIZED | 급여        | NULL       | index  | PRIMARY             |I_사용여부          | 4       | NULL                 | 2838731 |    33.33 | Using where; Using index |
+----+--------------+-------------+------------+--------+---------------------+---------------------+---------+----------------------+---------+----------+--------------------------+
3 rows in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 급여.연봉
FROM 사원,
      (SELECT 사원번호, MAX(연봉) as 연봉
       FROM 급여
       WHERE 사원번호 BETWEEN 10001 AND 20000 ) as 급여
WHERE 사원.사원번호 = 급여.사원번호;

* 결과
+----+-------------+------------+------------+--------+---------------+---------+---------+-------+--------+----------+-------------+
| id | select_type | table      | partitions | type   | possible_keys | key     | key_len | ref   | rows   | filtered | Extra       |
+----+-------------+------------+------------+--------+---------------+---------+---------+-------+--------+----------+-------------+
|  1 | PRIMARY     | <derived2> | NULL       | system | NULL          | NULL    | NULL    | NULL  |      1 |   100.00 | NULL        |
|  1 | PRIMARY     | 사원       | NULL       | const  | PRIMARY       | PRIMARY | 4       | const |      1 |   100.00 | Using index |
|  2 | DERIVED     | 급여       | NULL       | range  | PRIMARY       | PRIMARY | 4       | NULL  | 184756 |   100.00 | Using where |
+----+-------------+------------+------------+--------+---------------+---------+---------+-------+--------+----------+-------------+
3 rows in set, 1 warning (0.03 sec)

====================================================================================
* SQL
CREATE TABLE myisam_테이블 (
사원번호 int NOT NULL,
생년월일birth_date date NOT NULL,
이름 varchar(14) NOT NULL,
성 varchar(16) NOT NULL,
성별 enum('M','F') NOT NULL,
입사일자 date NOT NULL,
PRIMARY KEY (사원번호)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

* 결과
Query OK, 0 rows affected, 1 warning (0.01 sec)

====================================================================================
* SQL
INSERT INTO myisam_테이블
VALUES (10001, '1953-09-02', 'Georgi', 'Facello', 'M', '1986-06-26');

* 결과
Query OK, 1 row affected (0.01 sec)

====================================================================================
* SQL
EXPLAIN
SELECT * FROM myisam_테이블;

* 결과
+----+-------------+---------------+------------+--------+---------------+------+---------+------+------+----------+-------+
| id | select_type | table         | partitions | type   | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
+----+-------------+---------------+------------+--------+---------------+------+---------+------+------+----------+-------+
|  1 | SIMPLE      | myisam_테이블 | NULL       | system | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL  |
+----+-------------+---------------+------------+--------+---------------+------+---------+------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 사원번호 = 10001;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 매핑.사원번호, 부서.부서번호, 부서.부서명
FROM 부서사원_매핑 as 매핑,
     부서
WHERE 매핑.부서번호 = 부서.부서번호
AND 매핑.사원번호 BETWEEN 100001 AND 100010;

* 결과
+----+-------------+-------+------------+--------+--------------------+---------+---------+----------------------+------+----------+--------------------------+
| id | select_type | table | partitions | type   | possible_keys      | key     | key_len | ref                  | rows | filtered | Extra                    |
+----+-------------+-------+------------+--------+--------------------+---------+---------+----------------------+------+----------+--------------------------+
|  1 | SIMPLE      | 매핑  | NULL       | range  | PRIMARY,I_부서번호 | PRIMARY | 4       | NULL                 |   12 |   100.00 | Using where; Using index |
|  1 | SIMPLE      | 부서  | NULL       | eq_ref | PRIMARY            | PRIMARY | 12      | tuning.매핑.부서번호 |    1 |   100.00 | NULL                     |
+----+-------------+-------+------------+--------+--------------------+---------+---------+----------------------+------+----------+--------------------------+
2 rows in set, 1 warning (0.01 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 직급.직급명
FROM 사원, 직급
WHERE 사원.사원번호 = 직급.사원번호
AND 사원.사원번호 BETWEEN 10001 AND 10100;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref                  | rows | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+--------------------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL                 |  100 |   100.00 | Using where; Using index |
|  1 | SIMPLE      | 직급  | NULL       | ref   | PRIMARY       | PRIMARY | 4       | tuning.사원.사원번호 |    1 |   100.00 | Using index              |
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+--------------------------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 입사일자 = '1985-11-21';

* 결과
+----+-------------+-------+------------+------+---------------+------------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key        | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | ref  | I_입사일자    | I_입사일자 | 3       | const |  119 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원출입기록
WHERE 출입문 IS NULL
OR 출입문 = 'A';

* 결과
+----+-------------+--------------+------------+-------------+---------------+----------+---------+-------+--------+----------+-----------------------+
| id | select_type | table        | partitions | type        | possible_keys | key      | key_len | ref   | rows   | filtered | Extra                 |
+----+-------------+--------------+------------+-------------+---------------+----------+---------+-------+--------+----------+-----------------------+
|  1 | SIMPLE      | 사원출입기록 | NULL       | ref_or_null | I_출입문      | I_출입문 | 4       | const | 329468 |   100.00 | Using index condition |
+----+-------------+--------------+------------+-------------+---------------+----------+---------+-------+--------+----------+-----------------------+
1 row in set, 1 warning (0.01 sec)

====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 10001 AND 100000;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 149578 |   100.00 | Using where |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.01 sec)

====================================================================================
* SQL
EXPLAIN
SELECT * 
FROM 사원 
WHERE 사원번호 BETWEEN 10001 AND 100000 
AND 입사일자 = '1985-11-21'; 

* 결과
+----+-------------+-------+------------+-------------+--------------------+--------------------+---------+------+------+----------+--------------------------------------------------+
| id | select_type | table | partitions | type        | possible_keys      | key                | key_len | ref  | rows | filtered | Extra                                            |
+----+-------------+-------+------------+-------------+--------------------+--------------------+---------+------+------+----------+--------------------------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | index_merge | PRIMARY,I_입사일자 | I_입사일자,PRIMARY | 7,4     | NULL |   15 |   100.00 | Using intersect(I_입사일자,PRIMARY); Using where |
+----+-------------+-------+------------+-------------+--------------------+--------------------+---------+------+------+----------+--------------------------------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원번호
FROM 직급
WHERE 직급명 = 'Manager';

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
|  1 | SIMPLE      | 직급  | NULL       | index | PRIMARY       | PRIMARY | 159     | NULL | 442961 |    10.00 | Using where; Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN 
SELECT * FROM 사원;

* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299157 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원번호
FROM 직급
WHERE 직급명 = 'Manager';

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
|  1 | SIMPLE      | 직급  | NULL       | index | PRIMARY       | PRIMARY | 159     | NULL | 442961 |    10.00 | Using where; Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT * FROM 사원;

* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299157 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
desc 직급;

* 결과
+----------+-------------+------+-----+---------+-------+
| Field    | Type        | Null | Key | Default | Extra |
+----------+-------------+------+-----+---------+-------+
| 사원번호 | int         | NO   | PRI | NULL    |       |
| 직급명   | varchar(50) | NO   | PRI | NULL    |       |
| 시작일자 | date        | NO   | PRI | NULL    |       |
| 종료일자 | date        | YES  |     | NULL    |       |
+----------+-------------+------+-----+---------+-------+
4 rows in set (0.01 sec)

====================================================================================
* SQL
show index from 직급;

* 결과
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 직급  |          0 | PRIMARY  |            1 | 사원번호    | A         |      301768 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 직급  |          0 | PRIMARY  |            2 | 직급명      | A         |      442605 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 직급  |          0 | PRIMARY  |            3 | 시작일자    | A         |      442961 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
3 rows in set (0.01 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 사원번호
FROM 직급
WHERE 직급명 = 'Manager';

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
|  1 | SIMPLE      | 직급  | NULL       | index | PRIMARY       | PRIMARY | 159     | NULL | 442961 |    10.00 | Using where; Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 직급.직급명
FROM 사원, 직급
WHERE 사원.사원번호 = 직급.사원번호
AND 사원.사원번호 BETWEEN 10001 AND 10100;

* 길이
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref                  | rows | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+--------------------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL                 |  100 |   100.00 | Using where; Using index |
|  1 | SIMPLE      | 직급  | NULL       | ref   | PRIMARY       | PRIMARY | 4       | tuning.사원.사원번호 |    1 |   100.00 | Using index              |
+----+-------------+-------+------------+-------+---------------+---------+---------+----------------------+------+----------+--------------------------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원번호
FROM 직급
WHERE 직급명 = 'Manager';

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
|  1 | SIMPLE      | 직급  | NULL       | index | PRIMARY       | PRIMARY | 159     | NULL | 442961 |    10.00 | Using where; Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+--------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
== 3.2.4 ===========================================================================
====================================================================================
* SQL
EXPLAIN FORMAT = TRADITIONAL
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+-------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 20080 |   100.00 | Using where |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+-------+----------+-------------+
1 row in set, 1 warning (0.01 sec)

====================================================================================
* SQL
EXPLAIN FORMAT = TREE
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000;

* 결과
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                                                       |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -> Filter: (`사원`.`사원번호` between 100001 and 200000)  (cost=4036.17 rows=20080)                                                                           |
|   -> Index range scan on 사원 using PRIMARY  (cost=4036.17 rows=20080)                                                                                        |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
====================================================================================
* SQL
EXPLAIN FORMAT = JSON
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000; 

====================================================================================
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN



                                                                                                                                   |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| {
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "4036.54"
    },
    "table": {
      "table_name": "사원",
      "access_type": "range",
      "possible_keys": [
        "PRIMARY"
      ],
      "key": "PRIMARY",
      "used_key_parts": [
        "사원번호"
      ],
      "key_length": "4",
      "rows_examined_per_scan": 20080,
      "rows_produced_per_join": 20080,
      "filtered": "100.00",
      "cost_info": {
        "read_cost": "2028.54",
        "eval_cost": "2008.00",
        "prefix_cost": "4036.54",
        "data_read_per_join": "1M"
      },
      "used_columns": [
        "사원번호",
        "생년월일",
        "이름",
        "성",
        "성별",
        "입사일자"
      ],
      "attached_condition": "(`tuning`.`사원`.`사원번호` between 100001 and 200000)"
    }
  }
} |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
EXPLAIN ANALYZE 
SELECT * 
FROM 사원 
WHERE 사원번호 BETWEEN 100001 AND 200000; 

* 결과
+-------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                             |
+-------------------------------------------------------------------------------------------------------------------------------------+
| -> Filter: (`사원`.`사원번호` between 100001 and 200000)  (cost=4036.54 rows=20080) (actual time=0.082..8.311 rows=10025 loops=1)
    -> Index range scan on 사원 using PRIMARY  (cost=4036.54 rows=20080) (actual time=0.079..7.389 rows=10025 loops=1)                |
+-------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)

==================================================================================== EXPLAIN PARTITIONS
* SQL
EXPLAIN PARTITIONS
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000;

* 결과
+------+-------------+-------+------------+-------+---------------+---------+---------+------+-------+-------------+
| id   | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows  | Extra       |
+------+-------------+-------+------------+-------+---------------+---------+---------+------+-------+-------------+
|    1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 18826 | Using where |
+------+-------------+-------+------------+-------+---------------+---------+---------+------+-------+-------------+
1 row in set (0.013 sec)

====================================================================================EXPLAIN EXTENDED
* SQL
EXPLAIN EXTENDED
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000;

* 결과
+------+-------------+-------+-------+---------------+---------+---------+------+-------+----------+-------------+
| id   | select_type | table | type  | possible_keys | key     | key_len | ref  | rows  | filtered | Extra       |
+------+-------------+-------+-------+---------------+---------+---------+------+-------+----------+-------------+
|    1 | SIMPLE      | 사원  | range | PRIMARY       | PRIMARY | 4       | NULL | 18826 |   100.00 | Using where |
+------+-------------+-------+-------+---------------+---------+---------+------+-------+----------+-------------+
1 row in set, 1 warning (0.000 sec)

==================================================================================== ANALYZE
* SQL
ANALYZE
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 100001 AND 200000;

* 결과
+------+-------------+-------+-------+---------------+---------+---------+------+-------+----------+----------+------------+-------------+
| id   | select_type | table | type  | possible_keys | key     | key_len | ref  | rows  | r_rows   | filtered | r_filtered | Extra       |
+------+-------------+-------+-------+---------------+---------+---------+------+-------+----------+----------+------------+-------------+
|    1 | SIMPLE      | 사원  | range | PRIMARY       | PRIMARY | 4       | NULL | 18826 | 10025.00 |   100.00 |     100.00 | Using where |
+------+-------------+-------+-------+---------------+---------+---------+------+-------+----------+----------+------------+-------------+
1 row in set (0.012 sec)

====================================================================================
== 3.3.1 ===========================================================================
====================================================================================
* SQL
show variables like 'profiling%';

* 결과
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| profiling              | OFF   |
| profiling_history_size | 15    |
+------------------------+-------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================
* SQL
set profiling = 'ON';
* 결과
Query OK, 0 rows affected (0.004 sec)

====================================================================================
* SQL
SELECT 사원번호
FROM 사원
WHERE 사원번호 = 100000;

* 결과
+----------+
| 사원번호 |
+----------+
|   100000 |
+----------+
1 row in set (0.00 sec)
====================================================================================
* SQL
show profiles;

* 결과
+----------+------------+---------------------------------------------------------+
| Query_ID | Duration   | Query	                                                  |
+----------+------------+---------------------------------------------------------+
|        1 | 0.00055779 | SELECT 사원번호 FROM 사원 WHERE 사원번호 = 100000       |
+----------+------------+---------------------------------------------------------+
1 rows in set (0.000 sec)

====================================================================================
* SQL
show profile for query 1;

* 결과
+------------------------+----------+
| Status                 | Duration |
+------------------------+----------+
| Starting               | 0.000116 |
| checking permissions   | 0.000009 |
| Opening tables         | 0.000039 |
| After opening tables   | 0.000008 |
| System lock            | 0.000008 |
| table lock             | 0.000022 |
| init                   | 0.000037 |
| Optimizing             | 0.000029 |
| Statistics             | 0.000096 |
| Preparing              | 0.000006 |
| Unlocking tables       | 0.000020 |
| Preparing              | 0.000024 |
| Executing              | 0.000006 |
| Sending data           | 0.000020 |
| End of update loop     | 0.000013 |
| Query end              | 0.000005 |
| Commit                 | 0.000006 |
| closing tables         | 0.000004 |
| Unlocking tables       | 0.000003 |
| closing tables         | 0.000008 |
| Starting cleanup       | 0.000003 |
| Freeing items          | 0.000007 |
| Updating status        | 0.000064 |
| Reset for next command | 0.000006 |
+------------------------+----------+
24 rows in set (0.005 sec)

====================================================================================
== 3.3.2 ===========================================================================
====================================================================================
* SQL
show profile all for query 1;

* 결과
+--------------------------------+----------+----------+------------+-------------------+---------------------+--------------+---------------+---------------+-------------------+-------------------+-------------------+-------+--------------------------------+----------------------+-------------+
| Status                         | Duration | CPU_user | CPU_system | Context_voluntary | Context_involuntary | Block_ops_in | Block_ops_out | Messages_sent | Messages_received | Page_faults_major | Page_faults_minor | Swaps | Source_function                | Source_file          | Source_line |
+--------------------------------+----------+----------+------------+-------------------+---------------------+--------------+---------------+---------------+-------------------+-------------------+-------------------+-------+--------------------------------+----------------------+-------------+
| starting                       | 0.000093 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | NULL                           | NULL                 |        NULL |
| Executing hook on transaction  | 0.000003 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | launch_hook_trans_begin        | rpl_handler.cc       |        1122 |
| starting                       | 0.000010 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | launch_hook_trans_begin        | rpl_handler.cc       |        1124 |
| checking permissions           | 0.000007 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | check_access                   | sql_authorization.cc |        2207 |
| Opening tables                 | 0.000052 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | open_tables                    | sql_base.cc          |        5605 |
| init                           | 0.000011 | 0.015625 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | Sql_cmd_dml::execute           | sql_select.cc        |         684 |
| System lock                    | 0.000025 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | mysql_lock_tables              | lock.cc              |         329 |
| optimizing                     | 0.000018 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | JOIN::optimize                 | sql_optimizer.cc     |         282 |
| statistics                     | 0.000118 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | JOIN::optimize                 | sql_optimizer.cc     |         504 |
| preparing                      | 0.000015 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | JOIN::optimize                 | sql_optimizer.cc     |         588 |
| executing                      | 0.000013 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | SELECT_LEX_UNIT::ExecuteIterat | sql_union.cc         |        1084 |
| end                            | 0.000003 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | Sql_cmd_dml::execute           | sql_select.cc        |         737 |
| query end                      | 0.000002 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | mysql_execute_command          | sql_parse.cc         |        4703 |
| waiting for handler commit     | 0.000009 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | ha_commit_trans                | handler.cc           |        1589 |
| closing tables                 | 0.000008 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | mysql_execute_command          | sql_parse.cc         |        4754 |
| freeing items                  | 0.000064 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | mysql_parse                    | sql_parse.cc         |        5435 |
| cleaning up                    | 0.000018 | 0.000000 |   0.000000 |              NULL |                NULL |         NULL |          NULL |          NULL |              NULL |              NULL |              NULL |  NULL | dispatch_command               | sql_parse.cc         |        2217 |
+--------------------------------+----------+----------+------------+-------------------+---------------------+--------------+---------------+---------------+-------------------+-------------------+-------------------+-------+--------------------------------+----------------------+-------------+
17 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
show profile cpu for query 1;
* 결과
+--------------------------------+----------+----------+------------+
| Status                         | Duration | CPU_user | CPU_system |
+--------------------------------+----------+----------+------------+
| starting                       | 0.000093 | 0.000000 |   0.000000 |
| Executing hook on transaction  | 0.000003 | 0.000000 |   0.000000 |
| starting                       | 0.000010 | 0.000000 |   0.000000 |
| checking permissions           | 0.000007 | 0.000000 |   0.000000 |
| Opening tables                 | 0.000052 | 0.000000 |   0.000000 |
| init                           | 0.000011 | 0.015625 |   0.000000 |
| System lock                    | 0.000025 | 0.000000 |   0.000000 |
| optimizing                     | 0.000018 | 0.000000 |   0.000000 |
| statistics                     | 0.000118 | 0.000000 |   0.000000 |
| preparing                      | 0.000015 | 0.000000 |   0.000000 |
| executing                      | 0.000013 | 0.000000 |   0.000000 |
| end                            | 0.000003 | 0.000000 |   0.000000 |
| query end                      | 0.000002 | 0.000000 |   0.000000 |
| waiting for handler commit     | 0.000009 | 0.000000 |   0.000000 |
| closing tables                 | 0.000008 | 0.000000 |   0.000000 |
| freeing items                  | 0.000064 | 0.000000 |   0.000000 |
| cleaning up                    | 0.000018 | 0.000000 |   0.000000 |
+--------------------------------+----------+----------+------------+
17 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
show profile block io for query 1;

* 결과
+--------------------------------+----------+--------------+---------------+
| Status                         | Duration | Block_ops_in | Block_ops_out |
+--------------------------------+----------+--------------+---------------+
| starting                       | 0.000093 |         NULL |          NULL |
| Executing hook on transaction  | 0.000003 |         NULL |          NULL |
| starting                       | 0.000010 |         NULL |          NULL |
| checking permissions           | 0.000007 |         NULL |          NULL |
| Opening tables                 | 0.000052 |         NULL |          NULL |
| init                           | 0.000011 |         NULL |          NULL |
| System lock                    | 0.000025 |         NULL |          NULL |
| optimizing                     | 0.000018 |         NULL |          NULL |
| statistics                     | 0.000118 |         NULL |          NULL |
| preparing                      | 0.000015 |         NULL |          NULL |
| executing                      | 0.000013 |         NULL |          NULL |
| end                            | 0.000003 |         NULL |          NULL |
| query end                      | 0.000002 |         NULL |          NULL |
| waiting for handler commit     | 0.000009 |         NULL |          NULL |
| closing tables                 | 0.000008 |         NULL |          NULL |
| freeing items                  | 0.000064 |         NULL |          NULL |
| cleaning up                    | 0.000018 |         NULL |          NULL |
+--------------------------------+----------+--------------+---------------+
17 rows in set, 1 warning (0.00 sec)


====================================================================================
== 4.1.1 ===========================================================================
====================================================================================
* SQL
SELECT COUNT(1)
FROM 급여;

* 결과
+----------+
| COUNT(1) |
+----------+
|  2844047 |
+----------+
1 row in set (3.69 sec)

====================================================================================
* SQL
SELECT COUNT(1)
FROM 부서;

* 결과
+----------+
| COUNT(1) |
+----------+
|        9 |
+----------+
1 row in set (0.00 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 부서관리자;

* 결과
+----------+
| COUNT(1) |
+----------+
|       24 |
+----------+
1 row in set (0.01 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 부서사원_매핑;

* 결과
+----------+
| COUNT(1) |
+----------+
|   331603 |
+----------+
1 row in set (1.89 sec)

====================================================================================
* SQL
SELECT COUNT(1)
FROM 사원;

* 결과
+----------+
| COUNT(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.47 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 사원출입기록;

* 결과
+----------+
| COUNT(1) |
+----------+
|   660000 |
+----------+
1 row in set (1.78 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 직급;

* 결과
+----------+
| COUNT(1) |
+----------+
|   443308 |
+----------+
1 row in set (1.23 sec)
====================================================================================
* SQL
show index from 급여;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 급여  |          0 | PRIMARY    |            1 | 사원번호    | A         |      298323 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 급여  |          0 | PRIMARY    |            2 | 시작일자    | A         |     2838731 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 급여  |          1 | I_사용여부 |            1 | 사용여부    | A         |           1 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
3 rows in set (0.01 sec)
====================================================================================
* SQL
show index from 부서;

* 결과
+-------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name  | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 부서  |          0 | PRIMARY   |            1 | 부서번호    | A         |           9 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 부서  |          0 | UI_부서명 |            1 | 부서명      | A         |           9 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
2 rows in set (0.00 sec)
====================================================================================
* SQL
show index from 부서관리자;

* 결과
+------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table      | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 부서관리자 |          0 | PRIMARY    |            1 | 사원번호    | A         |          24 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 부서관리자 |          0 | PRIMARY    |            2 | 부서번호    | A         |          24 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 부서관리자 |          1 | I_부서번호 |            1 | 부서번호    | A         |           9 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
3 rows in set (0.00 sec)
====================================================================================
* SQL
show index from 부서사원_매핑;

* 결과
+---------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table         | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+---------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 부서사원_매핑 |          0 | PRIMARY    |            1 | 사원번호    | A         |      299417 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 부서사원_매핑 |          0 | PRIMARY    |            2 | 부서번호    | A         |      331143 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 부서사원_매핑 |          1 | I_부서번호 |            1 | 부서번호    | A         |           8 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+---------------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
3 rows in set (0.00 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
show index from 사원출입기록;

* 결과
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table        | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원출입기록 |          0 | PRIMARY  |            1 | 순번        | A         |      658935 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          0 | PRIMARY  |            2 | 사원번호    | A         |      658935 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_지역   |            1 | 지역        | A         |           4 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_시간   |            1 | 입출입시간  | A         |      652638 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_출입문 |            1 | 출입문      | A         |           3 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
5 rows in set (0.00 sec)
====================================================================================
* SQL
show index from 직급;

* 결과
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 직급  |          0 | PRIMARY  |            1 | 사원번호    | A         |      301768 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 직급  |          0 | PRIMARY  |            2 | 직급명      | A         |      442605 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 직급  |          0 | PRIMARY  |            3 | 시작일자    | A         |      442961 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
3 rows in set (0.00 sec)

====================================================================================
== 4.2.1 ===========================================================================
==================================================================================== 기본 키를 변형하는 나쁜 SQL 문
* SQL
SELECT *
FROM 사원
WHERE SUBSTRING(사원번호,1,4) = 1100
AND LENGTH(사원번호) = 5;

* 결과
+----------+------------+-------------+-------------+------+------------+
| 사원번호 | 생년월일   | 이름        | 성          | 성별 | 입사일자   |
+----------+------------+-------------+-------------+------+------------+
|    11000 | 1960-09-12 | Alain       | Bonifati    | M    | 1988-08-20 |
|    11001 | 1956-04-16 | Baziley     | Buchter     | F    | 1987-02-23 |
|    11002 | 1952-02-26 | Bluma       | Ulupinar    | M    | 1996-12-23 |
|    11003 | 1960-11-13 | Mariangiola | Gulla       | M    | 1987-05-24 |
|    11004 | 1954-08-05 | JoAnna      | Decleir     | F    | 1992-01-19 |
|    11005 | 1958-03-12 | Byong       | Douceur     | F    | 1986-07-27 |
|    11006 | 1962-12-26 | Christoper  | Butterworth | F    | 1989-08-02 |
|    11007 | 1962-03-16 | Olivera     | Maccarone   | M    | 1991-04-11 |
|    11008 | 1962-07-11 | Gennady     | Menhoudj    | M    | 1988-09-18 |
|    11009 | 1954-08-30 | Alper       | Axelband    | F    | 1986-09-09 |
+----------+------------+-------------+-------------+------+------------+
10 rows in set (0.21 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE SUBSTRING(사원번호,1,4) = 1100
AND LENGTH(사원번호) = 5;

* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299157 |   100.00 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
SELECT COUNT(1) FROM 사원;

* 결과
+----------+
| COUNT(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.37 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================

* SQL
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 11000 AND 11009;

* 결과
+----------+------------+-------------+-------------+------+------------+
| 사원번호 | 생년월일   | 이름        | 성          | 성별 | 입사일자   |
+----------+------------+-------------+-------------+------+------------+
|    11000 | 1960-09-12 | Alain       | Bonifati    | M    | 1988-08-20 |
|    11001 | 1956-04-16 | Baziley     | Buchter     | F    | 1987-02-23 |
|    11002 | 1952-02-26 | Bluma       | Ulupinar    | M    | 1996-12-23 |
|    11003 | 1960-11-13 | Mariangiola | Gulla       | M    | 1987-05-24 |
|    11004 | 1954-08-05 | JoAnna      | Decleir     | F    | 1992-01-19 |
|    11005 | 1958-03-12 | Byong       | Douceur     | F    | 1986-07-27 |
|    11006 | 1962-12-26 | Christoper  | Butterworth | F    | 1989-08-02 |
|    11007 | 1962-03-16 | Olivera     | Maccarone   | M    | 1991-04-11 |
|    11008 | 1962-07-11 | Gennady     | Menhoudj    | M    | 1988-09-18 |
|    11009 | 1954-08-30 | Alper       | Axelband    | F    | 1986-09-09 |
+----------+------------+-------------+-------------+------+------------+
10 rows in set (0.00 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 11000 AND 11009;

* 결과
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL |   10 |   100.00 | Using where |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
== 4.2.2. ==========================================================================
====================================================================================
* SQL
SELECT IFNULL(성별,'NO DATA') AS 성별, COUNT(1) 건수
FROM 사원
GROUP BY IFNULL(성별,'NO DATA');

* 결과
+------+--------+
| 성별 | 건수   |
+------+--------+
| M    | 179973 |
| F    | 120051 |
+------+--------+
2 rows in set (0.77 sec)


====================================================================================
* SQL
EXPLAIN
SELECT IFNULL(성별,'NO DATA') AS 성별, COUNT(1) 건수
FROM 사원
GROUP BY IFNULL(성별,'NO DATA');

* 결과
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+------------------------------+
| id | select_type | table | partitions | type  | possible_keys | key       | key_len | ref  | rows   | filtered | Extra                        |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | index | I_성별_성     | I_성별_성 | 51      | NULL | 299157 |   100.00 | Using index; Using temporary |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+------------------------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
desc 사원;

* 결과
+----------+---------------+------+-----+---------+-------+
| Field    | Type          | Null | Key | Default | Extra |
+----------+---------------+------+-----+---------+-------+
| 사원번호 | int           | NO   | PRI | NULL    |       |
| 생년월일 | date          | NO   |     | NULL    |       |
| 이름     | varchar(14)   | NO   |     | NULL    |       |
| 성       | varchar(16)   | NO   |     | NULL    |       |
| 성별     | enum('M','F') | NO   | MUL | NULL    |       |
| 입사일자 | date          | NO   | MUL | NULL    |       |
+----------+---------------+------+-----+---------+-------+
6 rows in set (0.01 sec)

====================================================================================
* SQL
SELECT 성별, COUNT(1) 건수
FROM 사원
GROUP BY 성별;

* 결과
+------+--------+
| 성별 | 건수   |
+------+--------+
| M    | 179973 |
| F    | 120051 |
+------+--------+
2 rows in set (0.10 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 성별, COUNT(1) 건수
FROM 사원
GROUP BY 성별;

* 결과
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key       | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | index | I_성별_성     | I_성별_성 | 51      | NULL | 299157 |   100.00 | Using index |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
== 4.2.3 ===========================================================================
====================================================================================
* SQL
SELECT COUNT(1)
FROM 급여
WHERE 사용여부 = 1;

* 결과
+----------+
| COUNT(1) |
+----------+
|    42842 |
+----------+
1 row in set (0.15 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(1)
FROM 급여
WHERE 사용여부 = 1;

* 결과
+----+-------------+-------+------------+-------+---------------+------------+---------+------+---------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key        | key_len | ref  | rows    | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+---------+----------+--------------------------+
|  1 | SIMPLE      | 급여  | NULL       | index | I_사용여부    | I_사용여부 | 4       | NULL | 2838731 |    10.00 | Using where; Using index |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+---------+----------+--------------------------+
1 row in set, 3 warnings (0.00 sec)
====================================================================================
* SQL
SELECT 사용여부, COUNT(1)
FROM 급여
GROUP BY 사용여부;

* 결과
+----------+----------+
| 사용여부 | COUNT(1) |
+----------+----------+
| 0        |  2801205 |
| 1        |    42842 |
+----------+----------+
2 rows in set (0.15 sec)

====================================================================================
* SQL
show index from 급여;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 급여  |          0 | PRIMARY    |            1 | 사원번호    | A         |      298323 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 급여  |          0 | PRIMARY    |            2 | 시작일자    | A         |     2838731 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 급여  |          1 | I_사용여부 |            1 | 사용여부    | A         |           1 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
3 rows in set (0.01 sec)
====================================================================================
* SQL
desc 급여;

* 결과
+----------+---------+------+-----+---------+-------+
| Field    | Type    | Null | Key | Default | Extra |
+----------+---------+------+-----+---------+-------+
| 사원번호 | int     | NO   | PRI | NULL    |       |
| 연봉     | int     | NO   |     | NULL    |       |
| 시작일자 | date    | NO   | PRI | NULL    |       |
| 종료일자 | date    | NO   |     | NULL    |       |
| 사용여부 | char(1) | YES  | MUL |         |       |
+----------+---------+------+-----+---------+-------+
5 rows in set (0.01 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 급여
WHERE 사용여부 = '1';

* 결과
+----------+
| COUNT(1) |
+----------+
|    42842 |
+----------+
1 row in set (0.01 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(1)
FROM 급여
WHERE 사용여부 = '1';

* 결과
+----+-------------+-------+------------+------+---------------+------------+---------+-------+-------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key        | key_len | ref   | rows  | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------------+---------+-------+-------+----------+-------------+
|  1 | SIMPLE      | 급여  | NULL       | ref  | I_사용여부    | I_사용여부 | 4       | const | 82824 |   100.00 | Using index |
+----+-------------+-------+------------+------+---------------+------------+---------+-------+-------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
== 4.2.4. ==========================================================================
====================================================================================
* SQL
SELECT *                                                      
FROM 사원                                                     
WHERE CONCAT(성별,' ',성) = 'M Radwan';

* 결과
+----------+------------+-------------+--------+------+------------+
| 사원번호 | 생년월일   | 이름        | 성     | 성별 | 입사일자   |
+----------+------------+-------------+--------+------+------------+
|    10346 | 1963-01-29 | Aamod       | Radwan | M    | 1987-01-27 |
|    16491 | 1952-12-03 | Emdad       | Radwan | M    | 1988-05-28 |
|    18169 | 1954-09-21 | Nathalie    | Radwan | M    | 1998-03-04 |
... 중략 ...
|   485129 | 1963-03-23 | Jouni       | Radwan | M    | 1990-08-31 |
|   491504 | 1954-12-27 | Zeydy       | Radwan | M    | 1998-03-08 |
|   498822 | 1955-06-15 | Boutros     | Radwan | M    | 1989-06-13 |
+----------+------------+-------------+--------+------+------------+
102 rows in set (0.25 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE CONCAT(성별,' ',성) = 'M Radwan';

* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299157 |   100.00 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT CONCAT(성별,' ',성) '성별_성', COUNT(1)
FROM 사원
WHERE CONCAT(성별,' ',성) = 'M Radwan'

UNION ALL

SELECT '전체 데이터', COUNT(1)
FROM 사원;

* 결과
+-------------+----------+
| 성별_성     | COUNT(1) |
+-------------+----------+
| M Radwan    |      102 |
| 전체 데이터 |   300024 |
+-------------+----------+
2 rows in set (2.50 sec)


====================================================================================
* SQL
SELECT *
FROM 사원
WHERE 성별 = 'M'
AND 성 =  'Radwan';

* 결과
+----------+------------+-------------+--------+------+------------+
| 사원번호 | 생년월일   | 이름        | 성     | 성별 | 입사일자   |
+----------+------------+-------------+--------+------+------------+
|    10346 | 1963-01-29 | Aamod       | Radwan | M    | 1987-01-27 |
|    16491 | 1952-12-03 | Emdad       | Radwan | M    | 1988-05-28 |
|    18169 | 1954-09-21 | Nathalie    | Radwan | M    | 1998-03-04 |
... 중략 ...
|   485129 | 1963-03-23 | Jouni       | Radwan | M    | 1990-08-31 |
|   491504 | 1954-12-27 | Zeydy       | Radwan | M    | 1998-03-08 |
|   498822 | 1955-06-15 | Boutros     | Radwan | M    | 1989-06-13 |
+----------+------------+-------------+--------+------+------------+
102 rows in set (0.01 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 성별 = 'M'
AND 성 =  'Radwan';

* 결과
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key       | key_len | ref         | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | ref  | I_성별_성     | I_성별_성 | 51      | const,const |  102 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)


====================================================================================
== 4.2.5. ==========================================================================
====================================================================================
* SQL
SELECT DISTINCT 사원.사원번호, 이름, 성, 부서번호
FROM 사원
JOIN 부서관리자
ON (사원.사원번호 = 부서관리자. 사원번호);

* 결과
+----------+-------------+--------------+----------+
| 사원번호 | 이름        | 성           | 부서번호 |
+----------+-------------+--------------+----------+
|   110022 | Margareta   | Markovitch   | d001     |
|   110039 | Vishwani    | Minakawa     | d001     |
|   110085 | Ebru        | Alpin        | d002     |
|   110114 | Isamu       | Legleitner   | d002     |
|   110183 | Shirish     | Ossenbruggen | d003     |
|   110228 | Karsten     | Sigstam      | d003     |
|   110303 | Krassimir   | Wegerle      | d004     |
|   110344 | Rosine      | Cools        | d004     |
|   110386 | Shem        | Kieras       | d004     |
|   110420 | Oscar       | Ghazalie     | d004     |
|   110511 | DeForest    | Hagimont     | d005     |
|   110567 | Leon        | DasSarma     | d005     |
|   110725 | Peternela   | Onuegbe      | d006     |
|   110765 | Rutger      | Hofmeyr      | d006     |
|   110800 | Sanjoy      | Quadeer      | d006     |
|   110854 | Dung        | Pesch        | d006     |
|   111035 | Przemyslawa | Kaelbling    | d007     |
|   111133 | Hauke       | Zhang        | d007     |
|   111400 | Arie        | Staelin      | d008     |
|   111534 | Hilary      | Kambil       | d008     |
|   111692 | Tonny       | Butterworth  | d009     |
|   111784 | Marjo       | Giarratana   | d009     |
|   111877 | Xiaobin     | Spinelli     | d009     |
|   111939 | Yuchang     | Weedman      | d009     |
+----------+-------------+--------------+----------+
24 rows in set (0.00 sec)


====================================================================================
* SQL
EXPLAIN
SELECT DISTINCT 사원.사원번호, 이름, 성, 부서번호
FROM 사원
JOIN 부서관리자
ON (사원.사원번호 = 부서관리자. 사원번호);

* 결과
+----+-------------+------------+------------+--------+---------------+------------+---------+----------------------------+------+----------+------------------------------+
| id | select_type | table      | partitions | type   | possible_keys | key        | key_len | ref                        | rows | filtered | Extra                        |
+----+-------------+------------+------------+--------+---------------+------------+---------+----------------------------+------+----------+------------------------------+
|  1 | SIMPLE      | 부서관리자 | NULL       | index  | PRIMARY       | I_부서번호 | 12      | NULL                       |   24 |   100.00 | Using index; Using temporary |
|  1 | SIMPLE      | 사원       | NULL       | eq_ref | PRIMARY       | PRIMARY    | 4       | tuning.부서관리자.사원번호 |    1 |   100.00 | NULL                         |
+----+-------------+------------+------------+--------+---------------+------------+---------+----------------------------+------+----------+------------------------------+
2 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT 사원.사원번호, 이름, 성, 부서번호
FROM 사원
JOIN 부서관리자
ON (사원.사원번호 = 부서관리자. 사원번호);
+----------+-------------+--------------+----------+
| 사원번호 | 이름        | 성           | 부서번호 |
+----------+-------------+--------------+----------+
|   110022 | Margareta   | Markovitch   | d001     |
|   110039 | Vishwani    | Minakawa     | d001     |
|   110085 | Ebru        | Alpin        | d002     |
|   110114 | Isamu       | Legleitner   | d002     |
|   110183 | Shirish     | Ossenbruggen | d003     |
|   110228 | Karsten     | Sigstam      | d003     |
|   110303 | Krassimir   | Wegerle      | d004     |
|   110344 | Rosine      | Cools        | d004     |
|   110386 | Shem        | Kieras       | d004     |
|   110420 | Oscar       | Ghazalie     | d004     |
|   110511 | DeForest    | Hagimont     | d005     |
|   110567 | Leon        | DasSarma     | d005     |
|   110725 | Peternela   | Onuegbe      | d006     |
|   110765 | Rutger      | Hofmeyr      | d006     |
|   110800 | Sanjoy      | Quadeer      | d006     |
|   110854 | Dung        | Pesch        | d006     |
|   111035 | Przemyslawa | Kaelbling    | d007     |
|   111133 | Hauke       | Zhang        | d007     |
|   111400 | Arie        | Staelin      | d008     |
|   111534 | Hilary      | Kambil       | d008     |
|   111692 | Tonny       | Butterworth  | d009     |
|   111784 | Marjo       | Giarratana   | d009     |
|   111877 | Xiaobin     | Spinelli     | d009     |
|   111939 | Yuchang     | Weedman      | d009     |
+----------+-------------+--------------+----------+
24 rows in set (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 이름, 성, 부서번호
FROM 사원
JOIN 부서관리자
ON (사원.사원번호 = 부서관리자. 사원번호);

* 결과
+----+-------------+------------+------------+--------+---------------+------------+---------+----------------------------+------+----------+-------------+
| id | select_type | table      | partitions | type   | possible_keys | key        | key_len | ref                        | rows | filtered | Extra       |
+----+-------------+------------+------------+--------+---------------+------------+---------+----------------------------+------+----------+-------------+
|  1 | SIMPLE      | 부서관리자 | NULL       | index  | PRIMARY       | I_부서번호 | 12      | NULL                       |   24 |   100.00 | Using index |
|  1 | SIMPLE      | 사원       | NULL       | eq_ref | PRIMARY       | PRIMARY    | 4       | tuning.부서관리자.사원번호 |    1 |   100.00 | NULL        |
+----+-------------+------------+------------+--------+---------------+------------+---------+----------------------------+------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================
== 4.2.6. ==========================================================================
====================================================================================
* SQL
SELECT 'M' AS 성별, 사원번호
  FROM 사원 
 WHERE 성별 = 'M'
   AND 성 ='Baba'

 UNION

SELECT 'F', 사원번호
  FROM 사원
 WHERE 성별 = 'F'
   AND 성 = 'Baba';

* 결과
+------+----------+
| 성별 | 사원번호 |
+------+----------+
| M    |    11937 |
| M    |    12245 |
| M    |    15596 |
... 중략 ...
| F    |   496003 |
| F    |   498356 |
| F    |   499779 |
+------+----------+
226 rows in set (0.01 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 'M' AS 성별, 사원번호
  FROM 사원 
 WHERE 성별 = 'M'
   AND 성 ='Baba'

 UNION

SELECT 'F', 사원번호
  FROM 사원
 WHERE 성별 = 'F'
   AND 성 = 'Baba';
   
* 결과
+------+--------------+------------+------------+------+---------------+-----------+---------+-------------+------+----------+-----------------+
| id   | select_type  | table      | partitions | type | possible_keys | key       | key_len | ref         | rows | filtered | Extra           |
+------+--------------+------------+------------+------+---------------+-----------+---------+-------------+------+----------+-----------------+
|  1   | PRIMARY      | 사원       | NULL       | ref  | I_성별_성     | I_성별_성 | 51      | const,const |  135 |   100.00 | Using index     |
|  2   | UNION        | 사원       | NULL       | ref  | I_성별_성     | I_성별_성 | 51      | const,const |   91 |   100.00 | Using index     |
| NULL | UNION RESULT | <union1,2> | NULL       | ALL  | NULL          | NULL      | NULL    | NULL        | NULL |     NULL | Using temporary |
+------+--------------+------------+------------+------+---------------+-----------+---------+-------------+------+----------+-----------------+
3 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
SELECT 'M' as 성별, 사원번호
  FROM 사원 
 WHERE 성별 = 'M'
   AND 성 ='Baba'

 UNION ALL

SELECT 'F' as 성별, 사원번호
  FROM 사원
 WHERE 성별 = 'F'
   AND 성 ='Baba';

* 결과
+------+----------+
| 성별 | 사원번호 |
+------+----------+
| M    |    11937 |
| M    |    12245 |
| M    |    15596 |
... 중략 ...
| F    |   496003 |
| F    |   498356 |
| F    |   499779 |
+------+----------+
226 rows in set (0.00 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 'M' as 성별, 사원번호
  FROM 사원 
 WHERE 성별 = 'M'
   AND 성 ='Baba'

 UNION ALL

SELECT 'F' as 성별, 사원번호
  FROM 사원
 WHERE 성별 = 'F'
   AND 성 ='Baba';
   
* 결과
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key       | key_len | ref         | rows | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------------+
|  1 | PRIMARY     | 사원  | NULL       | ref  | I_성별_성     | I_성별_성 | 51      | const,const |  135 |   100.00 | Using index |
|  2 | UNION       | 사원  | NULL       | ref  | I_성별_성     | I_성별_성 | 51      | const,const |   91 |   100.00 | Using index |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)
====================================================================================
== 4.2.7. ==========================================================================
====================================================================================
* SQL
SELECT 성, 성별, COUNT(1) as 카운트
  FROM 사원
 GROUP BY 성, 성별;

* 결과
+------------------+------+--------+
| 성               | 성별 | 카운트 |
+------------------+------+--------+
| Aamodt           | M    |    120 |
| Acton            | M    |    108 |
| Adachi           | M    |    140 |
... 중략 ...
| Zwicker          | F    |     65 |
| Zyda             | F    |     72 |
| Zykh             | F    |     61 |
+------------------+------+--------+
3274 rows in set (0.43 sec)


====================================================================================
* SQL
EXPLAIN
SELECT 성, 성별, COUNT(1) as 카운트
FROM 사원
GROUP BY 성, 성별;

* 결과
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+------------------------------+
| id | select_type | table | partitions | type  | possible_keys | key       | key_len | ref  | rows   | filtered | Extra                        |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | index | I_성별_성     | I_성별_성 | 51      | NULL | 299157 |   100.00 | Using index; Using temporary |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+------------------------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
SELECT 성, 성별, COUNT(1) as 카운트
FROM 사원
GROUP BY 성별, 성;

* 결과
+------------------+------+--------+
| 성               | 성별 | 카운트 |
+------------------+------+--------+
| Aamodt           | M    |    120 |
| Acton            | M    |    108 |
| Adachi           | M    |    140 |
... 중략 ...
| Zwicker          | F    |     65 |
| Zyda             | F    |     72 |
| Zykh             | F    |     61 |
+------------------+------+--------+
3274 rows in set (0.04 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 성, 성별, COUNT(1) as 카운트
FROM 사원
GROUP BY 성별, 성;

* 결과
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key       | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | index | I_성별_성     | I_성별_성 | 51      | NULL | 299157 |   100.00 | Using index |
+----+-------------+-------+------------+-------+---------------+-----------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
== 4.2.8. ==========================================================================
====================================================================================
* SQL
SELECT 사원번호
FROM 사원
WHERE 입사일자 LIKE '1989%'
AND 사원번호 > 100000;

* 결과
+----------+
| 사원번호 |    
+----------+
|   100011 |
|   100028 |
|   100041 |
... 중략 ...
|   499974 |
|   499983 |
|   499991 |
+----------+
20001 rows in set (0.13 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원번호
FROM 사원
WHERE 입사일자 LIKE '1989%'
AND 사원번호 > 100000;

* 결과
+----+-------------+-------+------------+-------+--------------------+---------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys      | key     | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+-------+--------------------+---------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY,I_입사일자 | PRIMARY | 4       | NULL | 149578 |    11.11 | Using where |
+----+-------------+-------+------------+-------+--------------------+---------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
SELECT COUNT(1) FROM 사원;

* 결과
+----------+
| COUNT(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.58 sec)

====================================================================================
* SQL
SELECT COUNT(1) FROM 사원 WHERE 입사일자 LIKE '1989%';

* 결과
+----------+
| COUNT(1) |
+----------+
|    28394 |
+----------+
1 row in set (0.16 sec)
====================================================================================
* SQL
SELECT COUNT(1) FROM 사원 WHERE 사원번호 > 100000;

* 결과
+----------+
| count(1) |
+----------+
|   210024 |
+----------+
1 row in set (0.12 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원번호
FROM 사원 USE INDEX(I_입사일자)
WHERE 입사일자 LIKE '1989%'
AND 사원번호 > 100000;

* 결과
+----+-------------+-------+------------+-------+---------------+------------+---------+------+-------+----------+----------------------------------------+
| id | select_type | table | partitions | type  | possible_keys | key        | key_len | ref  | rows  | filtered | Extra                                  |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+-------+----------+----------------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | range | I_입사일자    | I_입사일자 | 7       | NULL | 99709 |   100.00 | Using where; Using index for skip scan |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+-------+----------+----------------------------------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT 사원번호
FROM 사원 USE INDEX(I_입사일자)
WHERE 입사일자 LIKE '1989%'
AND 사원번호 > 100000;

* 결과
+----------+
| 사원번호 |    
+----------+
|   100011 |
|   100028 |
|   100041 |
... 중략 ...
|   499974 |
|   499983 |
|   499991 |
+----------+
20001 rows in set (0.11 sec)
====================================================================================
* SQL
SELECT 사원번호
FROM 사원
WHERE 입사일자 >= '1989-01-01' AND 입사일자 < '1990-01-01'
AND 사원번호 > 100000;

* 결과
+----------+
| 사원번호 |    
+----------+
|   100011 |
|   100028 |
|   100041 |
... 중략 ...
|   499974 |
|   499983 |
|   499991 |
+----------+
20001 rows in set (0.01 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 사원번호
FROM 사원
WHERE 입사일자 >= '1989-01-01' AND 입사일자 < '1990-01-01'
AND 사원번호 > 100000;

* 결과
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+-------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys      | key        | key_len | ref  | rows  | filtered | Extra                    |
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+-------+----------+--------------------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY,I_입사일자 | I_입사일자 | 7       | NULL | 49820 |    50.00 | Using where; Using index |
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+-------+----------+--------------------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
== 4.2.9. ========================================================================== 
====================================================================================
* SQL
SELECT *
FROM 사원출입기록
WHERE 출입문 = 'B';

* 결과
+---------+----------+---------------------+------------+--------+------+
| 순번    | 사원번호 | 입출입시간          | 입출입구분 | 출입문 | 지역 |
+---------+----------+---------------------+------------+--------+------+
|  983026 |   110022 | 2020-05-26 11:16:28 | I          | B      | b    |
|  983027 |   110085 | 2020-09-05 01:20:57 | I          | B      | b    |
|  983028 |   110183 | 2020-03-09 20:55:22 | I          | B      | b    |
... 중략 ...
| 983033 |   111400 | 2020-08-03 08:41:13 | I          | B      | b    |
| 983034 |   111692 | 2020-07-12 04:42:28 | I          | B      | b    |
| 983035 |   110114 | 2020-11-15 21:28:40 | I          | B      | b    |
+--------+----------+---------------------+------------+--------+------+
300000 rows in set (3.70 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원출입기록
WHERE 출입문 = 'B';

* 결과
+----+-------------+--------------+------------+------+---------------+----------+---------+-------+--------+----------+-------+
| id | select_type | table        | partitions | type | possible_keys | key      | key_len | ref   | rows   | filtered | Extra |
+----+-------------+--------------+------------+------+---------------+----------+---------+-------+--------+----------+-------+
|  1 | SIMPLE      | 사원출입기록 | NULL       | ref  | I_출입문      | I_출입문 | 4       | const | 329467 |   100.00 | NULL  |
+----+-------------+--------------+------------+------+---------------+----------+---------+-------+--------+----------+-------+
1 row in set, 1 warning (0.02 sec)
====================================================================================
* SQL
SELECT 출입문, COUNT(1)
FROM 사원출입기록
GROUP BY 출입문;

* 결과
+--------+----------+
| 출입문 | COUNT(1) |
+--------+----------+
| A      |   250000 |
| B      |   300000 |
| C      |    10000 |
| D      |   100000 |
+--------+----------+
4 rows in set (0.24 sec)
====================================================================================
* SQL
SELECT *
FROM 사원출입기록 IGNORE INDEX(I_출입문)
WHERE 출입문 = 'B';

* 결과
+---------+----------+---------------------+------------+--------+------+
| 순번    | 사원번호 | 입출입시간          | 입출입구분 | 출입문 | 지역 |
+---------+----------+---------------------+------------+--------+------+
|  983026 |   110022 | 2020-05-26 11:16:28 | I          | B      | b    |
|  983027 |   110085 | 2020-09-05 01:20:57 | I          | B      | b    |
|  983028 |   110183 | 2020-03-09 20:55:22 | I          | B      | b    |
... 중략 ...
| 983033 |   111400 | 2020-08-03 08:41:13 | I          | B      | b    |
| 983034 |   111692 | 2020-07-12 04:42:28 | I          | B      | b    |
| 983035 |   110114 | 2020-11-15 21:28:40 | I          | B      | b    |
+--------+----------+---------------------+------------+--------+------+
300000 rows in set (0.85 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원출입기록 IGNORE INDEX(I_출입문)
WHERE 출입문 = 'B';

* 결과
+----+-------------+--------------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table        | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+--------------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원출입기록 | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 658935 |    10.00 | Using where |
+----+-------------+--------------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
== 4.2.10. =========================================================================
====================================================================================
* SQL
SELECT 이름, 성
FROM 사원
WHERE 입사일자 BETWEEN STR_TO_DATE('1994-01-01', '%Y-%m-%d') 
AND STR_TO_DATE('2000-12-31', '%Y-%m-%d');

* 결과
+----------------+------------------+
| 이름           | 성               |
+----------------+------------------+
| Saniya         | Kalloufi         |
| Kazuhito       | Cappelletti      |
| Lillian        | Haddadi          |
... 중략 ...
| Rimli          | Dusink           |
| DeForest       | Mullainathan     |
| Sachin         | Tsukuda          |
+----------------+------------------+
48875 rows in set (1.21 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 이름, 성
FROM 사원
WHERE 입사일자 BETWEEN STR_TO_DATE('1994-01-01', '%Y-%m-%d') 
AND STR_TO_DATE('2000-12-31', '%Y-%m-%d');

* 결과
+----+-------------+-------+------------+-------+---------------+------------+---------+------+--------+----------+----------------------------------+
| id | select_type | table | partitions | type  | possible_keys | key        | key_len | ref  | rows   | filtered | Extra                            |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+--------+----------+----------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | range | I_입사일자    | I_입사일자 | 3       | NULL | 112160 |   100.00 | Using index condition; Using MRR |
+----+-------------+-------+------------+-------+---------------+------------+---------+------+--------+----------+----------------------------------+
1 row in set, 1 warning (0.01 sec)
====================================================================================
* SQL
select count(1) from 사원;

* 결과
+----------+
| count(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.30 sec)
====================================================================================
* SQL
SELECT 이름, 성
FROM 사원
WHERE YEAR(입사일자) BETWEEN '1994' AND '2000';

* 결과
+----------------+------------------+
| 이름           | 성               |
+----------------+------------------+
| Saniya         | Kalloufi         |
| Kazuhito       | Cappelletti      |
| Lillian        | Haddadi          |
... 중략 ...
| Rimli          | Dusink           |
| DeForest       | Mullainathan     |
| Sachin         | Tsukuda          |
+----------------+------------------+
48875 rows in set (0.20 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 이름, 성
FROM 사원
WHERE YEAR(입사일자) BETWEEN '1994' AND '2000';

* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299157 |   100.00 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
== 4.3.1. ==========================================================================
====================================================================================
* SQL
SELECT 매핑.사원번호, 부서.부서번호
FROM 부서사원_매핑 매핑, 부서
WHERE 매핑.부서번호 = 부서.부서번호
AND 매핑.시작일자 >= '2002-03-01';

* 결과
+----------+----------+
| 사원번호 | 부서번호 |
+----------+----------+
|    11732 | d009     |
|    14179 | d009     |
|    16989 | d009     |
... 중략 ...
|   483592 | d007     |
|   487945 | d007     |
|   488117 | d007     |
+----------+----------+
1341 rows in set (13.27 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 매핑.사원번호, 부서.부서번호
FROM 부서사원_매핑 매핑,부서
WHERE 매핑.부서번호 = 부서.부서번호
AND 매핑.시작일자 >= '2002-03-01';

* 결과
+----+-------------+-------+------------+-------+---------------+------------+---------+----------------------+-------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key        | key_len | ref                  | rows  | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+------------+---------+----------------------+-------+----------+-------------+
|  1 | SIMPLE      | 부서  | NULL       | index | PRIMARY       | UI_부서명  | 122     | NULL                 |     9 |   100.00 | Using index |
|  1 | SIMPLE      | 매핑  | NULL       | ref   | I_부서번호    | I_부서번호 | 12      | tuning.부서.부서번호 | 41392 |    33.33 | Using where |
+----+-------------+-------+------------+-------+---------------+------------+---------+----------------------+-------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT COUNT(1) FROM 부서사원_매핑;

* 결과
+----------+
| COUNT(1) |
+----------+
|   331603 |
+----------+
1 row in set (1.94 sec)

====================================================================================

* SQL
SELECT COUNT(1) FROM 부서;

* 결과
+----------+
| COUNT(1) |
+----------+
|        9 |
+----------+
1 row in set (0.01 sec)

====================================================================================

* SQL
SELECT COUNT(1) FROM 부서사원_매핑 WHERE 시작일자>='2002-03-01';

* 결과
+----------+
| COUNT(1) |
+----------+
|     1341 |
+----------+
1 row in set (0.27 sec)

====================================================================================
* SQL
SELECT STRAIGHT_JOIN 매핑.사원번호, 부서.부서번호
FROM 부서사원_매핑 매핑, 부서
WHERE 매핑.부서번호 = 부서.부서번호
AND 매핑.시작일자 >= '2002-03-01' ;

* 결과
+----------+----------+
| 사원번호 | 부서번호 |
+----------+----------+
|    11732 | d009     |
|    14179 | d009     |
|    16989 | d009     |
... 중략 ...
|   483592 | d007     |
|   487945 | d007     |
|   488117 | d007     |
+----------+----------+
1341 rows in set (0.17 sec)
====================================================================================
* SQL
EXPLAIN
SELECT STRAIGHT_JOIN 매핑.사원번호, 부서.부서번호
FROM 부서사원_매핑 매핑, 부서
WHERE 매핑.부서번호 = 부서.부서번호
AND 매핑.시작일자 >= '2002-03-01';

* 결과
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------------+--------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref                  | rows   | filtered | Extra       |
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------------+--------+----------+-------------+
|  1 | SIMPLE      | 매핑  | NULL       | ALL    | I_부서번호    | NULL    | NULL    | NULL                 | 331143 |    33.33 | Using where |
|  1 | SIMPLE      | 부서  | NULL       | eq_ref | PRIMARY       | PRIMARY | 12      | tuning.매핑.부서번호 |      1 |   100.00 | Using index |
+----+-------------+-------+------------+--------+---------------+---------+---------+----------------------+--------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)

====================================================================================
== 4.3.2. ==========================================================================
====================================================================================
* SQL
SELECT 사원.사원번호, 사원.이름, 사원.성
  FROM 사원
 WHERE 사원번호 > 450000
   AND ( SELECT MAX(연봉)
           FROM 급여
          WHERE 사원번호 = 사원.사원번호
       ) > 100000;

* 결과
+----------+----------------+------------------+
| 사원번호 | 이름           | 성               |
+----------+----------------+------------------+
|   450025 | Dharmaraja     | Marrevee         |
|   450040 | Iara           | Falby            |
|   450044 | Steen          | Broder           |
... 중략 ...
|   499980 | Gino           | Usery            |
|   499986 | Nathan         | Ranta            |
|   499988 | Bangqing       | Kleiser          |
+----------+----------------+------------------+
3155 rows in set (0.57 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성
  FROM 사원
 WHERE 사원번호 > 450000
   AND ( SELECT MAX(연봉)
           FROM 급여
          WHERE 사원번호 = 사원.사원번호
       ) > 100000;
	   
* 결과
+----+--------------------+-------+------------+-------+---------------+---------+---------+----------------------+--------+----------+-------------+
| id | select_type        | table | partitions | type  | possible_keys | key     | key_len | ref                  | rows   | filtered | Extra       |
+----+--------------------+-------+------------+-------+---------------+---------+---------+----------------------+--------+----------+-------------+
|  1 | PRIMARY            | 사원  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL                 | 104330 |   100.00 | Using where |
|  2 | DEPENDENT SUBQUERY | 급여  | NULL       | ref   | PRIMARY       | PRIMARY | 4       | tuning.사원.사원번호 |      9 |   100.00 | NULL        |
+----+--------------------+-------+------------+-------+---------------+---------+---------+----------------------+--------+----------+-------------+
2 rows in set, 2 warnings (0.01 sec)
====================================================================================
* SQL
SELECT COUNT(1) FROM 사원;

* 결과
+----------+
| COUNT(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.28 sec)
====================================================================================
* SQL
SELECT COUNT(1) FROM 급여;

* 결과
+----------+
| COUNT(1) |
+----------+
|  2844047 |
+----------+
1 row in set (1.32 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 사원
WHERE 사원번호 > 450000;

* 결과
+----------+
| COUNT(1) |
+----------+
|    49999 |
+----------+
1 row in set (0.03 sec)

====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
show index from 급여;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 급여  |          0 | PRIMARY    |            1 | 사원번호    | A         |      298323 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 급여  |          0 | PRIMARY    |            2 | 시작일자    | A         |     2838731 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 급여  |          1 | I_사용여부 |            1 | 사용여부    | A         |           1 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
3 rows in set (0.01 sec)

====================================================================================
* SQL
SELECT 사원.사원번호,
       사원.이름,
       사원.성
  FROM 사원,
       급여
 WHERE 사원.사원번호 > 450000
   AND 사원.사원번호 = 급여.사원번호
 GROUP BY 사원.사원번호
HAVING MAX(급여.연봉) > 100000;

* 결과
+----------+----------------+------------------+
| 사원번호 | 이름           | 성               |
+----------+----------------+------------------+
|   450025 | Dharmaraja     | Marrevee         |
|   450040 | Iara           | Falby            |
|   450044 | Steen          | Broder           |
... 중략 ...
|   499980 | Gino           | Usery            |
|   499986 | Nathan         | Ranta            |
|   499988 | Bangqing       | Kleiser          |
+----------+----------------+------------------+
3155 rows in set (0.11 sec)


====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호,
       사원.이름,
       사원.성
  FROM 사원,
       급여
 WHERE 사원.사원번호 > 450000
   AND 사원.사원번호 = 급여.사원번호
 GROUP BY 사원.사원번호
HAVING MAX(급여.연봉) > 100000;

* 결과
+----+-------------+-------+------------+-------+------------------------------+---------+---------+----------------------+--------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys                | key     | key_len | ref                  | rows   | filtered | Extra       |
+----+-------------+-------+------------+-------+------------------------------+---------+---------+----------------------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY,I_입사일자,I_성별_성 | PRIMARY | 4       | NULL                 | 104330 |   100.00 | Using where |
|  1 | SIMPLE      | 급여  | NULL       | ref   | PRIMARY                      | PRIMARY | 4       | tuning.사원.사원번호 |      9 |   100.00 | NULL        |
+----+-------------+-------+------------+-------+------------------------------+---------+---------+----------------------+--------+----------+-------------+
2 rows in set, 1 warning (0.01 sec)

====================================================================================
== 4.3.3. ==========================================================================
====================================================================================
* SQL
SELECT COUNT(DISTINCT 사원.사원번호) as 데이터건수
  FROM 사원,
       ( SELECT 사원번호
           FROM 사원출입기록 기록
          WHERE 출입문 = 'A'
       ) 기록
 WHERE 사원.사원번호 = 기록.사원번호;

* 결과
+------------+
| 데이터건수 |
+------------+
|     150000 |
+------------+
1 row in set (22.50 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(DISTINCT 사원.사원번호) as 데이터건수
  FROM 사원,
       ( SELECT 사원번호
           FROM 사원출입기록 기록
          WHERE 출입문 = 'A'
       ) 기록
 WHERE 사원.사원번호 = 기록.사원번호;
 
* 결과
+----+-------------+-------+------------+--------+---------------+----------+---------+----------------------+--------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys | key      | key_len | ref                  | rows   | filtered | Extra       |
+----+-------------+-------+------------+--------+---------------+----------+---------+----------------------+--------+----------+-------------+
|  1 | SIMPLE      | 기록  | NULL       | ref    | I_출입문      | I_출입문 | 4       | const                | 329467 |   100.00 | Using index |
|  1 | SIMPLE      | 사원  | NULL       | eq_ref | PRIMARY       | PRIMARY  | 4       | tuning.기록.사원번호 |      1 |   100.00 | Using index |
+----+-------------+-------+------------+--------+---------------+----------+---------+----------------------+--------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
DESC 사원;

* 결과
+----------+---------------+------+-----+---------+-------+
| Field    | Type          | Null | Key | Default | Extra |
+----------+---------------+------+-----+---------+-------+
| 사원번호 | int           | NO   | PRI | NULL    |       |
| 생년월일 | date          | NO   |     | NULL    |       |
| 이름     | varchar(14)   | NO   |     | NULL    |       |
| 성       | varchar(16)   | NO   |     | NULL    |       |
| 성별     | enum('M','F') | NO   | MUL | NULL    |       |
| 입사일자 | date          | NO   | MUL | NULL    |       |
+----------+---------------+------+-----+---------+-------+
6 rows in set (0.01 sec)
====================================================================================
* SQL
SELECT COUNT(1) as 데이터건수
  FROM 사원
 WHERE EXISTS (SELECT 1
                 FROM 사원출입기록 기록
                WHERE 출입문 = 'A'
                AND 기록.사원번호 = 사원.사원번호);

* 결과
+------------+
| 데이터건수 |
+------------+
|     150000 |
+------------+
1 row in set (0.45 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(1) as 데이터건수
  FROM 사원
 WHERE EXISTS (SELECT 1
                 FROM 사원출입기록 기록
                WHERE 출입문 = 'A'
                AND 기록.사원번호 = 사원.사원번호);
				
* 결과
+----+--------------+-------------+------------+--------+---------------------+---------------------+---------+----------------------+--------+----------+--------------------------+
| id | select_type  | table       | partitions | type   | possible_keys       | key                 | key_len | ref                  | rows   | filtered | Extra                    |
+----+--------------+-------------+------------+--------+---------------------+---------------------+---------+----------------------+--------+----------+--------------------------+
|  1 | SIMPLE       | 사원        | NULL       | index  | PRIMARY             | I_입사일자          | 3       | NULL                 | 299157 |   100.00 | Using where; Using index |
|  1 | SIMPLE       | <subquery2> | NULL       | eq_ref | <auto_distinct_key> | <auto_distinct_key> | 4       | tuning.사원.사원번호 |      1 |   100.00 | NULL                     |
|  2 | MATERIALIZED | 기록        | NULL       | ref    | I_출입문            | I_출입문            | 4       | const                | 329467 |   100.00 | Using index              |
+----+--------------+-------------+------------+--------+---------------------+---------------------+---------+----------------------+--------+----------+--------------------------+
3 rows in set, 2 warnings (0.00 sec)	


====================================================================================
== 5.1.1. ==========================================================================
====================================================================================
* SQL
SELECT 사원.사원번호, 
       급여.평균연봉, 
         급여.최고연봉, 
         급여.최저연봉
 FROM 사원,
       ( SELECT 사원번호,
            ROUND(AVG(연봉),0) 평균연봉,
                  ROUND(MAX(연봉),0) 최고연봉,
                  ROUND(MIN(연봉),0) 최저연봉
             FROM 급여
            GROUP BY 사원번호
       ) 급여
WHERE 사원.사원번호 = 급여.사원번호
AND 사원.사원번호 BETWEEN 10001 AND 10100;

* 결과
+----------+----------+----------+----------+
| 사원번호 | 평균연봉 | 최고연봉 | 최저연봉 |
+----------+----------+----------+----------+
|    10001 |    75389 |    88958 |    60117 |
|    10002 |    68855 |    72527 |    65828 |
|    10003 |    43030 |    43699 |    40006 |
|    10004 |    56512 |    74057 |    40054 |
|    10005 |    87276 |    94692 |    78228 |
|    10006 |    50515 |    60098 |    40000 |
|    10007 |    70827 |    88070 |    56724 |
|    10008 |    49308 |    52668 |    46671 |
|    10009 |    78285 |    94443 |    60929 |
|    10010 |    76723 |    80324 |    72488 |
|    10011 |    49782 |    56753 |    42365 |
|    10012 |    46903 |    54794 |    40000 |
|    10013 |    52432 |    68901 |    40000 |
|    10014 |    52990 |    60598 |    46168 |
|    10015 |    40000 |    40000 |    40000 |
|    10016 |    74995 |    77935 |    70889 |
|    10017 |    87065 |    99651 |    71380 |
|    10018 |    68640 |    84672 |    55881 |
|    10019 |    47007 |    50032 |    44276 |
|    10020 |    43278 |    47017 |    40000 |
|    10021 |    68650 |    84169 |    55025 |
|    10022 |    40428 |    41348 |    39935 |
|    10023 |    49438 |    50319 |    47883 |
|    10024 |    90572 |    96646 |    83733 |
|    10025 |    51959 |    57585 |    40000 |
|    10026 |    58253 |    66313 |    47585 |
|    10027 |    43319 |    46145 |    39520 |
|    10028 |    54142 |    58502 |    48859 |
|    10029 |    71870 |    77777 |    63163 |
|    10030 |    78853 |    88806 |    66956 |
|    10031 |    48178 |    56689 |    40000 |
|    10032 |    56634 |    69539 |    48426 |
|    10033 |    55988 |    60433 |    51258 |
|    10034 |    51543 |    53164 |    47561 |
|    10035 |    55906 |    68755 |    41538 |
|    10036 |    54160 |    63053 |    42819 |
|    10037 |    50413 |    60992 |    39765 |
|    10038 |    55665 |    64254 |    40000 |
|    10039 |    53052 |    63918 |    40000 |
|    10040 |    62092 |    72668 |    52153 |
|    10041 |    70343 |    81705 |    56893 |
|    10042 |    88329 |    95035 |    81662 |
|    10043 |    64417 |    77659 |    49324 |
|    10044 |    50801 |    58345 |    40919 |
|    10045 |    44556 |    47984 |    41971 |
|    10046 |    49502 |    62218 |    40000 |
|    10047 |    69665 |    81037 |    54982 |
|    10048 |    39754 |    40000 |    39507 |
|    10049 |    43365 |    51326 |    39735 |
|    10050 |    88987 |    97830 |    74366 |
|    10051 |    57594 |    64905 |    48817 |
|    10052 |    61815 |    67156 |    56908 |
|    10053 |    73346 |    78478 |    67854 |
|    10054 |    46357 |    53906 |    40000 |
|    10055 |    85483 |    90843 |    80024 |
|    10056 |    62168 |    74722 |    48857 |
|    10057 |    60253 |    68061 |    49616 |
|    10058 |    63303 |    72542 |    52787 |
|    10059 |    84431 |    94161 |    71218 |
|    10060 |    81555 |    93188 |    74686 |
|    10061 |    82247 |    97338 |    68577 |
|    10062 |    63594 |    68784 |    55685 |
|    10063 |    58313 |    74841 |    40000 |
|    10064 |    42775 |    48454 |    39551 |
|    10065 |    42725 |    47437 |    40000 |
|    10066 |    88558 |   103672 |    69736 |
|    10067 |    64081 |    83254 |    44642 |
|    10068 |   101224 |   113229 |    87964 |
|    10069 |    74965 |    86641 |    67675 |
|    10070 |    75166 |    96322 |    55999 |
|    10071 |    44851 |    53315 |    40000 |
|    10072 |    52682 |    64726 |    39567 |
|    10073 |    56473 |    56473 |    56473 |
|    10074 |    71721 |    80820 |    61714 |
|    10075 |    52226 |    67492 |    43590 |
|    10076 |    56337 |    62921 |    47319 |
|    10077 |    47678 |    54699 |    40000 |
|    10078 |    50940 |    54652 |    46833 |
|    10079 |    59053 |    67231 |    53492 |
|    10080 |    64140 |    72729 |    54916 |
|    10081 |    67265 |    79351 |    55786 |
|    10082 |    48935 |    48935 |    48935 |
|    10083 |    59606 |    77186 |    40000 |
|    10084 |    82092 |    93621 |    69811 |
|    10085 |    50348 |    60910 |    40000 |
|    10086 |    86675 |    96471 |    80934 |
|    10087 |    99015 |   102651 |    96750 |
|    10088 |    80508 |    98003 |    65957 |
|    10089 |    66329 |    77955 |    56040 |
|    10090 |    59204 |    75401 |    44978 |
|    10091 |    47918 |    60014 |    40000 |
|    10092 |    60056 |    66803 |    53977 |
|    10093 |    75089 |    82715 |    67856 |
|    10094 |    70947 |    85225 |    58001 |
|    10095 |    70909 |    80955 |    63668 |
|    10096 |    64945 |    68612 |    61395 |
|    10097 |    57068 |    70161 |    44886 |
|    10098 |    48210 |    56202 |    40000 |
|    10099 |    83902 |    98538 |    68781 |
|    10100 |    64537 |    74957 |    54398 |
+----------+----------+----------+----------+
100 rows in set (2.36 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 
       급여.평균연봉, 
         급여.최고연봉, 
         급여.최저연봉
 FROM 사원,
       ( SELECT 사원번호,
            ROUND(AVG(연봉),0) 평균연봉,
                  ROUND(MAX(연봉),0) 최고연봉,
                  ROUND(MIN(연봉),0) 최저연봉
             FROM 급여
            GROUP BY 사원번호
       ) 급여
WHERE 사원.사원번호 = 급여.사원번호
AND 사원.사원번호 BETWEEN 10001 AND 10100;


* 결과
+----+-------------+------------+------------+-------+--------------------+-------------+---------+----------------------+---------+----------+--------------------------+
| id | select_type | table      | partitions | type  | possible_keys      | key         | key_len | ref                  | rows    | filtered | Extra                    |
+----+-------------+------------+------------+-------+--------------------+-------------+---------+----------------------+---------+----------+--------------------------+
|  1 | PRIMARY     | 사원       | NULL       | range | PRIMARY            | PRIMARY     | 4       | NULL                 |     100 |   100.00 | Using where; Using index |
|  1 | PRIMARY     | <derived2> | NULL       | ref   | <auto_key0>        | <auto_key0> | 4       | tuning.사원.사원번호 |      10 |   100.00 | NULL                     |
|  2 | DERIVED     | 급여       | NULL       | index | PRIMARY,I_사용여부 | PRIMARY     | 7       | NULL                 | 2838731 |   100.00 | NULL                     |
+----+-------------+------------+------------+-------+--------------------+-------------+---------+----------------------+---------+----------+--------------------------+
3 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT count(1) from 사원;

* 결과
+----------+
| count(1) |
+----------+
|   300024 |
+----------+
1 row in set (18.43 sec)
====================================================================================
* SQL
SELECT count(1) from 사원 where 사원번호 BETWEEN 10001 AND 10100;

* 결과
+----------+
| count(1) |
+----------+
|      100 |
+----------+
1 row in set (0.00 sec)

====================================================================================
* SQL
SELECT 사원.사원번호,
       ( SELECT ROUND(AVG(연봉),0)
           FROM 급여 as 급여1
          WHERE 사원번호 = 사원.사원번호
       ) AS 평균연봉,
       ( SELECT ROUND(MAX(연봉),0)
           FROM 급여 as 급여2
          WHERE 사원번호 = 사원.사원번호
       ) AS 최고연봉,
       ( SELECT ROUND(MIN(연봉),0)
           FROM 급여 as 급여3
          WHERE 사원번호 = 사원.사원번호
       ) AS 최저연봉
  FROM 사원
 WHERE 사원.사원번호 BETWEEN 10001 AND 10100;

* 결과
+----------+----------+----------+----------+
| 사원번호 | 평균연봉 | 최고연봉 | 최저연봉 |
+----------+----------+----------+----------+
|    10001 |    75389 |    88958 |    60117 |
|    10002 |    68855 |    72527 |    65828 |
|    10003 |    43030 |    43699 |    40006 |
|    10004 |    56512 |    74057 |    40054 |
|    10005 |    87276 |    94692 |    78228 |
|    10006 |    50515 |    60098 |    40000 |
|    10007 |    70827 |    88070 |    56724 |
|    10008 |    49308 |    52668 |    46671 |
|    10009 |    78285 |    94443 |    60929 |
|    10010 |    76723 |    80324 |    72488 |
|    10011 |    49782 |    56753 |    42365 |
|    10012 |    46903 |    54794 |    40000 |
|    10013 |    52432 |    68901 |    40000 |
|    10014 |    52990 |    60598 |    46168 |
|    10015 |    40000 |    40000 |    40000 |
|    10016 |    74995 |    77935 |    70889 |
|    10017 |    87065 |    99651 |    71380 |
|    10018 |    68640 |    84672 |    55881 |
|    10019 |    47007 |    50032 |    44276 |
|    10020 |    43278 |    47017 |    40000 |
|    10021 |    68650 |    84169 |    55025 |
|    10022 |    40428 |    41348 |    39935 |
|    10023 |    49438 |    50319 |    47883 |
|    10024 |    90572 |    96646 |    83733 |
|    10025 |    51959 |    57585 |    40000 |
|    10026 |    58253 |    66313 |    47585 |
|    10027 |    43319 |    46145 |    39520 |
|    10028 |    54142 |    58502 |    48859 |
|    10029 |    71870 |    77777 |    63163 |
|    10030 |    78853 |    88806 |    66956 |
|    10031 |    48178 |    56689 |    40000 |
|    10032 |    56634 |    69539 |    48426 |
|    10033 |    55988 |    60433 |    51258 |
|    10034 |    51543 |    53164 |    47561 |
|    10035 |    55906 |    68755 |    41538 |
|    10036 |    54160 |    63053 |    42819 |
|    10037 |    50413 |    60992 |    39765 |
|    10038 |    55665 |    64254 |    40000 |
|    10039 |    53052 |    63918 |    40000 |
|    10040 |    62092 |    72668 |    52153 |
|    10041 |    70343 |    81705 |    56893 |
|    10042 |    88329 |    95035 |    81662 |
|    10043 |    64417 |    77659 |    49324 |
|    10044 |    50801 |    58345 |    40919 |
|    10045 |    44556 |    47984 |    41971 |
|    10046 |    49502 |    62218 |    40000 |
|    10047 |    69665 |    81037 |    54982 |
|    10048 |    39754 |    40000 |    39507 |
|    10049 |    43365 |    51326 |    39735 |
|    10050 |    88987 |    97830 |    74366 |
|    10051 |    57594 |    64905 |    48817 |
|    10052 |    61815 |    67156 |    56908 |
|    10053 |    73346 |    78478 |    67854 |
|    10054 |    46357 |    53906 |    40000 |
|    10055 |    85483 |    90843 |    80024 |
|    10056 |    62168 |    74722 |    48857 |
|    10057 |    60253 |    68061 |    49616 |
|    10058 |    63303 |    72542 |    52787 |
|    10059 |    84431 |    94161 |    71218 |
|    10060 |    81555 |    93188 |    74686 |
|    10061 |    82247 |    97338 |    68577 |
|    10062 |    63594 |    68784 |    55685 |
|    10063 |    58313 |    74841 |    40000 |
|    10064 |    42775 |    48454 |    39551 |
|    10065 |    42725 |    47437 |    40000 |
|    10066 |    88558 |   103672 |    69736 |
|    10067 |    64081 |    83254 |    44642 |
|    10068 |   101224 |   113229 |    87964 |
|    10069 |    74965 |    86641 |    67675 |
|    10070 |    75166 |    96322 |    55999 |
|    10071 |    44851 |    53315 |    40000 |
|    10072 |    52682 |    64726 |    39567 |
|    10073 |    56473 |    56473 |    56473 |
|    10074 |    71721 |    80820 |    61714 |
|    10075 |    52226 |    67492 |    43590 |
|    10076 |    56337 |    62921 |    47319 |
|    10077 |    47678 |    54699 |    40000 |
|    10078 |    50940 |    54652 |    46833 |
|    10079 |    59053 |    67231 |    53492 |
|    10080 |    64140 |    72729 |    54916 |
|    10081 |    67265 |    79351 |    55786 |
|    10082 |    48935 |    48935 |    48935 |
|    10083 |    59606 |    77186 |    40000 |
|    10084 |    82092 |    93621 |    69811 |
|    10085 |    50348 |    60910 |    40000 |
|    10086 |    86675 |    96471 |    80934 |
|    10087 |    99015 |   102651 |    96750 |
|    10088 |    80508 |    98003 |    65957 |
|    10089 |    66329 |    77955 |    56040 |
|    10090 |    59204 |    75401 |    44978 |
|    10091 |    47918 |    60014 |    40000 |
|    10092 |    60056 |    66803 |    53977 |
|    10093 |    75089 |    82715 |    67856 |
|    10094 |    70947 |    85225 |    58001 |
|    10095 |    70909 |    80955 |    63668 |
|    10096 |    64945 |    68612 |    61395 |
|    10097 |    57068 |    70161 |    44886 |
|    10098 |    48210 |    56202 |    40000 |
|    10099 |    83902 |    98538 |    68781 |
|    10100 |    64537 |    74957 |    54398 |
+----------+----------+----------+----------+
100 rows in set (0.00 sec)
====================================================================================
====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호,
       ( SELECT ROUND(AVG(연봉),0)
           FROM 급여 as 급여1
          WHERE 사원번호 = 사원.사원번호
       ) AS 평균연봉,
       ( SELECT ROUND(MAX(연봉),0)
           FROM 급여 as 급여2
          WHERE 사원번호 = 사원.사원번호
       ) AS 최고연봉,
       ( SELECT ROUND(MIN(연봉),0)
           FROM 급여 as 급여3
          WHERE 사원번호 = 사원.사원번호
       ) AS 최저연봉
  FROM 사원
 WHERE 사원.사원번호 BETWEEN 10001 AND 10100;
 
* 결과
+----+--------------------+-------+------------+-------+------------------------------+---------+---------+----------------------+------+----------+--------------------------+
| id | select_type        | table | partitions | type  | possible_keys                | key     | key_len | ref                  | rows | filtered | Extra                    |
+----+--------------------+-------+------------+-------+------------------------------+---------+---------+----------------------+------+----------+--------------------------+
|  1 | PRIMARY            | 사원  | NULL       | range | PRIMARY,I_입사일자,I_성별_성 | PRIMARY | 4       | NULL                 |  100 |   100.00 | Using where; Using index |
|  4 | DEPENDENT SUBQUERY | 급여3 | NULL       | ref   | PRIMARY                      | PRIMARY | 4       | tuning.사원.사원번호 |    9 |   100.00 | NULL                     |
|  3 | DEPENDENT SUBQUERY | 급여2 | NULL       | ref   | PRIMARY                      | PRIMARY | 4       | tuning.사원.사원번호 |    9 |   100.00 | NULL                     |
|  2 | DEPENDENT SUBQUERY | 급여1 | NULL       | ref   | PRIMARY                      | PRIMARY | 4       | tuning.사원.사원번호 |    9 |   100.00 | NULL                     |
+----+--------------------+-------+------------+-------+------------------------------+---------+---------+----------------------+------+----------+--------------------------+

4 rows in set, 4 warnings (0.00 sec)
====================================================================================
== 5.1.2. ==========================================================================
====================================================================================
* SQL
SELECT 사원.사원번호, 사원.이름, 사원.성, 사원.입사일자
  FROM 사원,
       급여       
 WHERE 사원.사원번호 = 급여.사원번호
   AND 사원.사원번호 BETWEEN 10001 AND 50000
 GROUP BY 사원.사원번호
 ORDER BY SUM(급여.연봉) DESC
 LIMIT 150,10;
 
* 결과
+----------+----------+---------------+------------+
| 사원번호 | 이름     | 성            | 입사일자   |
+----------+----------+---------------+------------+
|    34821 | Gila     | Suomi         | 1985-02-20 |
|    30351 | Djenana  | Blokdijk      | 1985-07-15 |
|    15598 | Kristinn | Kemmerer      | 1986-10-07 |
|    20817 | Yucai    | Albarhamtoshy | 1986-12-27 |
|    30249 | Aran     | Bridgland     | 1985-03-31 |
|    21465 | Shalesh  | Terwilliger   | 1985-03-05 |
|    13916 | Vidya    | Wynblatt      | 1986-06-06 |
|    49465 | Chenyi   | Schusler      | 1989-02-15 |
|    33197 | Dmitry   | Riefers       | 1985-04-07 |
|    43888 | Sushant  | Baalen        | 1985-12-24 |
+----------+----------+---------------+------------+
10 rows in set (0.41 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성, 사원.입사일자
  FROM 사원,
       급여       
 WHERE 사원.사원번호 = 급여.사원번호
   AND 사원.사원번호 BETWEEN 10001 AND 50000
 GROUP BY 사원.사원번호
 ORDER BY SUM(급여.연봉) DESC
 LIMIT 150,10;
 
* 결과
+----+-------------+-------+------------+-------+------------------------------+---------+---------+----------------------+-------+----------+----------------------------------------------+
| id | select_type | table | partitions | type  | possible_keys                | key     | key_len | ref                  | rows  | filtered | Extra                                        |
+----+-------------+-------+------------+-------+------------------------------+---------+---------+----------------------+-------+----------+----------------------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY,I_입사일자,I_성별_성 | PRIMARY | 4       | NULL                 | 79652 |   100.00 | Using where; Using temporary; Using filesort |
|  1 | SIMPLE      | 급여  | NULL       | ref   | PRIMARY                      | PRIMARY | 4       | tuning.사원.사원번호 |     9 |   100.00 | NULL                                         |
+----+-------------+-------+------------+-------+------------------------------+---------+---------+----------------------+-------+----------+----------------------------------------------+
2 rows in set, 1 warning (0.01 sec)
====================================================================================
* SQL
SELECT 사원.사원번호, 사원.이름, 사원.성, 사원.입사일자
  FROM (SELECT 사원번호
          FROM 급여
           WHERE 사원번호 BETWEEN 10001 AND 50000
           GROUP BY 사원번호
           ORDER BY SUM(급여.연봉) DESC
           LIMIT 150,10) 급여,
        사원
 WHERE 사원.사원번호 = 급여.사원번호;

* 결과
+----------+----------+---------------+------------+
| 사원번호 | 이름     | 성            | 입사일자   |
+----------+----------+---------------+------------+
|    34821 | Gila     | Suomi         | 1985-02-20 |
|    30351 | Djenana  | Blokdijk      | 1985-07-15 |
|    15598 | Kristinn | Kemmerer      | 1986-10-07 |
|    20817 | Yucai    | Albarhamtoshy | 1986-12-27 |
|    30249 | Aran     | Bridgland     | 1985-03-31 |
|    21465 | Shalesh  | Terwilliger   | 1985-03-05 |
|    13916 | Vidya    | Wynblatt      | 1986-06-06 |
|    49465 | Chenyi   | Schusler      | 1989-02-15 |
|    33197 | Dmitry   | Riefers       | 1985-04-07 |
|    43888 | Sushant  | Baalen        | 1985-12-24 |
+----------+----------+---------------+------------+
10 rows in set (0.21 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성, 사원.입사일자
  FROM (SELECT 사원번호
          FROM 급여
           WHERE 사원번호 BETWEEN 10001 AND 50000
           GROUP BY 사원번호
           ORDER BY SUM(급여.연봉) DESC
           LIMIT 150,10) 급여,
        사원
 WHERE 사원.사원번호 = 급여.사원번호;
 
* 결과
+----+-------------+------------+------------+--------+--------------------+---------+---------+---------------+--------+----------+----------------------------------------------+
| id | select_type | table      | partitions | type   | possible_keys      | key     | key_len | ref           | rows   | filtered | Extra                                        |
+----+-------------+------------+------------+--------+--------------------+---------+---------+---------------+--------+----------+----------------------------------------------+
|  1 | PRIMARY     | <derived2> | NULL       | ALL    | NULL               | NULL    | NULL    | NULL          |    160 |   100.00 | NULL                                         |
|  1 | PRIMARY     | 사원       | NULL       | eq_ref | PRIMARY            | PRIMARY | 4       | 급여.사원번호 |      1 |   100.00 | NULL                                         |
|  2 | DERIVED     | 급여       | NULL       | range  | PRIMARY,I_사용여부 | PRIMARY | 4       | NULL          | 779148 |   100.00 | Using where; Using temporary; Using filesort |
+----+-------------+------------+------------+--------+--------------------+---------+---------+---------------+--------+----------+----------------------------------------------+
3 rows in set, 1 warning (0.01 sec)
====================================================================================
== 5.1.3 ===========================================================================
====================================================================================
* SQL
SELECT COUNT(사원번호) AS 카운트
  FROM (
         SELECT 사원.사원번호, 부서관리자.부서번호
           FROM ( SELECT *
                   FROM 사원
                  WHERE 성별= 'M'
                    AND 사원번호 > 300000
                ) 사원
           LEFT JOIN 부서관리자
                 ON 사원.사원번호 = 부서관리자.사원번호
       ) 서브쿼리;

* 결과
+--------+
| 카운트 |
+--------+
|  60108 |
+--------+
1 row in set (0.15 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(사원번호) AS 카운트
  FROM (
         SELECT 사원.사원번호, 부서관리자.부서번호
           FROM ( SELECT *
                   FROM 사원
                  WHERE 성별= 'M'
                    AND 사원번호 > 300000
                ) 사원
           LEFT JOIN 부서관리자
                 ON 사원.사원번호 = 부서관리자.사원번호
       ) 서브쿼리;
	   
* 결과
+----+-------------+------------+------------+------+-------------------+-----------+---------+----------------------+--------+----------+--------------------------+
| id | select_type | table      | partitions | type | possible_keys     | key       | key_len | ref                  | rows   | filtered | Extra                    |
+----+-------------+------------+------------+------+-------------------+-----------+---------+----------------------+--------+----------+--------------------------+
|  1 | SIMPLE      | 사원       | NULL       | ref  | PRIMARY,I_성별_성 | I_성별_성 | 1       | const                | 149578 |    50.00 | Using where; Using index |
|  1 | SIMPLE      | 부서관리자 | NULL       | ref  | PRIMARY           | PRIMARY   | 4       | tuning.사원.사원번호 |      1 |   100.00 | Using index              |
+----+-------------+------------+------------+------+-------------------+-----------+---------+----------------------+--------+----------+--------------------------+
2 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT COUNT(사원번호) as 카운트
  FROM 사원
 WHERE 성별 = 'M'
   AND 사원번호 > 300000;

* 결과
+--------+
| 카운트 |
+--------+
|  60108 |
+--------+
1 row in set (0.05 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(사원번호) as 카운트
  FROM 사원
 WHERE 성별 = 'M'
   AND 사원번호 > 300000;
   
* 결과
+----+-------------+-------+------------+-------+-------------------+-----------+---------+------+-------+----------+----------------------------------------+
| id | select_type | table | partitions | type  | possible_keys     | key       | key_len | ref  | rows  | filtered | Extra                                  |
+----+-------------+-------+------------+-------+-------------------+-----------+---------+------+-------+----------+----------------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | range | PRIMARY,I_성별_성 | I_성별_성 | 55      | NULL | 49854 |   100.00 | Using where; Using index for skip scan |
+----+-------------+-------+------------+-------+-------------------+-----------+---------+------+-------+----------+----------------------------------------+
1 row in set, 1 warning (0.00 sec) 
====================================================================================
== 5.1.4. ==========================================================================
====================================================================================
* SQL
SELECT DISTINCT 매핑.부서번호
  FROM 부서관리자 관리자,
       부서사원_매핑 매핑
 WHERE 관리자.부서번호 = 매핑.부서번호
 ORDER BY 매핑.부서번호;

* 결과
+----------+
| 부서번호 |
+----------+
| d001     |
| d002     |
| d003     |
| d004     |
| d005     |
| d006     |
| d007     |
| d008     |
| d009     |
+----------+
9 rows in set (1.17 sec)

====================================================================================
* SQL
EXPLAIN
SELECT DISTINCT 매핑.부서번호
  FROM 부서관리자 관리자,
       부서사원_매핑 매핑
 WHERE 관리자.부서번호 = 매핑.부서번호
 ORDER BY 매핑.부서번호;
 
* 결과
+----+-------------+--------+------------+-------+--------------------+------------+---------+----------------------+--------+----------+------------------------------+
| id | select_type | table  | partitions | type  | possible_keys      | key        | key_len | ref                  | rows   | filtered | Extra                        |
+----+-------------+--------+------------+-------+--------------------+------------+---------+----------------------+--------+----------+------------------------------+
|  1 | SIMPLE      | 매핑   | NULL       | index | PRIMARY,I_부서번호 | I_부서번호 | 12      | NULL                 | 331143 |   100.00 | Using index; Using temporary |
|  1 | SIMPLE      | 관리자 | NULL       | ref   | I_부서번호         | I_부서번호 | 12      | tuning.매핑.부서번호 |      2 |   100.00 | Using index; Distinct        |
+----+-------------+--------+------------+-------+--------------------+------------+---------+----------------------+--------+----------+------------------------------+
2 rows in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT 매핑.부서번호
  FROM ( SELECT DISTINCT 부서번호 
           FROM 부서사원_매핑 매핑
       ) 매핑
 WHERE EXISTS (SELECT 1 
                 FROM 부서관리자 관리자
                WHERE 부서번호 = 매핑.부서번호)
 ORDER BY 매핑.부서번호;

* 결과
+----------+
| 부서번호 |
+----------+
| d001     |
| d002     |
| d003     |
| d004     |
| d005     |
| d006     |
| d007     |
| d008     |
| d009     |
+----------+
9 rows in set (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 매핑.부서번호
  FROM ( SELECT DISTINCT 부서번호 
           FROM 부서사원_매핑 매핑
       ) 매핑
 WHERE EXISTS (SELECT 1 
                 FROM 부서관리자 관리자
                WHERE 부서번호 = 매핑.부서번호)
 ORDER BY 매핑.부서번호;
 
* 결과
+----+-------------+------------+------------+-------+--------------------+-------------+---------+------------------------+------+----------+---------------------------------------------------------+
| id | select_type | table      | partitions | type  | possible_keys      | key         | key_len | ref                    | rows | filtered | Extra                                                   |
+----+-------------+------------+------------+-------+--------------------+-------------+---------+------------------------+------+----------+---------------------------------------------------------+
|  1 | PRIMARY     | 관리자     | NULL       | index | I_부서번호         | I_부서번호  | 12      | NULL                   |   24 |    37.50 | Using index; Using temporary; Using filesort; LooseScan |
|  1 | PRIMARY     | <derived2> | NULL       | ref   | <auto_key0>        | <auto_key0> | 12      | tuning.관리자.부서번호 |    2 |   100.00 | Using index                                             |
|  2 | DERIVED     | 매핑       | NULL       | range | PRIMARY,I_부서번호 | I_부서번호  | 12      | NULL                   |    9 |   100.00 | Using index for group-by                                |
+----+-------------+------------+------------+-------+--------------------+-------------+---------+------------------------+------+----------+---------------------------------------------------------+
3 rows in set, 2 warnings (0.00 sec) 

====================================================================================
== 5.2.1. ==========================================================================
====================================================================================
* SQL
SELECT *
  FROM 사원
 WHERE 이름 = 'Georgi'
   AND 성 = 'Wielonsky';

* 결과
+----------+------------+--------+-----------+------+------------+
| 사원번호 | 생년월일   | 이름   | 성        | 성별 | 입사일자   |
+----------+------------+--------+-----------+------+------------+
|   499814 | 1960-12-28 | Georgi | Wielonsky | M    | 1989-01-31 |
+----------+------------+--------+-----------+------+------------+
1 row in set (0.19 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
  FROM 사원
 WHERE 이름 = 'Georgi'
   AND 성 = 'Wielonsky';
   
* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 299157 |     1.00 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT COUNT(DISTINCT(이름)) 이름_개수, COUNT(DISTINCT(성  )) 성_개수, COUNT(1) 전체
FROM 사원;

* 결과
+-----------+---------+--------+
| 이름_개수 | 성_개수 | 전체   |
+-----------+---------+--------+
|      1275 |    1637 | 300024 |
+-----------+---------+--------+
1 row in set (0.41 sec)
====================================================================================
* SQL
ALTER TABLE 사원
ADD INDEX I_사원_성_이름 (성,이름);

* 결과
Query OK, 0 rows affected (1.94 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
SELECT *
FROM 사원
WHERE 이름 = 'Georgi'
AND 성 = 'Wielonsky';

* 결과
+----------+------------+--------+-----------+------+------------+
| 사원번호 | 생년월일   | 이름   | 성        | 성별 | 입사일자   |
+----------+------------+--------+-----------+------+------------+
|   499814 | 1960-12-28 | Georgi | Wielonsky | M    | 1989-01-31 |
+----------+------------+--------+-----------+------+------------+
1 row in set (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT *
FROM 사원
WHERE 이름 = 'Georgi'
AND 성 = 'Wielonsky';

* 결과
+----+-------------+-------+------------+------+----------------+----------------+---------+-------------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys  | key            | key_len | ref         | rows | filtered | Extra |
+----+-------------+-------+------------+------+----------------+----------------+---------+-------------+------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | ref  | I_사원_성_이름 | I_사원_성_이름 | 94      | const,const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+------+----------------+----------------+---------+-------------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
alter table 사원 drop index I_사원_성_이름;

* 결과
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
== 5.2.2. ==========================================================================
====================================================================================
* SQL
SELECT *
  FROM 사원
 WHERE 이름 = 'Matt'
    OR 입사일자 = '1987-03-31';

* 결과
+----------+------------+-------------+-----------------+------+------------+
| 사원번호 | 생년월일   | 이름        | 성              | 성별 | 입사일자   |
+----------+------------+-------------+-----------------+------+------------+
|    10083 | 1959-07-23 | Vishv       | Zockler         | M    | 1987-03-31 |
|    10690 | 1962-09-06 | Matt        | Jumpertz        | F    | 1989-08-22 |
|    12302 | 1962-02-14 | Matt        | Plessier        | M    | 1987-01-28 |
... 중략 ...
|   495781 | 1960-10-06 | Georg       | Velasco         | M    | 1987-03-31 |
|   497243 | 1962-10-13 | Jianwen     | Kalsbeek        | M    | 1987-03-31 |
|   497766 | 1960-09-25 | Matt        | Atrawala        | F    | 1987-02-11 |
+----------+------------+-------------+-----------------+------+------------+
343 rows in set (0.24 sec)
====================================================================================
* SQL
EXPLAIN
SELECT *
  FROM 사원
 WHERE 이름 = 'Matt'
    OR 입사일자 = '1987-03-31';
	
* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | I_입사일자    | NULL | NULL    | NULL | 299157 |    10.02 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
select count(1) from 사원;

* 결과
+----------+
| count(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.37 sec)

====================================================================================
* SQL
select count(1) from 사원 where 이름='Matt';

* 결과
+----------+
| count(1) |
+----------+
|      233 |
+----------+
1 row in set (0.16 sec)

====================================================================================

* SQL
select count(1) from 사원 where 입사일자='1987-03-31';

* 결과
+----------+
| count(1) |
+----------+
|      111 |
+----------+
1 row in set (0.00 sec)

====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)

====================================================================================
* SQL
ALTER TABLE 사원
ADD INDEX I_이름(이름);

* 결과
Query OK, 0 rows affected (1.16 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
* SQL
SELECT *
  FROM 사원
 WHERE 이름 = 'Matt'
    OR 입사일자 = '1987-03-31';

* 결과
+----------+------------+-------------+-----------------+------+------------+
| 사원번호 | 생년월일   | 이름        | 성              | 성별 | 입사일자   |
+----------+------------+-------------+-----------------+------+------------+
|    10083 | 1959-07-23 | Vishv       | Zockler         | M    | 1987-03-31 |
|    10690 | 1962-09-06 | Matt        | Jumpertz        | F    | 1989-08-22 |
|    12302 | 1962-02-14 | Matt        | Plessier        | M    | 1987-01-28 |
... 중략 ...
|   495781 | 1960-10-06 | Georg       | Velasco         | M    | 1987-03-31 |
|   497243 | 1962-10-13 | Jianwen     | Kalsbeek        | M    | 1987-03-31 |
|   497766 | 1960-09-25 | Matt        | Atrawala        | F    | 1987-02-11 |
+----------+------------+-------------+-----------------+------+------------+
343 rows in set (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT *
  FROM 사원
 WHERE 이름 = 'Matt'
    OR 입사일자 = '1987-03-31';
	
* 결과
+----+-------------+-------+------------+-------------+-------------------+-------------------+---------+------+------+----------+---------------------------------------------+
| id | select_type | table | partitions | type        | possible_keys     | key               | key_len | ref  | rows | filtered | Extra                                       |
+----+-------------+-------+------------+-------------+-------------------+-------------------+---------+------+------+----------+---------------------------------------------+
|  1 | SIMPLE      | 사원  | NULL       | index_merge | I_입사일자,I_이름 | I_이름,I_입사일자 | 44,3    | NULL |  344 |   100.00 | Using union(I_이름,I_입사일자); Using where |
+----+-------------+-------+------------+-------------+-------------------+-------------------+---------+------+------+----------+---------------------------------------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
ALTER TABLE 사원
DROP INDEX I_이름;

* 결과
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
== 5.2.3. ==========================================================================
====================================================================================
* SQL
select @@autocommit;

* 결과
+--------------+
| @@autocommit |
+--------------+
|            1 |
+--------------+
1 row in set (0.00 sec)

====================================================================================
* SQL
set autocommit=0;

* 결과
Query OK, 0 rows affected (0.00 sec)

====================================================================================
* SQL
select @@autocommit;

* 결과
+--------------+
| @@autocommit |
+--------------+
|            0 |
+--------------+
1 row in set (0.00 sec)

====================================================================================
* SQL
UPDATE 사원출입기록
SET 출입문 = 'X'
WHERE 출입문 = 'B';

* 결과	
Query OK, 300000 rows affected (34.13 sec)
Rows matched: 300000  Changed: 300000  Warnings: 0

====================================================================================
* SQL
rollback;

* 결과
Query OK, 0 rows affected (17.52 sec)

====================================================================================
* SQL
EXPLAIN
UPDATE 사원출입기록
SET 출입문 = 'X'
WHERE 출입문 = 'B';

* 결과
+----+-------------+--------------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
| id | select_type | table        | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+--------------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
|  1 | UPDATE      | 사원출입기록 | NULL       | index | I_출입문      | PRIMARY | 8       | NULL | 658935 |   100.00 | Using where |
+----+-------------+--------------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.02 sec)
====================================================================================
* SQL
show index from 사원출입기록;

* 결과
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table        | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원출입기록 |          0 | PRIMARY  |            1 | 순번        | A         |      658935 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          0 | PRIMARY  |            2 | 사원번호    | A         |      658935 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_지역   |            1 | 지역        | A         |           4 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_시간   |            1 | 입출입시간  | A         |      652638 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_출입문 |            1 | 출입문      | A         |           3 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
5 rows in set (0.00 sec)
====================================================================================
* SQL
ALTER TABLE 사원출입기록
DROP INDEX I_출입문;

* 결과
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
* SQL
show index from 사원출입기록;

* 결과
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table        | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원출입기록 |          0 | PRIMARY  |            1 | 순번        | A         |      658935 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          0 | PRIMARY  |            2 | 사원번호    | A         |      658935 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_지역   |            1 | 지역        | A         |           4 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| 사원출입기록 |          1 | I_시간   |            1 | 입출입시간  | A         |      652638 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+--------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)

====================================================================================
* SQL
SELECT @@autocommit;

* 결과
+--------------+
| @@autocommit |
+--------------+
|            0 |
+--------------+
1 row in set (0.00 sec)
====================================================================================
* SQL
UPDATE 사원출입기록
SET 출입문 = 'X'
WHERE 출입문 = 'B';

* 결과
Query OK, 300000 rows affected (3.82 sec)
Rows matched: 300000  Changed: 300000  Warnings: 0

====================================================================================
* SQL
rollback;

* 결과
Query OK, 0 rows affected (4.08 sec)

====================================================================================
* SQL
EXPLAIN
UPDATE 사원출입기록
SET 출입문 = 'X'
WHERE 출입문 = 'B';

* 결과
+----+-------------+--------------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
| id | select_type | table        | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+--------------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
|  1 | UPDATE      | 사원출입기록 | NULL       | index | I_출입문      | PRIMARY | 8       | NULL | 658935 |   100.00 | Using where |
+----+-------------+--------------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
ALTER TABLE 사원출입기록
ADD INDEX I_출입문(출입문);

* 결과
Query OK, 0 rows affected (1.94 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================

* SQL
set autocommit=1;

* 결과
Query OK, 0 rows affected (0.00 sec)

====================================================================================

* SQL
select @@autocommit;

* 결과
+--------------+
| @@autocommit |
+--------------+
|            1 |
+--------------+
1 row in set (0.00 sec)

====================================================================================
== 5.2.4. ==========================================================================
====================================================================================
* SQL
SELECT 사원번호, 이름, 성
  FROM 사원
 WHERE 성별 = 'M'
   AND 성 = 'Baba';

* 결과
+----------+----------------+------+
| 사원번호 | 이름           | 성   |
+----------+----------------+------+
|    11937 | Zissis         | Baba |
|    12245 | Christ         | Baba |
|    15596 | Bedir          | Baba |
... 중략 ...
|   492391 | Alenka         | Baba |
|   494271 | Zsolt          | Baba |
|   499900 | Leon           | Baba |
+----------+----------------+------+
135 rows in set (0.04 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 사원번호, 이름, 성
  FROM 사원
 WHERE 성별 = 'M'
   AND 성 = 'Baba';

* 결과
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key       | key_len | ref         | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | ref  | I_성별_성     | I_성별_성 | 51      | const,const |  135 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
SELECT COUNT(DISTINCT 성) 성_개수, COUNT(DISTINCT 성별) 성별_개수  
FROM 사원 ;

* 결과
+---------+-----------+
| 성_개수 | 성별_개수 |
+---------+-----------+
|    1637 |         2 |
+---------+-----------+
1 row in set (0.23 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
ALTER TABLE 사원
DROP INDEX I_성별_성,
ADD INDEX I_성_성별(성, 성별);

* 결과
Query OK, 0 rows affected (2.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
* SQL
SELECT 사원번호, 이름, 성
FROM 사원
WHERE 성별 = 'M'
AND 성 = 'Baba';

* 결과
+----------+----------------+------+
| 사원번호 | 이름           | 성   |
+----------+----------------+------+
|    11937 | Zissis         | Baba |
|    12245 | Christ         | Baba |
|    15596 | Bedir          | Baba |
... 중략 ...
|   492391 | Alenka         | Baba |
|   494271 | Zsolt          | Baba |
|   499900 | Leon           | Baba |
+----------+----------------+------+
135 rows in set (0.00 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 사원번호, 이름, 성
FROM 사원
WHERE 성별 = 'M'
AND 성 = 'Baba';

* 결과
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key       | key_len | ref         | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
|  1 | SIMPLE      | 사원  | NULL       | ref  | I_성_성별     | I_성_성별 | 51      | const,const |  135 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+-----------+---------+-------------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
====================================================================================
* SQL
ALTER TABLE 사원
DROP INDEX I_성_성별,
ADD INDEX I_성별_성(성별, 성);

* 결과
Query OK, 0 rows affected (1.37 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
== 5.3.1. ==========================================================================
====================================================================================
* SQL
SELECT 부서명, 비고
  FROM 부서
 WHERE 비고 = 'active'
   AND ASCII(SUBSTR(비고,1,1)) = 97
   AND ASCII(SUBSTR(비고,2,1)) = 99;

* 결과
+------------------+--------+
| 부서명           | 비고   |
+------------------+--------+
| Human Resources  | active |
| Production       | active |
| Sales            | active |
| Customer Service | active |
+------------------+--------+
4 rows in set (0.00 sec)

====================================================================================
* SQL
SELECT 부서명, 비고
FROM 부서
WHERE 비고 = 'active';

* 결과
+------------------+--------+
| 부서명           | 비고   |
+------------------+--------+
| Marketing        | aCTIVE |
| Finance          | ACTIVE |
| Human Resources  | active |
| Production       | active |
| Development      | Active |
| Sales            | active |
| Customer Service | active |
+------------------+--------+
7 rows in set (0.00 sec)
====================================================================================
* SQL
SELECT 비고, 
       SUBSTR(비고,1,1) 첫번째, 
       ASCII(SUBSTR(비고,1,1)) 첫번째_아스키, 
	   SUBSTR(비고,2,1) 두번째,
       ASCII(SUBSTR(비고,2,1)) 두번째_아스키
FROM 부서
WHERE 비고 = 'active';

* 결과
+--------+--------+---------------+--------+---------------+
| 비고   | 첫번째 | 첫번째_아스키 | 두번째 | 두번째_아스키 |
+--------+--------+---------------+--------+---------------+
| aCTIVE | a      |            97 | C      |            67 |
| ACTIVE | A      |            65 | C      |            67 |
| active | a      |            97 | c      |            99 |
| active | a      |            97 | c      |            99 |
| Active | A      |            65 | c      |            99 |
| active | a      |            97 | c      |            99 |
| active | a      |            97 | c      |            99 |
+--------+--------+---------------+--------+---------------+
7 rows in set (0.00 sec)
====================================================================================
* SQL
SELECT COLUMN_NAME, collation_name
FROM information_schema.COLUMNS
WHERE table_schema = 'tuning'
AND TABLE_NAME = '부서';

* 결과
+-------------+-----------------+
| COLUMN_NAME | COLLATION_NAME  |
+-------------+-----------------+
| 부서번호    | utf8_general_ci |
| 부서명      | utf8_general_ci |
| 비고        | utf8_general_ci |
+-------------+-----------------+
3 rows in set (0.01 sec)
====================================================================================
* SQL
ALTER TABLE 부서
CHANGE COLUMN 비고 비고 VARCHAR(40) NULL DEFAULT NULL COLLATE 'UTF8MB4_bin';

* 결과
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
* SQL
SELECT COLUMN_NAME, collation_name
FROM information_schema.COLUMNS
WHERE table_schema = 'tuning'
AND TABLE_NAME = '부서';

* 결과
+-------------+-----------------+
| COLUMN_NAME | COLLATION_NAME  |
+-------------+-----------------+
| 부서번호    | utf8_general_ci |
| 부서명      | utf8_general_ci |
| 비고        | utf8mb4_bin     |
+-------------+-----------------+
3 rows in set (0.01 sec)

====================================================================================
* SQL
SELECT 부서명, 비고
FROM 부서
WHERE 비고 = 'active';

* 결과
+------------------+--------+
| 부서명           | 비고   |
+------------------+--------+
| Human Resources  | active |
| Production       | active |
| Sales            | active |
| Customer Service | active |
+------------------+--------+
4 rows in set (0.00 sec)

====================================================================================
* SQL
ALTER TABLE 부서
CHANGE COLUMN 비고 비고 VARCHAR(40) NULL DEFAULT NULL COLLATE 'utf8_general_ci';

* 결과
Query OK, 9 rows affected, 1 warning (0.05 sec)
Records: 9  Duplicates: 0  Warnings: 1

====================================================================================
== 5.3.2. ==========================================================================
====================================================================================
* SQL
SELECT 이름, 성, 성별, 생년월일
FROM 사원
WHERE LOWER(이름) = LOWER('MARY')
AND 입사일자 >= STR_TO_DATE('1990-01-01', '%Y-%m-%d');

* 결과
+------+----------------+------+------------+
| 이름 | 성             | 성별 | 생년월일   |
+------+----------------+------+------------+
| Mary | Sluis          | F    | 1953-11-07 |
| Mary | Piazza         | F    | 1954-10-18 |
| Mary | Ertl           | F    | 1962-03-08 |
| Mary | Monarch        | F    | 1956-08-14 |
| Mary | DasSarma       | F    | 1955-05-23 |
| Mary | Ananiadou      | F    | 1964-06-04 |
| Mary | Ritcey         | M    | 1955-12-28 |
| Mary | Schapire       | M    | 1956-04-29 |
| Mary | Demian         | M    | 1961-11-05 |
| Mary | Lanzelotte     | M    | 1954-06-16 |
| Mary | Fujisawa       | F    | 1959-03-27 |
| Mary | Monarch        | F    | 1955-10-27 |
| Mary | Srimani        | M    | 1961-03-13 |
| Mary | Itzfeldt       | F    | 1953-11-06 |
| Mary | Babu           | F    | 1963-08-31 |
| Mary | Glinert        | F    | 1959-02-14 |
| Mary | Hofmeyr        | F    | 1952-10-06 |
| Mary | Milicic        | M    | 1963-12-13 |
| Mary | Hiroyama       | M    | 1952-11-29 |
| Mary | Lindenbaum     | F    | 1964-01-01 |
| Mary | Kalafatis      | F    | 1953-02-15 |
| Mary | Perz           | F    | 1955-07-25 |
| Mary | Nishimukai     | M    | 1960-11-01 |
| Mary | Ananiadou      | M    | 1963-10-06 |
| Mary | Holburn        | M    | 1955-01-22 |
| Mary | Pelz           | M    | 1954-12-17 |
| Mary | Hammerschmidt  | M    | 1952-05-19 |
| Mary | Gruenwald      | M    | 1957-01-14 |
| Mary | Siochi         | M    | 1962-10-05 |
| Mary | Kalefeld       | F    | 1960-07-02 |
| Mary | Chimia         | M    | 1952-02-03 |
| Mary | Ghalwash       | M    | 1963-09-11 |
| Mary | Puoti          | F    | 1954-05-04 |
| Mary | Ulupinar       | M    | 1959-03-30 |
| Mary | Gente          | F    | 1958-02-18 |
| Mary | Hasenauer      | M    | 1952-10-17 |
| Mary | Mitsuhashi     | M    | 1957-03-06 |
| Mary | Billingsley    | F    | 1955-12-01 |
| Mary | Hofman         | M    | 1962-08-11 |
| Mary | Lorch          | F    | 1957-01-28 |
| Mary | Danecki        | M    | 1952-02-10 |
| Mary | Molenkamp      | M    | 1955-10-10 |
| Mary | DasSarma       | M    | 1958-12-18 |
| Mary | Thiria         | M    | 1962-05-13 |
| Mary | Axelband       | M    | 1956-10-26 |
| Mary | Uhrik          | M    | 1955-12-02 |
| Mary | Bugaenko       | M    | 1955-08-19 |
| Mary | Shihab         | M    | 1963-01-29 |
| Mary | Yoshizawa      | M    | 1955-05-11 |
| Mary | Krichel        | M    | 1952-06-24 |
| Mary | Peha           | M    | 1962-03-09 |
| Mary | Czaja          | F    | 1955-06-29 |
| Mary | Katalagarianos | M    | 1960-07-01 |
| Mary | Heyers         | M    | 1952-05-27 |
| Mary | Schlegelmilch  | M    | 1953-02-24 |
| Mary | Wuwongse       | M    | 1964-08-09 |
| Mary | Servieres      | M    | 1963-03-24 |
| Mary | Perna          | F    | 1954-12-07 |
| Mary | Busillo        | M    | 1963-03-26 |
| Mary | Cronau         | F    | 1957-02-09 |
| Mary | Comellas       | M    | 1959-01-07 |
| Mary | Braunschweig   | M    | 1955-05-29 |
| Mary | Kampfer        | F    | 1956-03-10 |
| Mary | Carrere        | F    | 1964-06-07 |
| Mary | Ratnaker       | M    | 1953-10-19 |
| Mary | Gils           | M    | 1953-08-29 |
| Mary | Mitchem        | M    | 1953-03-03 |
| Mary | Pietrzykowski  | M    | 1961-10-06 |
| Mary | Tokunaga       | F    | 1960-06-24 |
| Mary | Stavenow       | F    | 1964-03-23 |
| Mary | Burnard        | F    | 1953-03-20 |
| Mary | Lamparter      | F    | 1953-02-27 |
| Mary | Speek          | M    | 1953-12-04 |
| Mary | Edelhoff       | M    | 1952-03-12 |
| Mary | Assaf          | F    | 1953-11-02 |
| Mary | Casley         | M    | 1961-08-28 |
| Mary | Bahk           | F    | 1952-08-29 |
| Mary | Schrooten      | M    | 1957-08-30 |
| Mary | Kornyak        | F    | 1957-10-03 |
| Mary | Jansen         | M    | 1961-03-26 |
| Mary | Weedman        | M    | 1959-07-15 |
| Mary | Cronin         | F    | 1953-11-17 |
| Mary | Kampfer        | M    | 1957-06-16 |
| Mary | Mitsuhashi     | M    | 1962-01-20 |
| Mary | Conti          | M    | 1962-02-27 |
| Mary | Staudhammer    | M    | 1960-08-06 |
| Mary | Keohane        | M    | 1952-12-29 |
| Mary | Kumaresan      | M    | 1958-02-24 |
| Mary | Mahmud         | M    | 1960-07-03 |
| Mary | Facello        | M    | 1953-10-11 |
| Mary | Birrer         | M    | 1964-05-16 |
| Mary | Nyanchama      | M    | 1956-05-15 |
| Mary | Baba           | F    | 1958-06-25 |
| Mary | Swift          | M    | 1957-05-29 |
| Mary | Showalter      | M    | 1953-01-05 |
| Mary | Tiemann        | M    | 1954-10-05 |
+------+----------------+------+------------+
96 rows in set (0.18 sec)
====================================================================================
* SQL
EXPLAIN
SELECT 이름, 성, 성별, 생년월일
FROM 사원
WHERE LOWER(이름) = LOWER('MARY')
AND 입사일자 >= STR_TO_DATE('1990-01-01', '%Y-%m-%d');

* 결과
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | ALL  | I_입사일자    | NULL | NULL    | NULL | 299157 |    50.00 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.01 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 사원;

* 결과
+----------+
| COUNT(1) |
+----------+
|   300024 |
+----------+
1 row in set (2.37 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 사원
WHERE 입사일자 >= STR_TO_DATE('1990-01-01', '%Y-%m-%d');

* 결과
+----------+
| COUNT(1) |
+----------+
|   135227 |
+----------+
1 row in set (0.04 sec)
====================================================================================
* SQL
SELECT COUNT(1)
FROM 사원
WHERE LOWER(이름) = LOWER('MARY');

* 결과
+----------+
| COUNT(1) |
+----------+
|      224 |
+----------+
1 row in set (0.09 sec)
====================================================================================
* SQL
show index from 사원;

* 결과
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| 사원  |          0 | PRIMARY    |            1 | 사원번호    | A         |      299157 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_입사일자 |            1 | 입사일자    | A         |        4612 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            1 | 성별        | A         |           1 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| 사원  |          1 | I_성별_성  |            2 | 성          | A         |        3257 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)
====================================================================================
* SQL
SELECT *
FROM 사원
WHERE 이름 = 'MARY';

* 결과
Empty set (0.32 sec)

====================================================================================
* SQL
SELECT COLUMN_NAME, collation_name
FROM information_schema.columns
WHERE TABLE_NAME='사원'
AND table_schema='tuning';

* 결과
+-------------+-----------------+
| COLUMN_NAME | COLLATION_NAME  |
+-------------+-----------------+
| 사원번호    | NULL            |
| 생년월일    | NULL            |
| 이름        | utf8_bin        |
| 성          | utf8_general_ci |
| 성별        | utf8_general_ci |
| 입사일자    | NULL            |
+-------------+-----------------+
6 rows in set (0.00 sec)

====================================================================================
* SQL
ALTER TABLE 사원 ADD COLUMN 소문자_이름 VARCHAR(14) NOT NULL AFTER 이름;
* 결과
Query OK, 0 rows affected (3.47 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================

* SQL
UPDATE 사원
SET 소문자_이름 = LOWER(이름);

* 결과
Query OK, 300024 rows affected (13.96 sec)
Rows matched: 300024  Changed: 300024  Warnings: 0

====================================================================================

* SQL
ALTER TABLE 사원 ADD INDEX I_소문자이름(소문자_이름);

* 결과
Query OK, 0 rows affected (1.08 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
* SQL
desc 사원;

* 결과
+-------------+---------------+------+-----+---------+-------+
| Field       | Type          | Null | Key | Default | Extra |
+-------------+---------------+------+-----+---------+-------+
| 사원번호    | int           | NO   | PRI | NULL    |       |
| 생년월일    | date          | NO   |     | NULL    |       |
| 이름        | varchar(14)   | NO   |     | NULL    |       |
| 소문자_이름 | varchar(14)   | NO   | MUL | NULL    |       |
| 성          | varchar(16)   | NO   |     | NULL    |       |
| 성별        | enum('M','F') | NO   | MUL | NULL    |       |
| 입사일자    | date          | NO   | MUL | NULL    |       |
+-------------+---------------+------+-----+---------+-------+
7 rows in set (0.01 sec)

====================================================================================
* SQL
SELECT 이름, 소문자_이름
FROM 사원
LIMIT 10;

* 결과
+-----------+-------------+
| 이름      | 소문자_이름 |
+-----------+-------------+
| Georgi    | georgi      |
| Bezalel   | bezalel     |
| ParTo     | parto       |
| Chirstian | chirstian   |
| Kyoichi   | kyoichi     |
| AnneKe    | anneke      |
| Tzvetan   | tzvetan     |
| Saniya    | saniya      |
| Sumant    | sumant      |
| Duangkaew | duangkaew   |
+-----------+-------------+
10 rows in set (0.00 sec)

====================================================================================
* SQL
SELECT 이름, 성, 성별, 생년월일
FROM 사원
WHERE 소문자_이름= 'MARY'
AND 입사일자 >= '1990-01-01';

* 결과
+------+----------------+------+------------+
| 이름 | 성             | 성별 | 생년월일   |
+------+----------------+------+------------+
| Mary | Sluis          | F    | 1953-11-07 |
| Mary | Piazza         | F    | 1954-10-18 |
| Mary | Ertl           | F    | 1962-03-08 |
| Mary | Monarch        | F    | 1956-08-14 |
| Mary | DasSarma       | F    | 1955-05-23 |
| Mary | Ananiadou      | F    | 1964-06-04 |
| Mary | Ritcey         | M    | 1955-12-28 |
| Mary | Schapire       | M    | 1956-04-29 |
| Mary | Demian         | M    | 1961-11-05 |
| Mary | Lanzelotte     | M    | 1954-06-16 |
| Mary | Fujisawa       | F    | 1959-03-27 |
| Mary | Monarch        | F    | 1955-10-27 |
| Mary | Srimani        | M    | 1961-03-13 |
| Mary | Itzfeldt       | F    | 1953-11-06 |
| Mary | Babu           | F    | 1963-08-31 |
| Mary | Glinert        | F    | 1959-02-14 |
| Mary | Hofmeyr        | F    | 1952-10-06 |
| Mary | Milicic        | M    | 1963-12-13 |
| Mary | Hiroyama       | M    | 1952-11-29 |
| Mary | Lindenbaum     | F    | 1964-01-01 |
| Mary | Kalafatis      | F    | 1953-02-15 |
| Mary | Perz           | F    | 1955-07-25 |
| Mary | Nishimukai     | M    | 1960-11-01 |
| Mary | Ananiadou      | M    | 1963-10-06 |
| Mary | Holburn        | M    | 1955-01-22 |
| Mary | Pelz           | M    | 1954-12-17 |
| Mary | Hammerschmidt  | M    | 1952-05-19 |
| Mary | Gruenwald      | M    | 1957-01-14 |
| Mary | Siochi         | M    | 1962-10-05 |
| Mary | Kalefeld       | F    | 1960-07-02 |
| Mary | Chimia         | M    | 1952-02-03 |
| Mary | Ghalwash       | M    | 1963-09-11 |
| Mary | Puoti          | F    | 1954-05-04 |
| Mary | Ulupinar       | M    | 1959-03-30 |
| Mary | Gente          | F    | 1958-02-18 |
| Mary | Hasenauer      | M    | 1952-10-17 |
| Mary | Mitsuhashi     | M    | 1957-03-06 |
| Mary | Billingsley    | F    | 1955-12-01 |
| Mary | Hofman         | M    | 1962-08-11 |
| Mary | Lorch          | F    | 1957-01-28 |
| Mary | Danecki        | M    | 1952-02-10 |
| Mary | Molenkamp      | M    | 1955-10-10 |
| Mary | DasSarma       | M    | 1958-12-18 |
| Mary | Thiria         | M    | 1962-05-13 |
| Mary | Axelband       | M    | 1956-10-26 |
| Mary | Uhrik          | M    | 1955-12-02 |
| Mary | Bugaenko       | M    | 1955-08-19 |
| Mary | Shihab         | M    | 1963-01-29 |
| Mary | Yoshizawa      | M    | 1955-05-11 |
| Mary | Krichel        | M    | 1952-06-24 |
| Mary | Peha           | M    | 1962-03-09 |
| Mary | Czaja          | F    | 1955-06-29 |
| Mary | Katalagarianos | M    | 1960-07-01 |
| Mary | Heyers         | M    | 1952-05-27 |
| Mary | Schlegelmilch  | M    | 1953-02-24 |
| Mary | Wuwongse       | M    | 1964-08-09 |
| Mary | Servieres      | M    | 1963-03-24 |
| Mary | Perna          | F    | 1954-12-07 |
| Mary | Busillo        | M    | 1963-03-26 |
| Mary | Cronau         | F    | 1957-02-09 |
| Mary | Comellas       | M    | 1959-01-07 |
| Mary | Braunschweig   | M    | 1955-05-29 |
| Mary | Kampfer        | F    | 1956-03-10 |
| Mary | Carrere        | F    | 1964-06-07 |
| Mary | Ratnaker       | M    | 1953-10-19 |
| Mary | Gils           | M    | 1953-08-29 |
| Mary | Mitchem        | M    | 1953-03-03 |
| Mary | Pietrzykowski  | M    | 1961-10-06 |
| Mary | Tokunaga       | F    | 1960-06-24 |
| Mary | Stavenow       | F    | 1964-03-23 |
| Mary | Burnard        | F    | 1953-03-20 |
| Mary | Lamparter      | F    | 1953-02-27 |
| Mary | Speek          | M    | 1953-12-04 |
| Mary | Edelhoff       | M    | 1952-03-12 |
| Mary | Assaf          | F    | 1953-11-02 |
| Mary | Casley         | M    | 1961-08-28 |
| Mary | Bahk           | F    | 1952-08-29 |
| Mary | Schrooten      | M    | 1957-08-30 |
| Mary | Kornyak        | F    | 1957-10-03 |
| Mary | Jansen         | M    | 1961-03-26 |
| Mary | Weedman        | M    | 1959-07-15 |
| Mary | Cronin         | F    | 1953-11-17 |
| Mary | Kampfer        | M    | 1957-06-16 |
| Mary | Mitsuhashi     | M    | 1962-01-20 |
| Mary | Conti          | M    | 1962-02-27 |
| Mary | Staudhammer    | M    | 1960-08-06 |
| Mary | Keohane        | M    | 1952-12-29 |
| Mary | Kumaresan      | M    | 1958-02-24 |
| Mary | Mahmud         | M    | 1960-07-03 |
| Mary | Facello        | M    | 1953-10-11 |
| Mary | Birrer         | M    | 1964-05-16 |
| Mary | Nyanchama      | M    | 1956-05-15 |
| Mary | Baba           | F    | 1958-06-25 |
| Mary | Swift          | M    | 1957-05-29 |
| Mary | Showalter      | M    | 1953-01-05 |
| Mary | Tiemann        | M    | 1954-10-05 |
+------+----------------+------+------------+
96 rows in set (0.00 sec)

====================================================================================
* SQL
EXPLAIN
SELECT 이름, 성, 성별, 생년월일
FROM 사원
WHERE 소문자_이름= 'MARY'
AND 입사일자 >= '1990-01-01';

* 결과
+----+-------------+-------+------------+------+-------------------------+--------------+---------+-------+------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys           | key          | key_len | ref   | rows | filtered | Extra       |
+----+-------------+-------+------------+------+-------------------------+--------------+---------+-------+------+----------+-------------+
|  1 | SIMPLE      | 사원  | NULL       | ref  | I_입사일자,I_소문자이름 | I_소문자이름 | 44      | const |  224 |    50.00 | Using where |
+----+-------------+-------+------------+------+-------------------------+--------------+---------+-------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
ALTER TABLE 사원 DROP COLUMN 소문자_이름;

* 결과
Query OK, 0 rows affected (3.99 sec)
Records: 0  Duplicates: 0  Warnings: 0

====================================================================================
* SQL
mysql> desc 사원;

* 결과
+----------+---------------+------+-----+---------+-------+
| Field    | Type          | Null | Key | Default | Extra |
+----------+---------------+------+-----+---------+-------+
| 사원번호 | int           | NO   | PRI | NULL    |       |
| 생년월일 | date          | NO   |     | NULL    |       |
| 이름     | varchar(14)   | NO   |     | NULL    |       |
| 성       | varchar(16)   | NO   |     | NULL    |       |
| 성별     | enum('M','F') | NO   | MUL | NULL    |       |
| 입사일자 | date          | NO   | MUL | NULL    |       |
+----------+---------------+------+-----+---------+-------+
6 rows in set (0.01 sec)


====================================================================================
== 5.3.3. ==========================================================================
====================================================================================
* SQL
SELECT COUNT(1)
  FROM 급여
  WHERE 시작일자 BETWEEN STR_TO_DATE('2000-01-01', '%Y-%m-%d')
                     AND STR_TO_DATE('2000-12-31', '%Y-%m-%d');

* 결과
+----------+
| COUNT(1) |
+----------+
|   255785 |
+----------+
1 row in set (1.23 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(1)
FROM 급여
WHERE 시작일자 BETWEEN STR_TO_DATE('2000-01-01', '%Y-%m-%d') 
AND STR_TO_DATE('2000-12-31', '%Y-%m-%d');
					
* 결과
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+---------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys      | key        | key_len | ref  | rows    | filtered | Extra                    |
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+---------+----------+--------------------------+
|  1 | SIMPLE      | 급여  | NULL       | index | PRIMARY,I_사용여부 | I_사용여부 | 4       | NULL | 2838731 |    11.11 | Using where; Using index |
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+---------+----------+--------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
SELECT COUNT(1)
FROM 급여;

* 결과
+----------+
| COUNT(1) |
+----------+
|  2844047 |
+----------+
1 row in set (3.76 sec)

====================================================================================
* SQL
SELECT YEAR(시작일자), COUNT(1)
FROM 급여
GROUP BY YEAR(시작일자);

* 결과
+----------------+----------+
| YEAR(시작일자) | COUNT(1) |
+----------------+----------+
|           1986 |    37957 |
|           1987 |    57440 |
|           1988 |    76896 |
|           1989 |    95957 |
|           1990 |   114561 |
|           1991 |   132624 |
|           1992 |   151072 |
|           1993 |   168139 |
|           1994 |   185159 |
|           1995 |   201637 |
|           1996 |   218309 |
|           1997 |   233190 |
|           1998 |   247489 |
|           1999 |   260957 |
|           2000 |   255785 |
|           2001 |   247652 |
|           1985 |    18293 |
|           2002 |   140930 |
+----------------+----------+
18 rows in set (1.45 sec)

====================================================================================
* SQL
ALTER TABLE 급여
partition by range COLUMNS (시작일자)
(
    partition p85 values less than ('1985-12-31'),
    partition p86 values less than ('1986-12-31'),
    partition p87 values less than ('1987-12-31'),
    partition p88 values less than ('1988-12-31'),
    partition p89 values less than ('1989-12-31'),
    partition p90 values less than ('1990-12-31'),
    partition p91 values less than ('1991-12-31'),
    partition p92 values less than ('1992-12-31'),
    partition p93 values less than ('1993-12-31'),
    partition p94 values less than ('1994-12-31'),
    partition p95 values less than ('1995-12-31'),
    partition p96 values less than ('1996-12-31'),
    partition p97 values less than ('1997-12-31'),
    partition p98 values less than ('1998-12-31'),
    partition p99 values less than ('1999-12-31'),
    partition p00 values less than ('2000-12-31'),
    partition p01 values less than ('2001-12-31'),
    partition p02 values less than ('2002-12-31'),
    partition p03 values less than (MAXVALUE)
);

* 결과
Query OK, 2844047 rows affected (23.66 sec)
Records: 2844047  Duplicates: 0  Warnings: 0

====================================================================================
* SQL
SELECT COUNT(1)
FROM 급여
WHERE 시작일자 BETWEEN STR_TO_DATE('2000-01-01', '%Y-%m-%d')
AND STR_TO_DATE('2000-12-31', '%Y-%m-%d');

* 결과
+----------+
| COUNT(1) |
+----------+
|   255785 |
+----------+
1 row in set (0.19 sec)

====================================================================================
* SQL
EXPLAIN
SELECT COUNT(1)
FROM 급여
WHERE 시작일자 BETWEEN STR_TO_DATE('2000-01-01', '%Y-%m-%d')
AND STR_TO_DATE('2000-12-31', '%Y-%m-%d');

* 결과
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+--------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys      | key        | key_len | ref  | rows   | filtered | Extra                    |
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+--------+----------+--------------------------+
|  1 | SIMPLE      | 급여  | p00,p01    | index | PRIMARY,I_사용여부 | I_사용여부 | 4       | NULL | 503433 |    11.11 | Using where; Using index |
+----+-------------+-------+------------+-------+--------------------+------------+---------+------+--------+----------+--------------------------+
1 row in set, 1 warning (0.00 sec)

====================================================================================
* SQL
ALTER TABLE 급여 REMOVE PARTITIONING;

* 결과
Query OK, 2844047 rows affected (2 min 8.77 sec)
Records: 2844047  Duplicates: 0  Warnings: 0