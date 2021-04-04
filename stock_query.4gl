SCHEMA custdemo 

 DEFINE  mr_stockrec RECORD
  stock_num    LIKE stock.stock_num,
  fac_code   LIKE stock.fac_code,
  description   LIKE stock.description,
  reg_price        LIKE stock.reg_price,
  promo_price         LIKE stock.promo_price,
  price_updated        LIKE stock.price_updated,
  unit     LIKE stock.unit

 END RECORD

 FUNCTION query_stock()
   DEFINE cont_ok     SMALLINT,
         stock_cnt     SMALLINT,
         where_clause STRING
   MESSAGE "Enter search criteria"
   LET cont_ok = FALSE 

   LET INT_FLAG = FALSE
   CONSTRUCT BY NAME where_clause 
      ON stock.stock_num,
         stock.fac_code
 

   IF (INT_FLAG = TRUE) THEN
     LET INT_FLAG = FALSE
     CLEAR FORM
     LET cont_ok = FALSE
     MESSAGE "Canceled by user."
   ELSE      
     CALL get_stock_cnt(where_clause)
       RETURNING stock_cnt 
     IF (stock_cnt > 0) THEN
       MESSAGE stock_cnt USING "<<<<", 
                  " rows found."
     CALL stock_select(where_clause)
       RETURNING cont_ok
     ELSE
       MESSAGE "No rows found."
       LET cont_ok = FALSE    
     END IF
   END IF

   IF (cont_ok = TRUE) THEN
     CALL display_stock()
   END IF

 END FUNCTION

 FUNCTION get_stock_cnt(p_where_clause)
   DEFINE p_where_clause STRING,
         sql_text STRING,
         stock_cnt SMALLINT

   LET sql_text = 
    "SELECT COUNT(*) FROM stock" || 
    " WHERE " || p_where_clause 

   PREPARE stock_cnt_stmt FROM sql_text 
   
   EXECUTE stock_cnt_stmt INTO stock_cnt 
   FREE stock_cnt_stmt 
 
   RETURN stock_cnt 
    
   END FUNCTION 

   FUNCTION stock_select(p_where_clause) 
   DEFINE p_where_clause STRING,
         sql_text STRING,
         fetch_ok SMALLINT

   LET sql_text = "SELECT stock_num, " ||
      " fac_code,description,reg_price,promo_price, " ||
      " price_updated,unit " ||
      " FROM stock WHERE " || p_where_clause ||
      " ORDER BY stock_num"
 
   DECLARE stock_curs SCROLL CURSOR FROM sql_text 
   OPEN stock_curs 
   CALL fetch_stock(1)   -- fetch the first row 
     RETURNING fetch_ok 
   IF NOT (fetch_ok) THEN
     MESSAGE "no rows in table."   
   END IF

   RETURN fetch_ok 
 
 END FUNCTION

  FUNCTION fetch_stock(p_fetch_flag)
   DEFINE p_fetch_flag SMALLINT,
             fetch_ok SMALLINT

   LET fetch_ok = FALSE
   IF (p_fetch_flag = 1) THEN
     FETCH NEXT stock_curs 
       INTO mr_stockrec.*
   ELSE
     FETCH PREVIOUS stock_curs 
       INTO mr_stockrec.*
   END IF

   IF (SQLCA.SQLCODE = NOTFOUND) THEN
     LET fetch_ok = FALSE
   ELSE
     LET fetch_ok = TRUE
   END IF

   RETURN fetch_ok 

 END FUNCTION

  FUNCTION fetch_rel_stock(p_fetch_flag)
   DEFINE p_fetch_flag SMALLINT,
         fetch_ok SMALLINT

   MESSAGE " "       
   CALL fetch_stock(p_fetch_flag)
     RETURNING fetch_ok 

   IF (fetch_ok) THEN
     CALL display_stock()
   ELSE
     IF (p_fetch_flag = 1) THEN
       MESSAGE "End of list"
     ELSE
       MESSAGE "Beginning of list"
     END IF
   END IF

 END FUNCTION

 FUNCTION display_stock()
   DISPLAY BY NAME mr_stockrec.stock_num,mr_stockrec.fac_code
   
    WHENEVER ERROR CONTINUE
    ## to close window w1 we have to deactivate the components of w1
        CLOSE WINDOW w1
        OPEN WINDOW w2 WITH FORM "stock_form"
         DISPLAY BY NAME mr_stockrec.*
        WHENEVER ERROR stop
 END FUNCTION
