# 第08章_聚合函数的课后练习

#1.where子句可否使用组函数进行过滤?  No, 只能使用having

#2.查询公司员工工资的最大值，最小值，平均值，总和
SELECT MAX(salary) max_salary, MIN(salary) min_salary, AVG(salary) avg_salary, SUM(salary) sum_salary
FROM employees;

#3.查询各job_id的员工种类工资的最大值，最小值，平均值，总和

SELECT job_id, MAX(salary) max_salary, MIN(salary) min_salary, AVG(salary) avg_salary, SUM(salary) sum_salary
FROM employees
GROUP BY job_id;

#4.选择具有各个job_id的员工人数
SELECT job_id, COUNT(*), COUNT(job_id)
FROM employees
GROUP BY job_id;

# 5.查询员工最高工资和最低工资的差距（DIFFERENCE）  #DATEDIFF
SELECT MAX(salary) - MIN(salary) "DIFFERENCE"
FROM employees;

# 6.查询各个管理者手下员工的最低工资，其中最低工资不能低于6000，没有管理者的员工不计算在内
SELECT manager_id,employee_id,  MIN(salary) min_salary
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING min_salary >= 6000;

# 7.查询所有部门的名字，location_id，员工数量和平均工资，并按平均工资降序 

SELECT d.department_name, d.location_id, COUNT(employee_id), AVG(salary) avg_salary
FROM departments d LEFT JOIN employees e
ON d.`department_id` = e.`department_id`
GROUP BY d.`department_name`, d.`location_id`
ORDER BY avg_salary DESC;

# 8.查询每个工种、每个部门的部门名、工种名和最低工资 

SELECT job_id, department_name, MIN(salary) min_salary
FROM departments d LEFT JOIN employees e
ON d.`department_id` = e.`department_id`
GROUP BY d.`department_name`, job_id;



















