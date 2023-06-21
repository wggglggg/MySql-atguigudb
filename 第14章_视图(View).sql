#第14章_视图(View)

/*
1. 视图的理解

① 视图，可以看做是一个虚拟表，本身是不存储数据的。
  视图的本质，就可以看做是存储起来的SELECT语句
  
② 视图中SELECT语句中涉及到的表，称为基表

③ 针对视图做DML操作，会影响到对应的基表中的数据。反之亦然。

④ 视图本身的删除，不会导致基表中数据的删除。

⑤ 视图的应用场景：针对于小型项目，不推荐使用视图。针对于大型项目，可以考虑使用视图。

⑥ 视图的优点：简化查询; 控制数据的访问


*/

#2. 如何创建视图
#准备工作
CREATE DATABASE dbtest14;

USE dbtest14;

CREATE TABLE emps
AS
SELECT * FROM atguigudb.`employees`;

CREATE TABLE depts
AS
SELECT * FROM atguigudb.`departments`;

SELECT * FROM emps;
SELECT * FROM depts;

DESC emps;	# 虽然复制了一份emps表格，但是源表的约束都没有一同复制过来

DESC atguigudb.employees;

#2.1 针对于单表
#情况1：视图中的字段与基表的字段有对应关系
CREATE VIEW vu_emp1
AS
SELECT employee_id, last_name, salary
FROM emps;

SELECT * FROM vu_emp1;

#确定视图中字段名的方式1：
CREATE VIEW vu_emp2
AS
SELECT employee_id emp_id, last_name lname, salary #查询语句中字段的别名会作为视图中字段的名称出现
FROM emps
WHERE salary > 7000;

#确定视图中字段名的方式2：
CREATE VIEW vu_emp3(emp_id, `name`, monthly_sal)
AS
SELECT employee_id, last_name, salary
FROM emps
WHERE salary > 7000;

SELECT * FROM vu_emp2;
SELECT * FROM vu_emp3;

#情况2：视图中的字段在基表中可能没有对应的字段
CREATE VIEW vu_emp_sal
AS
SELECT department_id, AVG(salary) avg_sal
FROM emps
WHERE department_id IS NOT NULL
GROUP BY department_id;

SELECT * FROM vu_emp_sal;

#2.2 针对于多表
CREATE VIEW vu_emp_dept
AS
SELECT e.employee_id, e.department_id, d.department_name
FROM emps e JOIN depts d
ON e.department_id = d.department_id;

SELECT * FROM vu_emp_dept;

#利用视图对数据进行格式化
CREATE VIEW vu_emp_dept1
AS
SELECT CONCAT(e.last_name, '(', d.department_name, ')') emp_info
FROM emps e JOIN depts d
ON e.department_id = d.department_id;

SELECT * FROM vu_emp_dept1;

#2.3 基于视图创建视图
CREATE VIEW vu_emp4
AS
SELECT employee_id, last_name
FROM vu_emp1;

SELECT * FROM vu_emp4;

#3. 查看视图  查看有多少视图
# 语法1：查看数据库的表对象、视图对象
SHOW TABLES;

#语法2：查看视图的结构
DESC vu_emp3;

#语法3：查看视图的属性信息
SHOW TABLE STATUS LIKE 'vu_emp3';

#语法4：查看视图的详细定义信息
SHOW CREATE VIEW vu_emp3;

#4."更新"视图中的数据
#4.1 一般情况，可以更新视图的数据
SELECT * FROM vu_emp1;

SELECT employee_id,last_name,salary
FROM emps;


#更新视图的数据，会导致基表中数据的修改
UPDATE vu_emp1
SET salary = 10000
WHERE employee_id = 101;

#同理，更新表中的数据，也会导致视图中的数据的修改
UPDATE emps
SET salary = 20000
WHERE employee_id = 101;



SELECT * FROM vu_emp1;

SELECT employee_id,last_name,salary
FROM emps;

#删除视图中的数据，也会导致表中的数据的删除
DELETE FROM vu_emp1
WHERE employee_id = 101;

DELETE FROM emps
WHERE employee_id = 102;

#4.2 不能更新视图中的数据
SELECT * FROM vu_emp_sal;

#更新失败,因为avg_sal字段 在源表emps中不存在
#The target table vu_emp_sal of the UPDATE is not updatable

UPDATE vu_emp_sal
SET avg_sal = 5000
WHERE department_id = 30;

#删除失败 
DELETE FROM vu_emp_sal
WHERE department_id = 30;

#5. 修改视图

DESC vu_emp1;

#方式1 在vu_emp1 基础上再过滤数据修改一个新视图，覆盖掉老的vu_emp1
CREATE OR REPLACE VIEW vu_emp1 #如果存在老vu_emp1就覆盖老的
AS 
SELECT employee_id, last_name, salary, email
FROM emps
WHERE salary > 7000;

#方式2
ALTER VIEW vu_emp1
AS
SELECT employee_id, last_name, salary, email, hire_date
FROM emps;

SELECT * FROM vu_emp1;

#6. 删除视图
SHOW TABLES;

DROP VIEW vu_emp4;

DROP VIEW IF EXISTS vu_emp2, vu_emp3;
































































































































































































































































































































