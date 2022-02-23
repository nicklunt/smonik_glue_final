import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

from awsglue.dynamicframe import DynamicFrame
import pyspark.sql.functions as F
from pyspark.sql.functions import to_date,to_timestamp, col
from pyspark.sql.functions import input_file_name, current_timestamp


import pg8000 
import boto3
import json

client = boto3.client('secretsmanager')

response = client.get_secret_value(SecretId='smonik-custodianmdr')

secretDict = json.loads(response['SecretString'])

connection_db = pg8000.connect( 
        database=secretDict['dbname'],  
        user=secretDict['username'],  
        password=secretDict['password'], 
        host=secretDict['host'],
        port=secretDict['port']
) 

conn=connection_db

if conn is not None: 
    cursor = conn.cursor() 
    cursor.execute("Truncate table dbo.stagposition") 
    conn.commit() 
    cursor.close() 
    conn.close() 



## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "srcmetadata", table_name = "smonik_s3_position", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "srcmetadata", table_name = "smonik_s3_position", transformation_ctx = "datasource0")
## @type: ApplyMapping
## @args: [mapping = [("providerid", "string", "providerid", "string"), ("consolidationid", "string", "consolidationid", "string"), ("provideraccountid", "string", "provideraccountid", "string"), ("asof", "string", "asof", "date"), ("cusip", "string", "cusip", "string"), ("sedol", "string", "sedol", "string"), ("isin", "string", "isin", "string"), ("ticker", "string", "ticker", "string"), ("securityname", "string", "securityname", "string"), ("assetclass", "string", "assetclass", "string"), ("basecurrency", "string", "basecurrency", "string"), ("localcurrency", "string", "localcurrency", "string"), ("country", "string", "country", "string"), ("shares", "string", "shares", "decimal(38,8)"), ("price", "string", "price", "decimal(38,8)"), ("marketvalue", "string", "marketvalue", "decimal(38,8)"), ("accruedincome", "double", "accruedincome", "decimal(38,8)"), ("costbasis", "string", "costbasis", "decimal(38,8)"), ("gainloss", "string", "gainloss", "decimal(38,8)"), ("auditstatus", "string", "auditstatus", "string"), ("sourceorigin", "string", "sourceorigin", "string"), ("sourceclassification", "string", "sourceclassification", "string"), ("localprice", "string", "localprice", "decimal(38,8)"), ("localmarketvalue", "string", "localmarketvalue", "decimal(38,8)"), ("localaccruedincome", "string", "localaccruedincome", "decimal(38,8)"), ("localcostbasis", "string", "localcostbasis", "decimal(38,8)"), ("localgainloss", "string", "localgainloss", "decimal(38,8)"), ("proprietaryid", "long", "proprietaryid", "string"), ("process_datetime", "string", "process_datetime", "timestamp")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]


#Convert asof column to date format
dataFrame = datasource0.toDF()

