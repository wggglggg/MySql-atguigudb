#第07章_单行函数

#1.数值函数
#基本的操作
SELECT ABS(-123),ABS(32),SIGN(-23),SIGN(43),PI(),CEIL(32.32),CEILING(-43.23),FLOOR(32.32),
FLOOR(-43.23),MOD(12,5),12 MOD 5,12 % 5
FROM DUAL;

#取随机数
SELECT RAND(),RAND(),RAND(10),RAND(10),RAND(-1),RAND(-1)
FROM DUAL;

#四舍五入，截断操作
SELECT ROUND(123.556),ROUND(123.456,0),ROUND(123.456,1),ROUND(123.456,2),
ROUND(123.456,-1),ROUND(153.456,-2)
FROM DUAL;

SELECT TRUNCATE(123.456,0),TRUNCATE(123.496,1),TRUNCATE(129.45,-1)
FROM DUAL;

#单行函数可以嵌套
SELECT TRUNCATE(ROUND(123.456,2),0)
FROM DUAL;

#角度与弧度的互换

SELECT RADIANS(30),RADIANS(45),RADIANS(60),RADIANS(90),
DEGREES(2*PI()),DEGREES(RADIANS(60))
FROM DUAL;


#三角函数
SELECT SIN(RADIANS(30)),DEGREES(ASIN(1)),TAN(RADIANS(45)),DEGREES(ATAN(1))
FROM DUAL;

#指数和对数
SELECT POW(2,5),POWER(2,4),EXP(2)
FROM DUAL;

SELECT LN(EXP(2)),LOG(EXP(2)),LOG10(10),LOG2(4)
FROM DUAL;

#进制间的转换
SELECT BIN(10), HEX(10), OCT(10), CONV(10,10,8), CONV(10, 8,2)  
FROM DUAL;

#2. 字符串函数

SELECT ASCII('Abcdfsf'),CHAR_LENGTH('hello'),CHAR_LENGTH('我们'),
LENGTH('hello'),LENGTH('我们')
FROM DUAL;

# xxx worked for yyy
SELECT CONCAT(e.`last_name`, 'worked for', m.`last_name`)
FROM employees e LEFT JOIN employees m
ON e.`manager_id` = m.`employee_id`;

SELECT CONCAT_WS('-', 'KONKA', 'Hisenses', 'Haier')
FROM DUAL;

#字符串的索引是从1开始的！
SELECT INSERT('helloworld', 5, 7, 'ss'), REPLACE('helloworld', 'owo', 'lll')
FROM DUAL;

SELECT UPPER('HelLo'),LOWER('HelLo')
FROM DUAL;

SELECT last_name, salary
FROM employees
WHERE LOWER(last_name = 'King');

SELECT LEFT('hello',2),RIGHT('hello',3),RIGHT('hello',13)
FROM DUAL;

# LPAD:实现右对齐效果
# RPAD:实现左对齐效果
SELECT employee_id, last_name, LPAD(salary, 10, '-')
FROM employees;

SELECT CONCAT('---', LTRIM('     h  el  lo  '), '***'),
TRIM('oo' FROM 'ooheldoel' )
FROM DUAL;

SELECT REPEAT('hello',4),LENGTH(SPACE(5)),STRCMP('abc','abe')
FROM DUAL;

SELECT SUBSTR('hello',2,2),LOCATE('lll','hello')
FROM DUAL;

SELECT ELT(2,'a','b','c','d'),FIELD('mm','gg','jj','mm','dd','mm'),
FIND_IN_SET('mm','gg,mm,jj,dd,mm,gg')
FROM DUAL;

SELECT employee_id, NULLIF(LENGTH(first_name), LENGTH(last_name)) "name longth"
FROM employees;

#3. 日期和时间函数

#3.1  获取日期、时间
SELECT CURDATE(),CURRENT_DATE(),CURTIME(),NOW(),SYSDATE(),
UTC_DATE(),UTC_TIME()
FROM DUAL;

SELECT CURDATE(),CURDATE() + 0,CURTIME() + 0,NOW() + 0
FROM DUAL;  #  2023-05-13	20230513	163320	20230513163320

#3.2 日期与时间戳的转换
SELECT UNIX_TIMESTAMP(), UNIX_TIMESTAMP('2022-10-07 19:33:06'),
FROM_UNIXTIME(1683968575), FROM_UNIXTIME(1665142386)
FROM DUAL;

