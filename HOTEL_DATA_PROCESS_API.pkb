CREATE OR REPLACE PACKAGE BODY hotel_data_process_api
IS
--*********************************************
-- Type       : Function
-- Access     : public
-- Name       : Get military time
-- Parameters : p_time sample input 12 pm returns 24 HR military time
--*********************************************
   FUNCTION get_military_time (
      p_time_data   IN   VARCHAR2)
      RETURN NUMBER
   IS
      l_ret_time   NUMBER;
   BEGIN
      l_ret_time :=
         (CASE
             WHEN INSTR (p_time_data, 'am') > 0
                THEN (CASE
                         WHEN TO_NUMBER (REPLACE (REPLACE (TRIM (p_time_data), 'am', ''), ':', '.') ) >= 12
                            THEN TO_NUMBER (REPLACE (REPLACE (TRIM (p_time_data), 'am', ''), ':', '.') ) - 12
                         ELSE TO_NUMBER (REPLACE (REPLACE (TRIM (p_time_data), 'am', ''), ':', '.') )
                      END)
             WHEN INSTR (p_time_data, 'pm') > 0
                THEN (TO_NUMBER (REPLACE (REPLACE (TRIM (p_time_data), 'pm', ''), ':', '.') ) + 12)
          END);
      RETURN l_ret_time;
   END get_military_time;

--*********************************************
-- Type       : Function
-- Access     : Public
-- Name       : Get Day in Numeric
-- Parameters : p_day sample Mon returns number of the day
--*********************************************
   FUNCTION get_day_num (
      p_day   IN   VARCHAR2)
      RETURN NUMBER
   IS
      l_day   NUMBER;
   BEGIN
      l_day := (CASE p_day
                   WHEN 'mon'
                      THEN 1
                   WHEN 'tue'
                      THEN 2
                   WHEN 'wed'
                      THEN 3
                   WHEN 'thu'
                      THEN 4
                   WHEN 'fri'
                      THEN 5
                   WHEN 'sat'
                      THEN 6
                   WHEN 'sun'
                      THEN 7
                END);
      RETURN l_day;
   END get_day_num;

--*********************************************
-- Type        : Procedure
-- Access      : Private
-- Name        : Get Day in Numeric
-- Parameters  : p_input_range sample Mon-Fri or Thu
--*********************************************
   PROCEDURE get_start_end_day (
      p_input_range   IN       VARCHAR2
    , p_start_day     OUT      NUMBER
    , p_end_day       OUT      NUMBER)
   IS
   BEGIN
      IF INSTR (p_input_range, '-') > 0
      THEN
         p_start_day := get_day_num (TRIM (LOWER (SUBSTR (p_input_range, 1, INSTR (p_input_range, '-') - 1) ) ) );
         p_end_day := get_day_num (TRIM (LOWER (SUBSTR (p_input_range, INSTR (p_input_range, '-') + 1) ) ) );
      ELSE
         p_start_day := get_day_num (TRIM (LOWER (SUBSTR (p_input_range, 1) ) ) );
         p_end_day := p_start_day;
      END IF;
   END get_start_end_day;

--*********************************************
-- Type        : Function
-- Access      : Private
-- Name        : Get Day in Numeric
-- Parameters  : p_input_range sample Mon-Fri or Thu
--*********************************************
   FUNCTION csv_to_row (
      p_data        IN   VARCHAR2
    , p_delimiter   IN   VARCHAR2)
      RETURN tab_vc4k
   IS
      l_tab   tab_vc4k;

      CURSOR c_get_csv_to_row (
         cp_data        VARCHAR2
       , cp_delimiter   VARCHAR2)
      IS
         WITH DATA AS
              (SELECT cp_data str
                 FROM DUAL)
         SELECT     TRIM (REGEXP_SUBSTR (cp_data, '[^' || cp_delimiter || ']+', 1, LEVEL) ) str
               FROM DATA
         CONNECT BY LEVEL <= regexp_count (cp_data, cp_delimiter) + 1;
   BEGIN
      OPEN c_get_csv_to_row (p_data, p_delimiter);

      FETCH c_get_csv_to_row
      BULK COLLECT INTO l_tab;

      CLOSE c_get_csv_to_row;

      RETURN l_tab;
   END csv_to_row;

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
      RETURN CLOB
   IS
      l_output_clob      CLOB;
      l_availablity_vc   VARCHAR2 (4000);
      l_time_slot        VARCHAR2 (30);
      l_start_time_vc    VARCHAR2 (10);
      l_end_time_vc      VARCHAR2 (10);
      l_start_day        NUMBER;
      l_end_day          NUMBER;
      l_start_time       NUMBER;
      l_end_time         NUMBER;
      l_periods_tab      tab_vc4k;
      l_day_list_tab     tab_vc4k;
   -- l_range_tab         tab_vc4k;
   BEGIN
--- Setting the Path for the new File
   EXECUTE IMMEDIATE'ALTER TABLE hotel_data_csv ' || p_filename || '';
      FOR recs IN (SELECT *
                     FROM hotel_data_csv
                    WHERE hotel_name IS NOT NULL)
      LOOP
         -- This will be the first Split.
         l_periods_tab := csv_to_row (recs.day_and_time, '/');

         FOR l_period IN 1 .. l_periods_tab.COUNT
         LOOP
            ---Spliting Start Time and End Time
            l_time_slot := SUBSTR (l_periods_tab (l_period), REGEXP_INSTR (l_periods_tab (l_period), '[0-9]', 1, 1, 0) );
            l_start_time_vc := REPLACE (TRIM (LOWER (SUBSTR (l_time_slot, 1, INSTR (l_time_slot, '-') - 1) ) ), ' ', '');
            l_end_time_vc := TRIM (LOWER (SUBSTR (l_time_slot, INSTR (l_time_slot, '-') + 1) ) );
            l_start_time := get_military_time (TRIM (l_start_time_vc) );
            l_end_time := get_military_time (TRIM (l_end_time_vc) );
            l_availablity_vc := SUBSTR (l_periods_tab (l_period), 1, REGEXP_INSTR (l_periods_tab (l_period), '[0-9]', 1, 1, 0) - 1);
            l_day_list_tab := csv_to_row (l_availablity_vc, ',');

            FOR day_range IN 1 .. l_day_list_tab.COUNT
            LOOP
               get_start_end_day (l_day_list_tab (day_range), l_start_day, l_end_day);

               INSERT INTO hotel_data_gtt
                    VALUES (recs.hotel_name
                          , l_start_day
                          , l_end_day
                          , l_start_time
                          , l_end_time);
            END LOOP;
         END LOOP;
      END LOOP;

      -- Based on How we decide to render it we can set the output to a collection object or just use dbms_output to display the name or write it to a file...
      l_output_clob := '';

      FOR output_rec IN (SELECT DISTINCT hd_hotel_name
                                    FROM hotel_data_gtt
                                   WHERE hd_hotel_start_day <= get_day_num (TRIM (LOWER (p_day) ) )
                                     AND hd_hotel_end_day >= get_day_num (TRIM (LOWER (p_day) ) )
                                     AND hd_hotel_start_time <= get_military_time (REPLACE (LOWER (p_time), ' ', '') )
                                     AND hd_hotel_end_time >= get_military_time (REPLACE (LOWER (p_time), ' ', '') ) )
      LOOP
         l_output_clob := l_output_clob || CHR (10) || output_rec.hd_hotel_name;
      END LOOP;

      RETURN l_output_clob;
   END find_open_restaurants;
END hotel_data_process_api;