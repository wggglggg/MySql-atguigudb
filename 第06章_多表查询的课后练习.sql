# 第06章_多表查询的课后练习
SHOW DATABASES;
USE atguigudb;

# 1.显示所有员工的姓名，部门号和部门名称。
SELECT e.last_name, e.department_id, d.department_name
FROM employees e LEFT JOIN departments d
ON e.`department_id` = d.`department_id`;

# 2.查询90号部门员工的job_id和90号部门的location_id
SELECT e.`job_id`, d.`location_id`, e.`department_id`
FROM employees e JOIN departments d
ON e.`department_id` = d.`department_id`
WHERE e.`department_id`= 90;

# 3.选择所有有奖金的员工的 last_name , department_name , location_id , city
SELECT e.last_name , e.`commission_pct` , d.location_id , l.city
FROM employees e LEFT JOIN departments d
ON e.`department_id` = d.`department_id`
LEFT JOIN locations l
ON d.`location_id` = l.`location_id`
WHERE e.commission_pct IS NOT NULL; #也应该是35条记录 Grant location_id与city为

SELECT *
FROM employees
WHERE commission_pct IS NOT NULL;  #有35个员工有资金

# 4.选择city在Toronto工作的员工的 last_name , job_id , department_id , department_name 
SELECT e.`last_name`, e.`job_id`, d.`department_id`, d.`department_name` 
FROM employees e LEFT JOIN departments d
ON e.`department_id` = d.`department_id`
LEFT JOIN locations l
ON d.`location_id` = l.`location_id`
WHERE l.`city` = 'Toronto';

#sql92语法：
SELECT e.last_name , e.job_id , e.department_id , d.department_name
FROM employees e,departments d ,locations l
WHERE e.`department_id` = d.`department_id` 
AND d.`location_id` = l.`location_id`
AND l.`city` = 'Toronto';

# 5.查询员工所在的部门名称、部门地址、姓名、工作、工资，其中员工所在部门的部门名称为’Executive’

SELECT d.`department_name`, l.`street_address`, e.`last_name`, e.`job_id`, e.`salary`
FROM employees e LEFT JOIN departments d
ON e.`department_id` = d.`department_id`
LEFT JOIN locations l
ON d.`location_id` = l.`location_id`
WHERE d.`department_name` = 'Executive';

# 6.选择指定员工的姓名，员工号，以及他的管理者的姓名和员工号，结果类似于下面的格式
#employees	Emp#	manager	Mgr#
#kochhar		101	king	100

SELECT e.last_name, e.employee_id, m.last_name, m.employee_id
FROM employees e LEFT JOIN employees m
ON e.manager_id = m.employee_id;

# 7.查询哪些部门没有员工
SELECT d.`department_name`, d.`department_id`, e.`last_name`
FROM employees e RIGHT JOIN departments d
ON e.`department_id` = d.`department_id`
WHERE e.`employee_id` IS NULL;

#本题也可以使用子查询：暂时不讲

# 8. 查询哪个城市没有部门 
SELECT l.`city`, d.`department_id`, d.`department_name`
FROM departments d RIGHT JOIN locations l
ON d.`location_id` = l.`location_id`
WHERE d.`location_id` IS NULL;

SELECT * FROM departments;
SELECT * FROM locations;

SELECT *
FROM departments d RIGHT JOIN locations l
ON d.`location_id` = l.`location_id`
WHERE d.`department_id` IS NULL;

# 9. 查询部门名为 Sales 或 IT 的员工信息
SELECT d.`department_name`, e.`last_name`, e.`department_id`, e.`salary`
FROM employees e LEFT JOIN departments d
ON e.`department_id` = d.`department_id`
WHERE d.`department_name` IN ('Sales', 'IT');







