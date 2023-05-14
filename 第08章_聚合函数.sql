# 第08章_聚合函数
USE atguigudb;

#1. 常见的几个聚合函数
#1.1 AVG / SUM ：只适用于数值类型的字段（或变量）

SELECT AVG(salary), AVG(salary) * 107, SUM(salary)
FROM employees;

#如下的操作没有意义,不能计算字符
SELECT SUM(last_name),AVG(last_name),SUM(hire_date)
FROM employees;

#1.2 MAX / MIN :适用于数值类型、字符串类型、日期时间类型的字段（或变量）

SELECT MAX(salary), MIN(salary)
FROM employees;

SELECT MAX(last_name), MIN(last_name), MAX(hire_date),  MIN(hire_date)
FROM employees;

#1.3 COUNT：
# ① 作用：计算指定字段在查询结构中出现的个数（不包含NULL值的）

SELECT COUNT(employee_id), COUNT(salary), COUNT(2 * salary), COUNT(1), 
COUNT(2), COUNT(*)
FROM employees;

#如果计算表中有多少条记录，如何实现？
#方式1：COUNT(*)
#方式2：COUNT(1)
#方式3：COUNT(具体字段) : 不一定对！字段最好是绝对准确的

#② 注意：计算指定字段出现的个数时，是不计算NULL值的。
SELECT commission_pct
FROM employees
WHERE commission_pct IS NULL; #72条没资金的

SELECT COUNT(commission_pct)  #35条，因为还有一些人没有资金为Null
FROM employees;

#③ 公式：AVG = SUM / COUNT
SELECT AVG(salary),SUM(salary)/COUNT(salary),
AVG(commission_pct), SUM(commission_pct)/COUNT(commission_pct)
FROM employees;

#需求：查询公司中平均奖金率
#错误的！因为avg只统计有数据的员工，没资金的员工却不参与统计
SELECT AVG(commission_pct)
FROM employees;

#正确的：
SELECT SUM(commission_pct) / COUNT(IFNULL(commission_pct, 0)),
AVG(IFNULL(commission_pct, 0))		#0.072897
FROM employees;

# 如何需要统计表中的记录数，使用COUNT(*)、COUNT(1)、COUNT(具体字段) 哪个效率更高呢？
# 如果使用的是MyISAM 存储引擎，则三者效率相同，都是O(1)
# 如果使用的是InnoDB 存储引擎，则三者效率：COUNT(*) = COUNT(1)> COUNT(字段)


#其他：方差、标准差、中位数

#2. GROUP BY 的使用

#需求：查询各个部门的平均工资，最高工资
SELECT department_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY department_id;

#需求：查询各个job_id的平均工资
SELECT job_id, AVG(salary)
FROM employees
GROUP BY job_id;

#需求：查询各个department_id,job_id的平均工资
SELECT department_id, job_id, AVG(salary)
FROM employees
GROUP BY department_id, job_id;
#方式2：一样
SELECT job_id,department_id,AVG(salary)
FROM employees
GROUP BY job_id,department_id;

#错误的！
SELECT department_id,job_id,AVG(salary)
FROM employees
GROUP BY department_id;

#结论1：SELECT中出现的非组函数的字段必须声明在GROUP BY 中。
#      反之，GROUP BY中声明的字段可以不出现在SELECT中。

#结论2：GROUP BY 声明在FROM后面、WHERE后面，ORDER BY 前面、LIMIT前面

#结论3：MySQL中GROUP BY中使用WITH ROLLUP,将聚合函数的值 再平均计算一次，类似avg

SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id WITH ROLLUP;

#需求：查询各个部门的平均工资，按照平均工资升序排列
SELECT department_id, AVG(salary) avg_salary
FROM employees
GROUP BY department_id
ORDER BY avg_salary;

#3. HAVING的使用 (作用：用来过滤数据的)
#练习：查询各个部门中最高工资比10000高的部门信息
#错误的写法：
SELECT department_id,MAX(salary)
FROM employees
WHERE MAX(salary) > 10000
GROUP BY department_id;

#要求1：如果过滤条件中使用了聚合函数，则必须使用HAVING来替换WHERE。否则，报错。
#要求2：HAVING 必须声明在 GROUP BY 的后面。
SELECT department_id, MAX(salary) max_salary
FROM employees
GROUP BY department_id
HAVING max_salary > 10000;

#要求3：开发中，我们使用HAVING的前提是SQL中使用了GROUP BY。

#练习：查询部门id为10,20,30,40这4个部门中最高工资比10000高的部门信息
#方式1：推荐，执行效率高于方式2.
SELECT department_id, MAX(salary) max_salary
FROM employees
WHERE department_id IN (10, 20, 30, 40)
GROUP BY department_id
HAVING max_salary > 10000;

#方式2：不推荐having计算效率慢
SELECT department_id,MAX(salary)
FROM employees
GROUP BY department_id
HAVING MAX(salary) > 10000 AND department_id IN (10,20,30,40);

/*
  WHERE 与 HAVING 的对比
1. 从适用范围上来讲，HAVING的适用范围更广。 
2. 如果过滤条件中没有聚合函数：这种情况下，WHERE的执行效率要高于HAVING
*/

#4. SQL底层执行原理
#4.1 SELECT 语句的完整结构
/*

#sql92语法：
SELECT ....,....,....(存在聚合函数)
FROM ...,....,....
WHERE 多表的连接条件 AND 不包含聚合函数的过滤条件
GROUP BY ...,....
HAVING 包含聚合函数的过滤条件
ORDER BY ....,...(ASC / DESC )
LIMIT ...,....


#sql99语法：
SELECT ....,....,....(存在聚合函数)
FROM ... (LEFT / RIGHT)JOIN ....ON 多表的连接条件 
(LEFT / RIGHT)JOIN ... ON ....
WHERE 不包含聚合函数的过滤条件
GROUP BY ...,....
HAVING 包含聚合函数的过滤条件
ORDER BY ....,...(ASC / DESC )
LIMIT ...,....


*/

#4.2 SQL语句的执行过程：
#FROM ...,...-> ON -> (LEFT/RIGNT  JOIN) -> WHERE -> GROUP BY -> HAVING -> SELECT -> DISTINCT -> 
# ORDER BY -> LIMIT