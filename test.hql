--导出hbase表，在hadoop文件系统的当前用户目录下，small文件夹中。
$HBASE_HOME/bin/hbase org.apache.hadoop.hbase.mapreduce.Driver export xyz /home/hadoop/xyz

--将hdfs文件导入到hbase的表
$HBASE_HOME/bin/hbase org.apache.hadoop.hbase.mapreduce.Driver import small /user/hadoop/small/part-m-00000

---------------------
--先在hive中创建表
CREATE TABLE hbase_table_1(key int, value string)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,cf1:val")
TBLPROPERTIES ("hbase.table.name" = "xyz");

--到hbase中put
put 'xyz','100','cf1:val','www.gongchang.com'
put 'xyz','200','cf1:val','hello,word!'

--再到hive select
select * FROM hbase_table_1;


----------------------
--先在hbase中创建表
create 'student','info'
put "student",'1','info:name','tom'
put "student",'2','info:name','lily'
put "student",'3','info:name','wwn'
--在hive中创建表
CREATE EXTERNAL TABLE hbase_table_3(key int, value string)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = "info:name")
TBLPROPERTIES("hbase.table.name" = "student");
--查询
SELECT *　FROM hbase_table_3

------多行和多列族
hive：
CREATE TABLE hbase_table_add1(key int, value1 string, value2 int, value3 int)    
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'  
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,info:col1,info:col2,city:nu")
TBLPROPERTIES("hbase.table.name" = "student_info"); 

insert overwrite table hbase_table_add1 select key,value,key+1,value from hbase_table_3;
insert overwrite table hbase_table_add1 select key,value,key+1,key+100 from hbase_table_3;

hase:
list
scan "student_info"