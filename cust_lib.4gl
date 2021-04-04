 SCHEMA custdemo 

 FUNCTION display_custarr()

   DEFINE cust_arr DYNAMIC ARRAY OF RECORD
          store_num    LIKE customer.store_num,
          store_name   LIKE customer.store_name,
          city         LIKE customer.city,
          state        LIKE customer.state,
          zip_code      LIKE customer.zipcode,
          contact_name LIKE customer.contact_name,
          phone        LIKE customer.phone 
    END RECORD,
          cust_rec RECORD
          store_num    LIKE customer.store_num,
          store_name   LIKE customer.store_name,
          city         LIKE customer.city,
          state        LIKE customer.state,
          zip_code      LIKE customer.zipcode,
          contact_name LIKE customer.contact_name,
          phone        LIKE customer.phone 
    END RECORD,
    ret_num LIKE customer.store_num,
    ret_name LIKE customer.store_name,
    curr_pa SMALLINT
  
    OPEN WINDOW wcust WITH FORM "manycust"

    DECLARE custlist_curs CURSOR FOR
      SELECT store_num, 
            store_name,
            city, 
            state, 
            zip_code, 
            contact_name, 
            phone 
        FROM customer 
        ORDER BY store_num 

  
   CALL cust_arr.clear()
   FOREACH custlist_curs INTO cust_rec.*
      CALL cust_arr.appendElement()
      LET cust_arr[cust_arr.getLength()].* = cust_rec.*
   END FOREACH

   LET ret_num = 0
   LET ret_name = NULL

   IF (cust_arr.getLength() > 0) THEN 
      DISPLAY ARRAY cust_arr TO sa_cust.*
      
      IF NOT INT_FLAG THEN
         LET curr_pa = arr_curr()
         LET ret_num = cust_arr[curr_pa].store_num 
         LET ret_name = cust_arr[curr_pa].store_name 
      END IF
   END IF

   CLOSE WINDOW wcust 
   RETURN ret_num, ret_name 

 END FUNCTION 