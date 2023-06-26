#第18章_MySQL8.0的其它新特性

#2. 新特性1：窗口函数

# 准备工作
CREATE DATABASE dbtest18;

USE dbtest18;

CREATE TABLE sales(
id INT PRIMARY KEY AUTO_INCREMENT,
city VARCHAR(15),
county VARCHAR(15),
sales_value DECIMAL
);

INSERT INTO sales(city,county,sales_value)
VALUES
('北京','海淀',10.00),
('北京','朝阳',20.00),
('上海','黄埔',30.00),
('上海','长宁',10.00);

SELECT * FROM sales;


#需求：现在计算这个网站在每个城市的销售总额、在全国的销售总额、每个区的销售额占所在城市销售
#额中的比率，以及占总销售额中的比率。
#如果用分组和聚合函数，就需要分好几步来计算。


#第一步，计算总销售金额，并存入临时表 a：
CREATE TEMPORARY TABLE a
AS
SELECT SUM(sales_value) AS sales_value FROM sales;

#查看一下临时表 a 
SELECT * FROM a;

#第二步，计算每个城市的销售总额并存入临时表 b：
CREATE TEMPORARY TABLE b
AS
SELECT city, SUM(sales_value) AS sales_value
FROM sales
GROUP BY city;

#查看临时表 b ：
SELECT * FROM b;

#第三步，计算各区的销售占所在城市的总计金额的比例，和占全部销售总计金额的比例。我们可以通过
#下面的连接查询获得需要的结果：

SELECT s.city AS 城市,s.county AS 区,s.sales_value AS 区销售额,
b.sales_value AS 市销售额,s.sales_value/b.sales_value AS 市比率,
a.sales_value AS 总销售额,s.sales_value/a.sales_value AS 总比率
FROM sales s
JOIN b ON (s.city=b.city) 	-- 连接市统计结果临时表
JOIN a 				-- 连接总计金额临时表
ORDER BY s.city,s.county;


#同样的查询，如果用窗口函数，就简单多了。我们可以用下面的代码来实现：

SELECT city AS 城市,county AS 区,sales_value AS 区销售额,
SUM(sales_value) OVER(PARTITION BY city) AS 市销售额, -- 计算市销售额
sales_value/SUM(sales_value) OVER (PARTITION BY city) AS 市比率,
SUM(sales_value) OVER() AS 总销售额, 	-- 计算总销售额
sales_value/SUM(sales_value) OVER() AS 总比率
FROM sales
ORDER BY city, county;


#结果显示，我们得到了与上面那种查询同样的结果。
#使用窗口函数，只用了一步就完成了查询。而且，由于没有用到临时表，执行的效率也更高了。很显
#然，在这种需要用到分组统计的结果对每一条记录进行计算的场景下，使用窗口函数更好

#2.2 窗口函数分类
#MySQL从8.0版本开始支持窗口函数。窗口函数的作用类似于在查询中对数据进行分组，不同的是，分组
#操作会把分组的结果聚合成一条记录，而窗口函数是将结果置于每一条数据记录中。
#窗口函数可以分为 静态窗口函数 和 动态窗口函数 。
#静态窗口函数的窗口大小是固定的，不会因为记录的不同而不同；
#动态窗口函数的窗口大小会随着记录的不同而变化。
#MySQL官方网站窗口函数的网址为https://dev.mysql.com/doc/refman/8.0/en/window-function-descriptio
#ns.html#function_row-number。
#窗口函数总体上可以分为序号函数、分布函数、前后函数、首尾函数和其他函数，如下表：


#2.4 分类讲解

#创建表：

CREATE TABLE goods(
id INT PRIMARY KEY AUTO_INCREMENT,
category_id INT,		#类别id
category VARCHAR(15),		#类别名称
NAME VARCHAR(30),
price DECIMAL(10,2),
stock INT,
upper_time DATETIME
);

