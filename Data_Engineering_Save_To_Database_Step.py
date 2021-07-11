# Data Engineering Project - Save to Database from CSV File filled by WebScrape Step
# Goals
# 1. - Read all CSV lines memory
# 
# 1. Open a connection to PostgreSql database
# 2. Drop old table if it already exits
# 3. Recreate table that will receive the CSV file information 
# 4. Read all CSV lines memory
# 5. Insert all 1.000 lines on table created called tbBooks
# 6. If any error occurr, all transaction will be aborted


# To accomplish this step, we used a lib called Selenium:
#   1.1 - Install psycopg2 - Python-PostgreSQL Database Adapter Library using command like: pip install psycopg2 or conda install psycopg2

# Load Libraries needed
import psycopg2
import pandas as pd
import os
import numpy as np
from pandas.core.frame import DataFrame
from io import StringIO


# 1. Open a connection to PostgreSql database
conn = psycopg2.connect("dbname=books2scrape user=postgres password=aikido20")

# Setting auto commit false
conn.autocommit = False

# 2. Drop old table if it already exits
sSql = "DROP TABLE IF EXISTS public.tbBooks;"
cur = conn.cursor()
cur.execute(sSql)
conn.commit()

# 3. Recreate table that will receive the CSV file information  
sqlCreateTable = '''CREATE TABLE IF NOT EXISTS public.tbBooks
(
    "ID" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 ),
    book character varying(500) NOT NULL,
    price character varying(20) NOT NULL,
    PRIMARY KEY ("ID")
);

ALTER TABLE public.tbBooks
    OWNER to postgres; '''
cur.execute(sqlCreateTable)
conn.commit()

# 4. Read all CSV lines memory      
dfBooksCSV = pd.read_csv("C:/DSA/Selenium/SiteBooks2Scrape.csv", header=0)

# Using cursor.executemany() to insert the dataframe line to database table as Bulk Insert
# This approach has more performance than one by one method.
    
# Create a list of tupples from the dataframe values
tuples = [tuple(x) for x in dfBooksCSV.to_numpy()]

# Comma-separated dataframe columns
cols = ','.join(list(dfBooksCSV.columns))

# SQL quert to execute
query  = "INSERT INTO %s(%s) VALUES(%%s,%%s)" % ('tbBooks', cols)
cur = conn.cursor()
try:
    #Insert all 1.000 lines on table created called tbBooks per Blocks
    cur.executemany(query, tuples)
    conn.commit()
except (Exception, psycopg2.DatabaseError) as error:
    print("Error: %s" % error)
    conn.rollback()
    cur.close()
    
print("Save to Database from CSV File done!")

cur.close()

conn.close()