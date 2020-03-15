# Hotel-Data-Code
Code To load Hotel Data and get Hotel availablity
Given a CSV in the attached format Package  function
find_open_restaurants(filename, day, time) which takes as parameters a filename, 
a day (Mon,Tue ...Fri) and a time 
(in hh:mm format) and returns a list of restaurant names that are open on that day and time.
1. If a day of the week is not listed, the restaurant is closed on that day
2. All times are local — don’t worry about timezone-awareness
3. The CSV file will be well-formed
--------------------------------------
Login To Database 
It is assumed the user has all appropriate rights 
Execution Steps.
1. Execute the File DB_SCRIPTS.SQL
2. Compile the File HOTEL_DATA_PROCESS_API.pks -- For Package Specification
3. Compile the File HOTEL_DATA_PROCESS_API.pkb -- For Package Body

Steps to Execute 
1. Place the CSV file in database directory "DATA_IN"
Created in FILE  DB_SCRIPTS.SQL

Execute the File Stub.sql to pass the parameters File Name and day and Time respectively.