#添加数据：
INSERT INTO goods(category_id,category,NAME,price,stock,upper_time)
VALUES
(1, '女装/女士精品', 'T恤', 39.90, 1000, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '连衣裙', 79.90, 2500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '卫衣', 89.90, 1500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '牛仔裤', 89.90, 3500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '百褶裙', 29.90, 500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '呢绒外套', 399.90, 1200, '2020-11-10 00:00:00'),
(2, '户外运动', '自行车', 399.90, 1000, '2020-11-10 00:00:00'),
(2, '户外运动', '山地自行车', 1399.90, 2500, '2020-11-10 00:00:00'),
(2, '户外运动', '登山杖', 59.90, 1500, '2020-11-10 00:00:00'),
(2, '户外运动', '骑行装备', 399.90, 3500, '2020-11-10 00:00:00'),
(2, '户外运动', '运动外套', 799.90, 500, '2020-11-10 00:00:00'),
(2, '户外运动', '滑板', 499.90, 1200, '2020-11-10 00:00:00');

#下面针对goods表中的数据来验证每个窗口函数的功能。

SELECT * FROM goods;


#1. 序号函数
#1．ROW_NUMBER()函数
#ROW_NUMBER()函数能够对数据中的序号进行顺序显示。
#举例：查询 goods 数据表中每个商品分类下价格降序排列的各个商品信息。
#按category_id类型id的方式partition分组, partition分将同一类别的分一个组
#  并分配序号，分配到新的类型时，再从1开始分配序列
SELECT ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num ,
id, category_id, category, NAME, price, stock
FROM goods;

#举例：查询 goods 数据表中每个商品分类下价格最高的3种商品信息。
SELECT * 
FROM (
SELECT ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods
) AS t
WHERE row_num <= 3;



#在名称为“女装/女士精品”的商品类别中，有两款商品的价格为89.90元，分别是卫衣和牛仔裤。两款商品
#的序号都应该为2，而不是一个为2，另一个为3。此时，可以使用RANK()函数和DENSE_RANK()函数解
#决。


#2．RANK()函数
#使用RANK()函数能够对序号进行并列排序，并且会跳过重复的序号，比如序号为1、1、3。
#举例：使用RANK()函数获取 goods 数据表中各类别的价格从高到低排序的各商品信息。
SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods;

#举例：使用RANK()函数获取 goods 数据表中类别为“女装/女士精品”的价格最高的4款商品信息。
SELECT * FROM(
SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
 id, category_id, category, NAME, price, stock
 FROM goods
) AS t
WHERE row_num <= 4 AND category_id = 1;

#可以看到，使用RANK()函数得出的序号为1、2、2、4，相同价格的商品序号相同，后面的商品序号是不
#连续的，跳过了重复的序号。


#3．DENSE_RANK()函数---与RANK()相反

#DENSE_RANK()函数对序号进行并列排序，并且不会跳过重复的序号，比如序号为1、1、2。
#举例：使用DENSE_RANK()函数获取 goods 数据表中各类别的价格从高到低排序的各商品信息。
SELECT DENSE_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods;

#举例：使用DENSE_RANK()函数获取 goods 数据表中类别为“女装/女士精品”的价格最高的4款商品信息。
SELECT * FROM(
SELECT DENSE_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods
) AS t
WHERE row_num <= 4 AND category_id = 1;

#可以看到，使用DENSE_RANK()函数得出的行号为1、2、2、3，相同价格的商品序号相同，后面的商品序
#号是连续的，并且没有跳过重复的序号。


#2. 分布函数

#1．PERCENT_RANK()函数
#PERCENT_RANK()函数是等级值百分比函数。按照如下方式进行计算。

#其中，rank的值为使用RANK()函数产生的序号，rows的值为当前窗口的总记录数。
# (rank - 1) / (rows - 1)  ran序列第几个 / 总个数 = 当前列进度


#举例：计算 goods 数据表中名称为“女装/女士精品”的类别下的商品的PERCENT_RANK值。
SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS r,
PERCENT_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS pr,
id, category_id, category, NAME, price, stock
FROM goods
WHERE category_id = 1;


#2．CUME_DIST()函数

#CUME_DIST()函数主要用于查询小于或等于某个值的比例。

#举例：查询goods数据表中小于或等于当前价格的比例。

SELECT CUME_DIST() OVER(PARTITION BY category_id ORDER BY price ) AS cd,
id, category, NAME, price
FROM goods;


#3. 前后函数

#1．LAG(expr,n)函数
#LAG(expr,n)函数返回当前行的前n行的expr的值。

