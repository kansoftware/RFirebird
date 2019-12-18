#' Firebird
#'
#' @name firebird
NULL
#' @rdname firebird
#' @export
set_fb_parameters = function( 
  path, 
  usr = 'sysdba', 
  pwd = 'masterkey', 
  host = 'localhost', 
  port = 3050, 
  driver_path = '~/Soft/jaybird/jaybird-full-2.2.9.jar',
  charSet = 'WIN1251' ) {
  require( data.table )
  data.table(  path, usr, pwd, host, port, driver_path, charSet )
}

#' @rdname firebird
#' @export
extract_fdb_file <- function( fdb_zip_path, extract_path = '.' ) {
  
  start = Sys.time()
  
  fdb_name <- unzip( fdb_zip_path, list = TRUE )[ 1, 'Name' ]
  fdb_path = paste( extract_path, fdb_name, sep = '/' )
  unlink( fdb_path )
  unzip( fdb_zip_path, fdb_name, exdir = extract_path, unzip = getOption( "unzip" ) )
  system( paste0( 'chmod 666 ',fdb_path ) )
  
  end = Sys.time()
  message( paste( fdb_zip_path, 'unzipped to', extract_path, 'in', format( round( end - start, 2 ) ) ) )
  
  return( fdb_path )
}

#' @rdname firebird
#' @export
fb_connect <- function( parameters ) {
  require( rJava )
  require( RJDBC )

  jdbcDriver <- JDBC( 'org.firebirdsql.jdbc.FBDriver', parameters$driver_path )
  url = parameters[, paste0( 'jdbc:firebirdsql:', host, '/', port, ':', path ) ]
  url = paste0(url, paste0('?columnLabelForName=true&encoding=',parameters$charSet))
  # jdbcConnection <- parameters[, dbConnect( jdbcDriver, url, usr, pwd )]
  jdbcConnection <- dbConnect( jdbcDriver, url, parameters$usr, parameters$pwd )
  
  return( jdbcConnection )
}

#' @rdname firebird
#' @export
format_date_time <- function( z, silent = TRUE ){
  
  require( StanTools )
  time_format = '\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.*'
  date_format = '\\d{4}-\\d{2}-\\d{2}$'
  time_columns = names( z )[ grepl( time_format, z[1] ) ]
  date_columns = names( z )[ grepl( date_format, z[1] ) ]
  # Sys.setenv(TZ = "MSK")
  for( column in time_columns ) z[, eval(column) := fastPOSIXct_tz( get(eval(column) ) , Sys.getenv("TZ") ) ]
  for( column in date_columns ) z[, eval(column) := as.Date( get(eval(column) ) ) ]
  if( !silent ) message( paste0( time_columns, date_columns, collapse = ', ' ), ' columns formatted' )
}

#' @rdname firebird
#' @export
fb_get_query <- function( query, connection_parameters, silent = TRUE ){
  start = Sys.time()
  
  fb_connection = fb_connect( connection_parameters )
  
  require( data.table )
  x <- dbSendQuery( fb_connection, query )
  z <- data.table( dbFetch( x ) )
  setnames( z, tolower( names( z ) ) )
  dbClearResult( x )
  
  # format_date_time( z, silent = silent )
  
  end = Sys.time()
  if( !silent ) message( paste( query, 'fetched in', format( round( end - start, 2 ) ) ) )
  
  dbDisconnect( fb_connection )
  return( z )
}

#' @rdname firebird
#' @export
fb_send_query <- function( query, connection_parameters, silent = TRUE ){
  start = Sys.time()
  
  fb_connection = fb_connect( connection_parameters )
  
  query = unlist( strsplit( query, split = ';', fixed = TRUE ) )
  for( i in 1:length( query ) ) try( dbExecute( fb_connection, query[ i ] ), silent = silent )
  
  end = Sys.time()
  if( !silent ) message( paste( 'query sent in', format( round( end - start, 2 ) ) ) )
  
  dbDisconnect( fb_connection )
}

#' @rdname firebird
#' @export
fb_list_tables <- function( connection_parameters ) {
  
  list_tables_query = 'SELECT a.RDB$RELATION_NAME FROM RDB$RELATIONS a WHERE RDB$SYSTEM_FLAG = 0 AND RDB$RELATION_TYPE = 0 order by 1'
  tables = fb_get_query( list_tables_query, connection_parameters )
  setnames( tables, 'table' )
  tables[,table := trimws( table ) ]
  return( tables )
}

#' @rdname firebird
#' @export
read_text_file = function( path ) {
  return ( paste( readLines( path ), collapse = '\n' ) )
}
