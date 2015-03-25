hive与hbase结合后表可以分为四种：
managed native: what you get by default with CREATE TABLE
external native: what you get with CREATE EXTERNAL TABLE when no STORED BY clause is specified
managed non-native: what you get with CREATE TABLE when a STORED BY clause is specified; Hive stores the definition in its metastore, but does not create any files itself; instead, it calls the storage handler with a request to create a corresponding object structure
external non-native: what you get with CREATE EXTERNAL TABLE when a STORED BY clause is specified; Hive registers the definition in its metastore and calls the storage handler to check that it matches the primary definition in the other system
hbase_table_1是non-native table,A non-native table cannot be used as target for LOAD，所以不能把文件load入hbase_table_1

--hbase
create 'j_position','province','city','country','town','village'

--hive
--先创建外部表
CREATE EXTERNAL TABLE ex_j_position (
  province_id BIGINT,
  province_name string,
  city_id BIGINT,
  city_name string,
  country_id BIGINT,
  country_name string,
   town BIGINT,
  town_name string,
  village_id BIGINT,
  village_name string
)
COMMENT 'EXTERNAL table of j_position'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '/test/ex_j_position/'
TBLPROPERTIES('creator'='Dong Huang','date'='2015-03-20')
;
 fs -put j_position.txt /test/ex_j_position/ ;

--创建hive hbase关联管理表
CREATE  TABLE hive_j_position (
  province_id BIGINT,
  province_name string,
  city_id BIGINT,
  city_name string,
  country_id BIGINT,
  country_name string,
   town BIGINT,
  town_name string,
  village_id BIGINT,
  village_name string
)
COMMENT 'table of hive_j_position'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'  
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,province:name,city:id,city:name,country:id,country:name,town:id,town:name,village:id,village:name")
TBLPROPERTIES("hbase.table.name" = "hbase_j_position"); 

load data local inpath '/home/hadoop/scripts/hbasehive/j_position.txt' overwrite into table hive_j_position;
insert overwrite table hive_j_position select * from ex_j_position;

scan 'hbase_j_position', { LIMIT => 10}