pro split_colortab, tables, ncolors, bottom, $
		    initialize=initialize, get=get, reverse=reverse, $
		    noload=noload, restore=restore, status=status, $
		    defined=defined
;+
;   Name: split_colortab
;
;   Purpose: simplify some split-color tables manipulations
;
;   Input Paramters:
;      table -   idl color table(s) 
;      ncolors - number of colors for each table - (def = !d.table_size/nt)
;      bottom  - (optional) bottom color indices - (should auto-bottom..)
;
;   Output Parameters
;      table   (if /get) - tables currently 'dealt with'
;      ncolors (if /get) - ncolors for each 'table'
;      bottom  (if /get) - bottom for each 'table'
;  
;   Keyword Parameters
;      get        (switch) - if set, RETURN  [table] , ncolors, bottom
;      initialize (switch) - zero out existing 'split_colortab' info      
;      restore    (switch) - if set, restore previous state
;      noload     (switch) - if set, dont load CTables (via loadct)
;      status     (switch) - if set, print current settings
;      defined    (output) - boolean "defined?" used with /GET
;  
;   Calling Sequence:
;      IDL> split_colortab, tables, ncs [,bottoms] [,/get] [,/init]
;
;   Calling Context:
;   IDL> split_colortab,[3,1,0],[50,25,120],/init,/status  ;<< SET split
;     ----------------------------------------------       ; w/3 tables
;    | Too many colors requested... clipping to 101 |      ; << !d.table_size
;     ----------------------------------------------
;     % LOADCT: Loading table B-W LINEAR                 
;     % LOADCT: Loading table BLUE/WHITE
;     % LOADCT: Loading table RED TEMPERATURE
;     -----------------------                               
;    | Table# NColors Bottom |                             ; < /STATUS info
;    | 3      50      0      |
;    | 1      25      50     |
;    | 0      101     75     |
;     -----------------------
;
;    IDL> split_colortab,1,nc,bot,defined=defined, /get  ; << readback scaling
;    IDL> if defined then print,nc,bot
;          25      50
;  
;   History:
;      16-April-1999 - S.L.Freeland
;-
common split_colortab_blk, tabtemplate, tabinfo, lasttabinfo

init=keyword_set(initialize) or n_elements(tabinfo) eq 0
loadem=1-keyword_set(noload)                             ; default is load


ntabin=n_elements(tables)                      ; number user input tables
ntables=50                                     ; ~number of RSI tables

if n_elements(tabtemplate) eq 0 then $
  tabtemplate={table:0l, referenced:0l, ncolors:0, bottom:0, reverse:0}

noncolors=n_elements(ncolors) eq 0

if init then begin
   tabinfo=replicate(tabtemplate,ntables)
   tabinfo.table=indgen(ntables)
   if noncolors and ntabin gt 0 then $
       ncolors=replicate(round(float(!d.table_size)/ntabin),ntabin)
endif

ssref=where(tabinfo.referenced,refcnt)
if keyword_set(get) then begin
  defined=0
  case 1 of
      refcnt eq 0: box_message,'No tables set yet...'
      ntabin eq 0: begin                     ; ALL referenced
         tables=tabinfo(ssref).table
	 ncolors=tabinfo(ssref).ncolors
         bottom=tabinfo(ssref).bottom
         defined=1
      endcase
      else: begin                                         ; SPECIFIC referenced
         delvarx, ncolors, bottom                         ; clear output
         ss=where_arr(ssref,tables,count)
         defined=intarr(ntabin)               ; boolean
         if count eq 0 then begin
	    box_message,'Requested tables not set yet...'
         endif else begin
            tables=tabinfo(ssref(ss)).table
            ncolors=tabinfo(ssref(ss)).ncolors
            bottom=tabinfo(ssref(ss)).bottom
            defined(ss)=1
	 endelse
         if n_elements(defined) eq 1 then defined=defined(0) ; scalarize
      endcase
   endcase
endif  else begin 
   lasttabinfo=tabinfo                         ; save for /restore operation

   ntabin=n_elements(tables)
   ncin=n_elements(ncolors)   
   if ntabin eq 0 or (ntabin ne ncin) then begin
   ; ??? 
   
   endif else begin 
      gotbot=n_elements(bottom) eq ntabin
      if not gotbot then begin
        ssmax=(where(tabinfo.bottom eq max(tabinfo.bottom)))(0)
	bottom=(tabinfo(ssmax).bottom+tabinfo(ssmax).ncolors)>0
      endif
;     Load new information->structure
      for i=0, n_elements(tables)-1 do begin
         tabinfo(tables(i)).ncolors=ncolors(i)            ; ncolors
         tabinfo(tables(i)).referenced=1                  ; enabled flag
         if gotbot then bot=bottom(i) else bot=bottom
	 tabinfo(tables(i)).bottom=bot                    ; bottom
	 bottom=bottom+ncolors(i)                         ; increment floor
      endfor	 
      ssref=where(tabinfo.referenced,refcnt)
;     check for table overrun
      if refcnt gt 0 then begin
         over=where(tabinfo(ssref).bottom + $
		    tabinfo(ssref).ncolors gt !d.table_size,ocnt)
	 if ocnt gt 0 then begin
            clip=!d.table_size-tabinfo(ssref(over)).bottom
	    if not noncolors then box_message,'Too many colors requested... clipping to ' + strtrim(clip,2)
	    tabinfo(ssref(over)).ncolors=clip
	 endif
      endif
      for i=0,refcnt-1 do begin
         ss=ssref(i)
	 if loadem then loadct,tabinfo(ss).table, bottom=tabinfo(ss).bottom, $
	                     ncolors=tabinfo(ss).ncolors
      endfor
   endelse
endelse

if keyword_set(status) then begin
  if refcnt eq 0 then box_message,'No tables set yet...' else begin
     reftab=tabinfo(ssref)                                    ; referenced
     reftab=reftab(sort(reftab.bottom))                       ; bot->top
     refnum=strjustify(['Table#', strtrim(reftab.table,  2)])     
     refcol=strjustify(['NColors',strtrim(reftab.ncolors,2)])
     refbot=strjustify(['Bottom' ,strtrim(reftab.bottom, 2)])
     out=refnum+' ' + refcol+ ' ' + refbot
     box_message,out
  endelse
endif  

return
end