if dataFrame.count() != 0:
    dataFrame = dataFrame.withColumnRenamed('createtime', "createtime")
    dataFrame = dataFrame.withColumnRenamed('asof', "asof")
    
    #add source file name
    dataFrame = dataFrame.withColumn("sourcefilename", input_file_name())
    dataFrame = dataFrame.withColumn("asof", to_date(col("asof"),"MM/dd/yyyy"))
    dataFrame = dataFrame.withColumn("createtime", to_timestamp(col("createtime"),"MM/dd/yyyy HH:mm"))
    
    
    #Convert shares, price, marketvalue, accruedincome, costbasis, gainloss columns to decimal 
    dataFrame  = dataFrame .withColumn('shares', F.regexp_replace('shares', ',', '').cast('decimal(38,8)'))
    
    dataFrame  = dataFrame .withColumn('price', F.regexp_replace('price', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('marketvalue', F.regexp_replace('marketvalue', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('accruedincome', F.regexp_replace('accruedincome', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('costbasis', F.regexp_replace('costbasis', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('gainloss', F.regexp_replace('gainloss', ',', '').cast('decimal(38,8)'))
    
    #local columns
    dataFrame  = dataFrame .withColumn('localprice', F.regexp_replace('localprice', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('localmarketvalue', F.regexp_replace('localmarketvalue', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('localaccruedincome', F.regexp_replace('localaccruedincome', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('localcostbasis', F.regexp_replace('localcostbasis', ',', '').cast('decimal(38,8)'))
    dataFrame  = dataFrame .withColumn('localgainloss', F.regexp_replace('localgainloss', ',', '').cast('decimal(38,8)'))



# Convert back to a dynamic frame
editedData = DynamicFrame.fromDF(dataFrame, glueContext, "editedData")

print("Printed Schema")
editedData.printSchema()
print("Edited Schema",editedData.show())


applymapping1 = ApplyMapping.apply(frame = editedData, mappings = [("providerid", "string", "providerid", "int"), ("consolidationid", "string", "consolidationid", "string"), ("provideraccountid", "string", "provideraccountid", "string"), ("asof", "date", "asof", "date"), ("cusip", "string", "cusip", "string"), ("sedol", "string", "sedol", "string"), ("isin", "string", "isin", "string"), ("ticker", "string", "ticker", "string"), ("securityname", "string", "securityname", "string"), ("proprietary_id", "long", "proprietaryid", "string"), ("assetclass", "string", "assetclass", "string"), ("basecurrency", "string", "basecurrency", "string"), ("localcurrency", "string", "localcurrency", "string"), ("country", "string", "country", "string"), ("shares", "decimal(38,8)", "shares", "decimal(38,8)"), ("price", "decimal(38,8)", "price", "decimal(38,8)"), ("marketvalue", "decimal(38,8)", "marketvalue", "decimal(38,8)"), ("accruedincome", "decimal(38,8)", "accruedincome", "decimal(38,8)"), ("costbasis", "decimal(38,8)", "costbasis", "decimal(38,8)"), ("gainloss", "decimal(38,8)", "gainloss", "decimal(38,8)"), ("auditstatus", "string", "auditstatus", "string"), ("sourceorigin", "string", "sourceorigin", "string"), ("sourceclassification", "string", "sourceclassification", "string"), ("sourcefilename", "string", "sourcefilename", "string"), ("localmarketvalue", "decimal(38,8)", "localmarketvalue", "decimal(38,8)"), ("localaccruedincome", "decimal(38,8)", "localaccruedincome", "decimal(38,8)"), ("localcostbasis", "decimal(38,8)", "localcostbasis", "decimal(38,8)"), ("localgainloss", "decimal(38,8)", "localgainloss", "decimal(38,8)"),("localprice", "decimal(38,8)", "localprice", "decimal(38,8)"),("createtime", "timestamp", "process_datetime", "timestamp"),("figi", "string", "figi", "string"),("securitydescription", "string", "securitydescription", "string")], transformation_ctx = "applymapping1")


# applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("providerid", "string", "providerid", "string"), ("consolidationid", "string", "consolidationid", "string"), ("provideraccountid", "string", "provideraccountid", "string"), ("asof", "string", "asof", "date"), ("cusip", "string", "cusip", "string"), ("sedol", "string", "sedol", "string"), ("isin", "string", "isin", "string"), ("ticker", "string", "ticker", "string"), ("securityname", "string", "securityname", "string"), ("assetclass", "string", "assetclass", "string"), ("basecurrency", "string", "basecurrency", "string"), ("localcurrency", "string", "localcurrency", "string"), ("country", "string", "country", "string"), ("shares", "string", "shares", "decimal(38,8)"), ("price", "string", "price", "decimal(38,8)"), ("marketvalue", "string", "marketvalue", "decimal(38,8)"), ("accruedincome", "double", "accruedincome", "decimal(38,8)"), ("costbasis", "string", "costbasis", "decimal(38,8)"), ("gainloss", "string", "gainloss", "decimal(38,8)"), ("auditstatus", "string", "auditstatus", "string"), ("sourceorigin", "string", "sourceorigin", "string"), ("sourceclassification", "string", "sourceclassification", "string"), ("localprice", "string", "localprice", "decimal(38,8)"), ("localmarketvalue", "string", "localmarketvalue", "decimal(38,8)"), ("localaccruedincome", "string", "localaccruedincome", "decimal(38,8)"), ("localcostbasis", "string", "localcostbasis", "decimal(38,8)"), ("localgainloss", "string", "localgainloss", "decimal(38,8)"), ("proprietaryid", "long", "proprietaryid", "string"), ("process_datetime", "string", "process_datetime", "timestamp")], transformation_ctx = "applymapping1")

## @type: SelectFields
## @args: [paths = ["localcurrency", "country", "cusip", "localaccruedincome", "localcostbasis", "marketvalue", "sourceorigin", "basecurrency", "shares", "sourcemodified", "datemodified", "price", "costbasis", "localprice", "gainloss", "ticker", "auditstatus", "localmarketvalue", "asof", "sourceclassification", "datecreated", "sedol", "assetclass", "process_datetime", "consolidationid", "securityname", "providerid", "sourcefilename", "accruedincome", "proprietaryid", "provideraccountid", "localgainloss", "isin"], transformation_ctx = "selectfields2"]
## @return: selectfields2
## @inputs: [frame = applymapping1]

resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_cols", transformation_ctx = "resolvechoice2")

selectfields2 = SelectFields.apply(frame = resolvechoice2, paths = ["localcurrency", "country", "cusip", "marketvalue","localmarketvalue", "sourceorigin", "basecurrency", "shares", "price","localprice", "costbasis", "gainloss", "localcostbasis", "localgainloss","ticker", "auditstatus", "asof", "sourceclassification", "sedol", "assetclass", "consolidationid", "securityname", "providerid", "accruedincome","localaccruedincome", "proprietaryid", "sourcefilename","datecreated", "provideraccountid", "isin","process_datetime","sourcemodified", "datemodified","securitydescription","figi"], transformation_ctx = "selectfields2")


# selectfields2 = SelectFields.apply(frame = applymapping1, paths = ["localcurrency", "country", "cusip", "localaccruedincome", "localcostbasis", "marketvalue", "sourceorigin", "basecurrency", "shares", "sourcemodified", "datemodified", "price", "costbasis", "localprice", "gainloss", "ticker", "auditstatus", "localmarketvalue", "asof", "sourceclassification", "datecreated", "sedol", "assetclass", "process_datetime", "consolidationid", "securityname", "providerid", "sourcefilename", "accruedincome", "proprietaryid", "provideraccountid", "localgainloss", "isin"], transformation_ctx = "selectfields2")
## @type: ResolveChoice
## @args: [choice = "MATCH_CATALOG", database = "destmetadata", table_name = "rds_aurora_custodianmdr_dbo_stagposition", transformation_ctx = "resolvechoice3"]
## @return: resolvechoice3
## @inputs: [frame = selectfields2]
resolvechoice3 = ResolveChoice.apply(frame = selectfields2, choice = "MATCH_CATALOG", database = "destmetadata", table_name = "rds_aurora_custodianmdr_dbo_stagposition", transformation_ctx = "resolvechoice3")
## @type: ResolveChoice
## @args: [choice = "make_cols", transformation_ctx = "resolvechoice4"]
## @return: resolvechoice4
## @inputs: [frame = resolvechoice3]
resolvechoice4 = ResolveChoice.apply(frame = resolvechoice3, choice = "make_cols", transformation_ctx = "resolvechoice4")

Loading= DropNullFields.apply(frame = resolvechoice4, transformation_ctx = "Loading")

## @type: DataSink
## @args: [database = "destmetadata", table_name = "rds_aurora_custodianmdr_dbo_stagposition", transformation_ctx = "datasink5"]
## @return: datasink5
## @inputs: [frame = resolvechoice4]
datasink5 = glueContext.write_dynamic_frame.from_catalog(frame = Loading, database = "destmetadata", table_name = "rds_aurora_custodianmdr_dbo_stagposition", transformation_ctx = "datasink5")
job.commit()