#3.3 获取月份、星期、星期数、天数等函数
SELECT YEAR(CURDATE()), MONTH(NOW()), DAY(CURDATE()),
HOUR(CURTIME()), MINUTE(NOW()), SECOND(SYSDATE())
FROM DUAL;

SELECT WEEKDAY('2023-5-13'), MONTHNAME('2023-5-13'), DAYNAME('2023-5-13'),
QUARTER(SYSDATE()), WEEK(CURDATE()), DAYOFYEAR(NOW()),
DAYOFMONTH(SYSDATE()), DAYOFWEEK(SYSDATE())
FROM DUAL;

#3.4 日期的操作函数

SELECT EXTRACT(SECOND FROM NOW()), EXTRACT(DAY FROM SYSDATE()),
EXTRACT(HOUR_MINUTE FROM NOW()), EXTRACT(QUARTER FROM '2023-5-13')
FROM DUAL;

#3.5 时间和秒钟转换的函数
SELECT TIME_TO_SEC(CURTIME()), SEC_TO_TIME(83116)
FROM DUAL;

#3.6 计算日期和时间的函数
SELECT CURTIME(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR),
DATE_ADD(CURDATE(), INTERVAL -1 YEAR),
DATE_SUB(NOW(), INTERVAL 1 YEAR)
FROM DUAL;

SELECT DATE_ADD(NOW(), INTERVAL 1 DAY) AS col1,DATE_ADD('2021-10-21 23:32:12',INTERVAL 1 SECOND) AS col2,
ADDDATE('2021-10-21 23:32:12',INTERVAL 1 SECOND) AS col3,
DATE_ADD('2021-10-21 23:32:12',INTERVAL '1_1' MINUTE_SECOND) AS col4,
DATE_ADD(NOW(), INTERVAL -1 YEAR) AS col5, #可以是负数
DATE_ADD(NOW(), INTERVAL '1_1' YEAR_MONTH) AS col6 #需要单引号
FROM DUAL;

SELECT NOW(), ADDTIME(NOW(),20),SUBTIME(NOW(),30),SUBTIME(NOW(),'1:1:3'),DATEDIFF(NOW(),'2021-10-01'),
TIMEDIFF(NOW(),'2021-10-25 22:10:10'),FROM_DAYS(366),TO_DAYS('0000-12-25'),
LAST_DAY(NOW()),MAKEDATE(YEAR(NOW()),1),MAKETIME(10,21,23),PERIOD_ADD(20200101010101,10)
FROM DUAL;


#3.7 日期的格式化与解析
# 格式化：日期 ---> 字符串
# 解析：  字符串 ----> 日期

#此时我们谈的是日期的显式格式化和解析

#之前，我们接触过隐式的格式化或解析
SELECT *
FROM employees
WHERE hire_date	= '1993-01-13';

#格式化

SELECT DATE_FORMAT(CURDATE(),'%Y-%M-%D'),
DATE_FORMAT(NOW(),'%Y-%m-%d'),TIME_FORMAT(CURTIME(),'%h:%i:%S'),
DATE_FORMAT(NOW(),'%Y-%M-%D %h:%i:%S %W %w %T %r')
FROM DUAL;

SELECT STR_TO_DATE('2023-May-13th 07:49:56 Saturday 6','%Y-%M-%D %h:%i:%S %W %w' )
FROM DUAL;

SELECT GET_FORMAT(DATE, 'ISO')
FROM DUAL;

SELECT DATE_FORMAT(SYSDATE(), GET_FORMAT(DATE, 'ISO'))
FROM DUAL;

#4.流程控制函数
#4.1 IF(VALUE,VALUE1,VALUE2)

SELECT last_name, salary, IF(salary >= 6000, '高工资', '低工资') "收入"
FROM employees;

SELECT last_name, commission_pct,
IF(commission_pct IS NOT NULL, commission_pct, 0) "奖金倍率",
salary * 12 * (1 + IF(commission_pct IS NOT NULL, commission_pct, 0)) "年收入"
FROM employees;

#4.2 IFNULL(VALUE1,VALUE2):看做是IF(VALUE,VALUE1,VALUE2)的特殊情况
SELECT last_name, commission_pct, IFNULL(commission_pct, 0) "奖金倍率"
FROM employees;

