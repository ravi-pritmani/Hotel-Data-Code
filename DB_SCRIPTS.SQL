CREATE OR REPLACE DIRECTORY DATA_IN_DIR AS '/tmp/data';


---You can create Index on GTT if the data size increases 
CREATE GLOBAL TEMPORARY TABLE hotel_data_GTT   (hd_hotel_name          VARCHAR2(4000)
                                               ,hd_hotel_start_day     VARCHAR2(1)
                                               ,hd_hotel_end_day       VARCHAR2(1)
                                               ,hd_hotel_start_time    NUMBER(4,2)
                                               ,hd_hotel_end_time      NUMBER(4,2))
ON COMMIT DELETE ROWS                                           
/ 



CREATE OR REPLACE TYPE tab_vc4k 
IS TABLE OF varchar2(4000)
/

 

CREATE TABLE HOTEL_DATA_CSV
(
  HOTEL_NAME     VARCHAR2(4000 BYTE),
  DAY_AND_TIME   VARCHAR2(4000 BYTE)
)
ORGANIZATION EXTERNAL
  (  TYPE ORACLE_LOADER
     DEFAULT DIRECTORY DATA_IN_DIR
     ACCESS PARAMETERS 
       ( RECORDS DELIMITED BY NEWLINE
    FIELDS TERMINATED BY ',' enclosed by '"'
    MISSING FIELD VALUES ARE NULL
    (
      hotel_name      CHAR(4000),
      DAY_AND_TIME      CHAR(4000) 
    )
   )
     LOCATION (DATA_IN_DIR:'sample_data.csv')
  )
REJECT LIMIT UNLIMITED
/

 