#举例：查询goods数据表中前一个商品价格与当前商品价格的差值。
SELECT id, category, NAME, price, LAG(price, 1) OVER(PARTITION BY category_id ORDER BY price) AS pre_price
FROM goods;

SELECT  id, category, NAME, price, pre_price, price - pre_price AS diff_price
FROM (SELECT id, category, NAME, price, LAG(price, 1) OVER w AS pre_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price)) AS t;


#2．LEAD(expr,n)函数
#LEAD(expr,n)函数返回当前行的后n行的expr的值。
#举例：查询goods数据表中后一个商品价格与当前商品价格的差值。
SELECT id, category, NAME, price, pre_price, price - pre_price AS diff_price
FROM(
SELECT id, category, NAME, price, LEAD(price, 1) OVER w AS pre_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price)) AS t;



#4. 首尾函数

#1．FIRST_VALUE(expr)函数,拿同类别所有的价格与同类别第一个比较

#FIRST_VALUE(expr)函数返回第一个expr的值。

#举例：按照价格排序，查询第1个商品的价格信息。
SELECT  category_id, category, NAME, price, stock, FIRST_VALUE(price) 
OVER w AS first_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price);


#2．LAST_VALUE(expr)函数, 
#LAST_VALUE(expr)函数返回最后一个expr的值。

#举例：按照价格排序，查询最后一个商品的价格信息。

SELECT category_id, category NAME, price, stock, LAST_VALUE(price) 
OVER w AS last_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price RANGE BETWEEN
            UNBOUNDED PRECEDING AND
            UNBOUNDED FOLLOWING 
            );



#5. 其他函数
#1．NTH_VALUE(expr,n)函数
#NTH_VALUE(expr,n)函数返回第n个expr的值。


#举例：查询goods数据表中排名第2和第3的价格信息
SELECT id, category, NAME, price, 
NTH_VALUE(price, 2) OVER w AS second_price,
NTH_VALUE(price, 3) OVER w AS third_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price);


#2．NTILE(n)函数
#NTILE(n)函数将分区中的有序数据分为n个桶，记录桶编号。

#举例：将goods表中的商品按照价格分为3组。

SELECT NTILE(3) OVER w AS nt, id, category, NAME, price
FROM goods
WINDOW w AS (PARTITION BY category ORDER BY price);

#2.5 小 结
#窗口函数的特点是可以分组，而且可以在分组内排序。另外，窗口函数不会因为分组而减少原表中的行
#数，这对我们在原表数据的基础上进行统计和排序非常有用。





# 3. 新特性2：公用表表达式


#公用表表达式（或通用表表达式）简称为CTE（Common Table Expressions）。CTE是一个命名的临时结
#果集，作用范围是当前语句。CTE可以理解成一个可以复用的子查询，当然跟子查询还是有点区别的，
#CTE可以引用其他CTE，但子查询不能引用其他子查询。所以，可以考虑代替子查询。


#依据语法结构和执行方式的不同，公用表表达式分为 普通公用表表达式 和 递归公用表表达式 2 种。

#3.1 普通公用表表达式
#普通公用表表达式的语法结构是：

WITH CTE名称
AS （子查询）
SELECT|DELETE|UPDATE 语句;


#普通公用表表达式类似于子查询，不过，跟子查询不同的是，它可以被多次引用，而且可以被其他的普
#通公用表表达式所引用。



#举例：查询员工所在的部门的详细信息。
CREATE TABLE employees
AS
SELECT * FROM atguigudb.`employees`;

CREATE TABLE departments
AS
SELECT * FROM atguigudb.`departments`;

SELECT department_id, department_name, manager_id, location_id
FROM departments
WHERE department_id IN (
SELECT DISTINCT department_id
FROM employees
);

#这个查询也可以用普通公用表表达式的方式完成：
WITH emp_dept_id
AS (SELECT DISTINCT department_id FROM employees)
SELECT * 
FROM departments d JOIN emp_dept_id e
ON d.department_id = e.department_id;

