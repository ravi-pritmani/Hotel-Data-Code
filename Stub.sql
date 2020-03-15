 DECLARE
  P_FILENAME VARCHAR2(200);
  P_DAY VARCHAR2(200);
  P_TIME VARCHAR2(200);
  v_Return CLOB;
BEGIN
  P_FILENAME := 'sample_data.csv';
  P_DAY := 'Mon';
  P_TIME := '11 am';
 
COMMIT;
  v_Return := HOTEL_DATA_PROCESS_API.FIND_OPEN_RESTAURANTS(
    P_FILENAME => P_FILENAME,
    P_DAY => P_DAY,
    P_TIME => P_TIME
  );
  COMMIT;
 
DBMS_OUTPUT.PUT_LINE( v_Return);
 
END;
/