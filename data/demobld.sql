--
-- Copyright (c) Oracle Corporation 1988, 1999.  All Rights Reserved.
--
--  NAME
--    demobld.sql
--
-- DESCRIPTION
--   This script creates the SQL*Plus demonstration tables in the
--   current schema.  It should be STARTed by each user wishing to
--   access the tables.  To remove the tables use the demodrop.sql
--   script.
--
--  USAGE
--       SQL> START demobld.sql
--
--
-- drop database if exists mydb;
-- 새로 만들어라 
-- CREATE DATABASE IF NOT EXISTS mydb;
use mydb;

CREATE TABLE BONUS
        (ENAME nvarchar(10),
         JOB   nvarchar(9),
         SAL   int,
         COMM  int);

CREATE TABLE EMP
       (EMPNO int(4) NOT NULL,
        ENAME nvarchar(10),
        JOB nvarchar(9),
        MGR int(4),
        HIREDATE DATE,
        SAL decimal(7, 2),
        COMM decimal(7, 2),
        DEPTNO int(2),
				gender char(1));

INSERT INTO EMP VALUES
        (7369, 'SMITH',  'CLERK',     7902,
        '1980-12-17',  800, NULL, 20, 'M');
INSERT INTO EMP VALUES
        (7499, 'ALLEN',  'SALESMAN',  7698,
        '1981-02-20', 1600,  300, 30, 'M');
INSERT INTO EMP VALUES
        (7521, 'WARD',   'SALESMAN',  7698,
        '1981-02-22', 1250,  500, 30, 'M');
INSERT INTO EMP VALUES
        (7566, 'JONES',  'MANAGER',   7839,
        '1981-04-02',  2975, NULL, 20, 'M');
INSERT INTO EMP VALUES
        (7654, 'MARTIN', 'SALESMAN',  7698,
        '1981-08-28', 1250, 1400, 30, 'M');
INSERT INTO EMP VALUES
        (7698, 'BLAKE',  'MANAGER',   7839,
        '1981-05-01',  2850, NULL, 30, 'M');
INSERT INTO EMP VALUES
        (7782, 'CLARK',  'MANAGER',   7839,
        '1981-06-09',  2450, NULL, 10, 'M');
INSERT INTO EMP VALUES
        (7788, 'SCOTT',  'ANALYST',   7566,
        '1982-10-09', 3000, NULL, 20, 'M');
INSERT INTO EMP VALUES
        (7839, 'KING',   'PRESIDENT', NULL,
        '1981-11-17', 5000, NULL, 10, 'M');
INSERT INTO EMP VALUES
        (7844, 'TURNER', 'SALESMAN',  7698,
        '1981-8-8',  1500, NULL, 30, 'M');
INSERT INTO EMP VALUES
        (7876, 'ADAMS',  'CLERK',     7788,
        '1983-1-12', 1100, NULL, 20, 'M');
INSERT INTO EMP VALUES
        (7900, 'JAMES',  'CLERK',     7698,
        '1981-10-3',   950, NULL, 30, 'M');
INSERT INTO EMP VALUES
        (7902, 'FORD',   'ANALYST',   7566,
        '1981-10-3',  3000, NULL, 20, 'M');
INSERT INTO EMP VALUES
        (7934, 'MILLER', 'CLERK',     7782,
        '1982-1-23', 1300, NULL, 10, 'M');

CREATE TABLE DEPT
       (DEPTNO int(2),
        DNAME nvarchar(14),
        LOC nvarchar(13) );

INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO DEPT VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO DEPT VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO DEPT VALUES (40, 'OPERATIONS', 'BOSTON');

CREATE TABLE SALGRADE
        (GRADE int,
         LOSAL int,
         HISAL int);

INSERT INTO SALGRADE VALUES (1,  700, 1200);
INSERT INTO SALGRADE VALUES (2, 1201, 1400);
INSERT INTO SALGRADE VALUES (3, 1401, 2000);
INSERT INTO SALGRADE VALUES (4, 2001, 3000);
INSERT INTO SALGRADE VALUES (5, 3001, 9999);

