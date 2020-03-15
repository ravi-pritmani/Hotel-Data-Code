CREATE OR REPLACE PACKAGE hotel_data_process_api
IS
--*********************************************
-- Type       : Function
-- Access     : public
-- Name       : Get military time
-- Parameters : p_time sample input 12 pm returns 24 HR military time
--*********************************************
   FUNCTION get_military_time (
      p_time_data   IN   VARCHAR2)
      RETURN NUMBER;

--*********************************************
-- Type       : Function
-- Access     : Public
-- Name       : Get Day in Numeric
-- Parameters : p_day sample Mon returns number of the day
--*********************************************
   FUNCTION get_day_num (
      p_day   IN   VARCHAR2)
      RETURN NUMBER;

    --*********************************************
-- Type        : Function
-- Access      : Public
-- Name        : find_open_restaurants
-- Parameters  : p_filename Name of the File that needs to accessed
--             : p_day Any Day 'Mon' ,"Tue" ...
--             : p_time "10 Am" or "12:20 PM"....
--*********************************************
   FUNCTION find_open_restaurants (
      p_filename   IN   VARCHAR2
    , p_day        IN   VARCHAR2
    , p_time       IN   VARCHAR2)
      RETURN CLOB;
END hotel_data_process_api;