/*
例子说明，公用表表达式可以起到子查询的作用。以后如果遇到需要使用子查询的场景，你可以在查询
之前，先定义公用表表达式，然后在查询中用它来代替子查询。而且，跟子查询相比，公用表表达式有
一个优点，就是定义过公用表表达式之后的查询，可以像一个表一样多次引用公用表表达式，而子查询
则不能。


3.2 递归公用表表达式
递归公用表表达式也是一种公用表表达式，只不过，除了普通公用表表达式的特点以外，它还有自己的
特点，就是可以调用自己。它的语法结构是：
*/

WITH RECURSIVE
CTE名称 AS （子查询）
SELECT|DELETE|UPDATE 语句;


/*
递归公用表表达式由 2 部分组成，分别是种子查询和递归查询，中间通过关键字 UNION [ALL]进行连接。
这里的种子查询，意思就是获得递归的初始值。这个查询只会运行一次，以创建初始数据集，之后递归
查询会一直执行，直到没有任何新的查询数据产生，递归返回。
案例：针对于我们常用的employees表，包含employee_id，last_name和manager_id三个字段。如果a是b
的管理者，那么，我们可以把b叫做a的下属，如果同时b又是c的管理者，那么c就是b的下属，是a的下下
属。
下面我们尝试用查询语句列出所有具有下下属身份的人员信息。
如果用我们之前学过的知识来解决，会比较复杂，至少要进行 4 次查询才能搞定：
第一步，先找出初代管理者，就是不以任何别人为管理者的人，把结果存入临时表；
第二步，找出所有以初代管理者为管理者的人，得到一个下属集，把结果存入临时表；
第三步，找出所有以下属为管理者的人，得到一个下下属集，把结果存入临时表。
第四步，找出所有以下下属为管理者的人，得到一个结果集。
如果第四步的结果集为空，则计算结束，第三步的结果集就是我们需要的下下属集了，否则就必须继续
进行第四步，一直到结果集为空为止。比如上面的这个数据表，就需要到第五步，才能得到空结果集。
而且，最后还要进行第六步：把第三步和第四步的结果集合并，这样才能最终获得我们需要的结果集。

如果用递归公用表表达式，就非常简单了。我介绍下具体的思路。
用递归公用表表达式中的种子查询，找出初代管理者。字段 n 表示代次，初始值为 1，表示是第一
代管理者。
用递归公用表表达式中的递归查询，查出以这个递归公用表表达式中的人为管理者的人，并且代次
的值加 1。直到没有人以这个递归公用表表达式中的人为管理者了，递归返回。
在最后的查询中，选出所有代次大于等于 3 的人，他们肯定是第三代及以上代次的下属了，也就是
下下属了。这样就得到了我们需要的结果集。
这里看似也是 3 步，实际上是一个查询的 3 个部分，只需要执行一次就可以了。而且也不需要用临时表
保存中间结果，比刚刚的方法简单多了。
*/
WITH RECURSIVE cte
AS
(
SELECT employee_id,last_name,manager_id,1 AS n FROM employees WHERE employee_id = 100
-- 种子查询，找到第一代领导
UNION ALL
SELECT a.employee_id,a.last_name,a.manager_id,n+1 FROM employees AS a JOIN cte
ON (a.manager_id = cte.employee_id) -- 递归查询，找出以递归公用表表达式的人为领导的人
)
SELECT employee_id,last_name FROM cte WHERE n >= 4;


WITH RECURSIVE cte1
AS
(
SELECT employee_id, last_name, manager_id, 1 AS n FROM employees WHERE employee_id = 100
#子查询  找到第一代领导100
UNION ALL
SELECT e.employee_id, e.last_name, e.manager_id, n+1 FROM employees AS e JOIN cte1
ON e.manager_id = cte1.employee_id -- 递归查询，找出以递归公用表表达式的人为领导的人
)
SELECT employee_id, last_name FROM cte1 WHERE n >= 4;


/*
总之，递归公用表表达式对于查询一个有共同的根节点的树形结构数据，非常有用。它可以不受层级的
限制，轻松查出所有节点的数据。如果用其他的查询方式，就比较复杂了。




3.3 小 结
公用表表达式的作用是可以替代子查询，而且可以被多次引用。递归公用表表达式对查询有一个共同根
节点的树形结构数据非常高效，可以轻松搞定其他查询方式难以处理的查询。
*/
