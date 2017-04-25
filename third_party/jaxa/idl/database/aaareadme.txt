			      DATABASE Utilities

			  Last updated: 15 June 1994


This subdirectory contains the IDL procedures, mostly written by Don Lindler,
to create and access a database.    These database procedures are used by
both the UIT and HRS science teams.  The LaTex file DATABASE.TEX describes
the use of the database procedures, with an emphasis on astronomical
applications. 

The database procedures require the non-standard system variables
!PRIV, !TEXTOUT, and !TEXTUNIT.   These can be added to the IDL session 
using the procedure ASTROLIB.

On 1-Nov-1991 the database procedures were modified to expect item data
types to be recorded with the current IDL Version 2 codes, rather than
the old Version 1 codes.   In addition, the .dbc file has been renamed
to a .dbh file.   This means that databases created prior to 1-Nov-1991
must be updated with DBCREATE to work with the current software. 
Below is a sample program which can be used to update all the databases in a 
directory.

pro fixdb
!PRIV =2 
a = findfile('*.dbf')                 ;Find all databases
for i=0,N_elements(a)-1 do begin      ;Loop over all databases
   fdecomp,a(i),disk,dir,name         ;Decompose database name
   dbcreate,name                      ;Create .DBH file
endfor
return
end
   
The existing .dbc files can be deleted unless one is also using IDL V1
software on the same databases.

One difference between this software and the version found in the Astronomy
User's Library, is that external data representation is now supported.  See the
routine DBCREATE for details.  It is expected that these same modifications
will also be incorporated in the Astronomy User's Library in the near future.

===============================================================================

As of 21-Apr-95 the files are:

 
 
Directory:  /sohos1/cds/soft/util/database/
 
DB_ENT2EXT        - Converts database entry from host to external format.
DB_ENT2HOST       - Converts database entry from external to host format.
DB_INFO()         - Function to obtain information on opened data base file(s)
DB_ITEM           - Returns the item numbers and other info. for an item name.
DB_ITEM_INFO()    - Returns information on selected item(s).
DB_OR()           - Combine two vectors of entry numbers, removing duplicates.
DB_TITLES         - Print database name and title.  Called by DBHELP
DBBUILD           - Build a database by appending new values for every item.
DBCLOSE           - Procedure to close a data base file
DBCREATE          - Create new data base file or modify description.
DBDELETE          - Deletes specified entries from data base
DBEDIT            - Interactively edit specified fields in a database.
DBEDIT_BASIC      - Interactively edit specified fields in a database.
DBEXT             - Extract values of up to 12 items from data base file.
DBEXT_DBF         - Extract values of up to 12 items -- subroutine of DBEXT
DBEXT_IND         - routine to read a indexed item values from index file
DBFIND()          - Searche data base for entries with specified characteristics
DBFIND_ENTRY      - Performs an entry number search.  Subroutine of DBFIND.
DBFIND_SORT       - Limits the search using sorted values.
DBFPARSE          - Parse the search string.  Subroutine of DBFIND.
DBGET()           - Find entry number of fields with specified values.
DBHELP            - List available databases or items in current database
DBINDEX           - Procedure to create index file for data base
DBINDEX_BLK()     - Set associated variable in preparation for writing to file.
DBMATCH()         - Find entry number in a database for item values.
DBOPEN            - Routine to open an IDL database
DBPRINT           - Print specified items from a list of database entries
DBPUT             - Put new value for specified item into data base file entry.
DBRD              - Read an entry from a data base or linked multiple databases.
DBSEARCH          - Search a vector for specified values.  Subroutine of DBFIND.
DBSORT()          - Routine to sort list of entries in data base
DBTITLE()         - Function to create title line.  Subroutine of DBPRINT
DBUPDATE          - Update columns of data in a database  -- inverse of DBEXT
DBVAL()           - Extract value(s) of an item from a data base file entry.
DBWRT             - Procedure to update or add a new entry to a data base
DBXPUT            - Routine to replace value of an item in a data base entry
DBXVAL()          - Quickly return a value of the specified item number
UITDBLIB          - Add the system variables used by the UIT database library
