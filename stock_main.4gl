IMPORT FGL stock_query
IMPORT FGL cust_lib

{MAIN
    DEFER INTERRUPT 
    CONNECT TO "custdemo" USER "sa" USING "aman"
    CLOSE WINDOW SCREEN
    OPEN WINDOW w1 WITH FORM "arr_form"

    MENU "Stock"
    ON ACTION Get_Stock_Details
--    CLOSE WINDOW w1
--    OPEN WINDOW w2 WITH FORM "stock_form"
--        CALL query_stock()
       --CALL display_custarr()
         ON ACTION next 
      -- CALL fetch_rel_stock(1)
     ON ACTION previous 
       CALL fetch_rel_stock(-1)
     ON ACTION exit 
       EXIT MENU
   END MENU

    
END MAIN }
 SCHEMA custdemo 

 MAIN
   DEFINE store_num LIKE customer.store_num,
         store_name LIKE customer.store_name 

  DEFER INTERRUPT
  CONNECT TO "custdemo" USER "sa" USING "aman"
  CLOSE WINDOW SCREEN

  CALL display_custarr() 
           RETURNING store_num, store_name 
  DISPLAY store_num, store_name 

  DISCONNECT CURRENT

 END MAIN
