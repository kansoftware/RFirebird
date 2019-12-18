source("firebird_linux.R")
connection2db <- set_fb_parameters(
  path = 'MYSITE.FDB',
  driver_path = '~/Soft/Jaybird-3.0.8/jaybird-full-3.0.8.jar' )
comments_data <- fb_get_query( paste0("select * from COMMENTS;"), connection2db, T )


connection2db_2 <- set_fb_parameters(
              path = 'tradebot14',
              host = '172.17.76.75',
              driver_path = '/home/wellington/Soft/Jaybird-2.2.15/jaybird-full-2.2.15.jar' )
bots_data <- fb_get_query( paste0("select * from PARAM_BOTS;"), connection2db_2)


connection2db_3 <- set_fb_parameters( path = "tradebot5" )
lSQL <- "UPDATE PARAM_BOT_PAIRTRADING SET COEF_ANCHOR = NULL, MAINPRICE=NULL, ANCHORPRICE=NULL WHERE botid like '%_Q%' and TICKER_ANCHOR='USD';"
fb_send_query( lSQL, connection2db_3 )