#4.3 CASE WHEN ... THEN ...WHEN ... THEN ... ELSE ... END
# 类似于java的if ... else if ... else if ... else
SELECT last_name, salary, 
CASE 
WHEN salary >= 15000 THEN '高薪'
WHEN salary >= 10000 THEN '潜力股'
WHEN salary >= 8000 THEN '好工作'
ELSE '草根' END "收入情况",
department_id
FROM employees;

SELECT last_name, salary, 
CASE
WHEN salary >= 15000 THEN '高薪'
WHEN salary >= 10000 THEN '潜力股'
WHEN salary >= 8000 THEN '好工作'
END "收入情况"				#如果没有最后必要 ELSE 可省略
FROM employees;

#4.4 CASE ... WHEN ... THEN ... WHEN ... THEN ... ELSE ... END
# 类似于java的swich ... case...
/*

练习1
查询部门号为 10,20, 30 的员工信息, 
若部门号为 10, 则打印其工资的 1.1 倍, 
20 号部门, 则打印其工资的 1.2 倍, 
30 号部门,打印其工资的 1.3 倍数,
其他部门,打印其工资的 1.4 倍数

*/

SELECT employee_id, last_name, department_id, salary, 
CASE department_id
WHEN 10 THEN salary * 1.1
WHEN 20 THEN salary * 1.2
WHEN 30 THEN salary * 1.3
ELSE salary * 1.4 END "收入情况"
FROM employees;

/*

练习2
查询部门号为 10,20, 30 的员工信息, 
若部门号为 10, 则打印其工资的 1.1 倍, 
20 号部门, 则打印其工资的 1.2 倍, 
30 号部门打印其工资的 1.3 倍数
*/

SELECT employee_id, last_name, department_id, salary,
CASE department_id
WHEN 10 THEN salary * 1.1
WHEN 20 THEN salary * 1.2
WHEN 30 THEN salary * 1.3
END "工资+资金"
FROM employees
WHERE department_id IN (10, 20, 30);

#5. 加密与解密的函数
# PASSWORD()在mysql8.0中弃用。
SELECT MD5('KONKA'),	#f7da3440a24eb21a8377ed3a8fbd93c0
SHA('KONKA')		#e49d246aaceb93d12270e91fcf33efb2d52ab59b
FROM DUAL;

#ENCODE()\DECODE() 在mysql8.0中弃用。

/*
SELECT ENCODE('atguigu','mysql'),DECODE(ENCODE('atguigu','mysql'),'mysql')
FROM DUAL;

SELECT PASSWORD('KONKA')	#*D8DDF21C7057CE954DB3629CAA72462692CE8E4F
FROM DUAL;

SELECT ENCODE('KONKA', 'aaa')	# 将KONKA 按 aaa来进行加密		
FROM DUAL;

SELECT DECODE(ENCODE('KONKA', 'aaa'), 'aaa')	# 使用'aaa'来解密
FROM DUAL;
*/

#6. MySQL信息函数
SELECT VERSION(), CONNECTION_ID(), DATABASE(), SCHEMA(),
USER(),CURRENT_USER(), CHARSET('康佳'), COLLATION('康佳')
FROM DUAL;

#7. 其他函数
#如果n的值小于或者等于0，则只保留整数部分
SELECT FORMAT(224.493, 2), FORMAT(224.499, 0), FORMAT(224.499, -1)
FROM DUAL;

SELECT CONV(22, 10, 8), CONV(9999, 10, 2) # 26        10011100001111
FROM DUAL;

#以“192.168.1.100”为例，计算方式为192乘以256的3次方，加上168乘以256的2次方，加上1乘以256，再加上100。
SELECT INET_ATON('192.168.1.100'),INET_NTOA(3232235876)
FROM DUAL;


#BENCHMARK()用于测试表达式的执行效率
SELECT BENCHMARK(100000,MD5('mysql'))
FROM DUAL;

# CONVERT():可以实现字符集的转换
SELECT CHARSET('atguigu'),CHARSET(CONVERT('atguigu' USING 'gbk'))
FROM DUAL;

SELECT CHARSET(CONVERT('KONKA' USING 'gbk'))	#得出KONKA是什么字符集
FROM DUAL;






