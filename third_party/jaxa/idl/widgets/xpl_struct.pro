;+
; Project     : SOHO - CDS     
;                   
; Name        : XPL_STRUCT
;               
; Purpose     : Explain STRUCTURE tags by browsing help files
;               
; Explanation : A pulldown menu is created representing all the
;		levels of "introspection" of a structure variable.
;
;		If a tag in a structure is an array, it's "expanded"
;		if it's less than SIZE, which by default is set to 30.
;
;		The tags of the structure are linked to their tag names
;		and their parent structure names, i.e.,
;		
;			STC.TAG     ; Tag named "TAG" in structure "STC"
;		or      .TAG        ; Tag named "TAG" in anonymous structure.
;
;		These combinations are used to look up help texts via
;		WIDG_HELP, and display them on the screen.
;
; Use         : XPL_STRUCT, DATA_STRUCTURE
;    
; Inputs      : DATA_STRUCTURE: Any IDL structure.
;               
; Opt. Inputs : None.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : ON_BASE : The widget base to put the pulldown button on.
;		SIZE    : The maximum size of "expanded" arrays
;		FILE    : The data file to inspect for help texts.
;			  Default "struct_tags.hlp"
;		TITLE   : The title to be associated with the pulldown button
;		NOHELP  : Turn off the help facility (behaves like DSP_STRUCT)
;
; Calls       : DATATYPE(), NTRIM(), TRIM(), WIDG_HELP
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: During development, XDOC suddenly wouldn't work.
;		Could not reproduce it...
;               
; Category    : CDS, UTILITY, STRUCTURE
;               
; Prev. Hist. : Based on DSP_STRUCT
;		Added some more "intelligent" handling of arrays
;
; Written     : SVHH, 16-May-1995
;               
; Modified    : Version 2, SVHH, UiO, 27 February 1996
;                         Using NTRIM to avoid BYTE->STRING
;                         conversion.
;               Version 3, SVHH, UiO, 28 February 1996
;                         Using the /hierarchy flag in calling widg_help
;               Version 4, SVHH, UiO, 1 March 1996
;                         Using fixed font for widg_help topics
;               Version 5, SVHH, UiO, 2 October 1996
;                         Splitting long lists of tags into sub-lists.
;                         
; Version     : 5, 2 October 1996
;-            

PRO xpl_array,arr,menu=menu,elem=elem,Size=Size,ppp=ppp
  IF N_elements(elem) eq 0 THEN	elem = '"('
  sz = Size(arr)
  FOR i=0, (sz(1)-1)<size DO BEGIN
      item = reform(arr(i,*,*,*,*,*,*))
      menuline = elem+trim(i)+')'
      IF (Size(arr))(0)	gt 1 THEN BEGIN
	  menu = [menu,menuline+'"{']
	  xpl_array,item,elem=elem+trim(i)+',',Size=Size,ppp=ppp,menu=menu
      END ELSE IF datatype(item) eq 'STC' THEN BEGIN
	  menu = [menu,menuline+'" {']
	  xpl_struct,item,menu=menu,Size=Size
      END ELSE BEGIN
	  menu = [menu,menuline	+' = '+ntrim(item(0))+'"'+ ppp] 
      END
  EndFOR
  
  menu = [menu,'}']
END



PRO xpl_catch_event,event
  Widget_CONTROL,event.id,Get_UVALUE=uvalue
  widget_control,event.handler,get_uvalue=file
  
  IF uvalue eq 'QUIT' THEN begin
	Widget_CONTROL,event.top,/destroy
	return
  end

;  help,uvalue

  if datatype(uvalue) eq 'STR' and datatype(file) eq 'STR' then $
	widg_help,file,subtopic=uvalue,/hierarchy,tfont='fixed'

END




PRO xpl_struct,str,menu=menu,Size=Size,$
			title=title,on_base=on_base,file=file,nohelp=nohelp
  on_error,2
  if N_params() ne 1 then message,"Use: XPL_STRUCT,ANY_STRUCT"
  if datatype(str) ne 'STC' then message,"Parameter must be a structure"
  
  if !debug then on_error,0

  if N_elements(file) eq 0 then file='struct_tags.hlp'
  if keyword_set(nohelp) then file=0

  ntagsmax = 20
  
  names	= tag_names(str)
  tag =	0
  menuowner = 1
  

  IF N_elements(Size) eq 0 THEN	Size = 30
  
  IF N_elements(menu) gt 0 THEN	menuowner = 0

  if N_elements(str) gt 1 then begin
	stc_name = tag_names(str,/structure)
	if stc_name eq '' then stc_name = 'Anonymous'
	title = ''
	sz = size(str)
	menuline = '"Structure: '+stc_name+'('
	for i=1,sz(0) do begin
	   menuline=menuline+trim(sz(i))
	   if i lt sz(0) then menuline=menuline+','
	endfor
	menuline=menuline+')" {'
	menu=[menuline]
	xpl_array,str,size=size^(1./sz(0)),menu=menu
	GOTO,SKIP
  endif


  pp = tag_names(str,/struct)
  IF pp NE '' THEN BEGIN
     pp = byte(pp)
     pp = STRING(pp(WHERE(pp LT 48 OR pp GT 57)))
  END
  
  ntags = n_elements(names)
  
  FOR i=0,ntags-1 DO BEGIN
     IF ntags GT ntagsmax THEN BEGIN
        IF i MOD ntagsmax EQ 0 THEN BEGIN
           IF i NE 0 THEN BEGIN
              menu = [menu,"}"]
           END
           entry = '"Tags '+trim(i)+' - '+trim((i+ntagsmax-1) < ntags)+'" {'
           IF N_elements(menu) EQ 0 THEN menu = [entry] $
           ELSE menu = [menu,entry]
        END
     END
     
      r	= execute("tag = str."+names(i))
      ppp = pp + "." + names(i)

      menuline = '"'+names(i)
      
      dtype = datatype(tag)
      
      IF N_elements(tag) eq 1 THEN BEGIN
	  IF dtype eq 'STC' THEN BEGIN
	      menuline=menuline	+ '('+ tag_names(tag,/structure)+")""  {"
	      IF N_elements(menu) gt 0 THEN menu = [menu,menuline] $
	      ELSE			    menu = menuline
	      menu = [menu,'"<-----'+names(i)+'" '+ppp]
	      xpl_struct,tag,menu=menu,Size=Size
	  END ELSE BEGIN
	      menuline = menuline + ' = ' +ntrim(tag) +'"' ; "
	      IF N_elements(menu) gt 0 THEN menu = [menu,menuline] $
	      ELSE			    menu = menuline
	  END
      END ELSE BEGIN
	  IF dtype eq 'STC' THEN $
		  menuline = menuline+'('+tag_names(tag,/structure)+')'
	  menuline = menuline +	'('
	  sz = Size(tag)
	  Ndims	= sz(0)
	  FOR d	= 1,Ndims DO BEGIN
	      menuline = menuline + trim(sz(d))
	      IF d ne ndims THEN menuline = menuline+','
	  EndFOR
	  menuline = menuline+')'
	  
	  IF sz(0) gt 0	 THEN BEGIN
	      menuline = menuline + '" {'		   ; "
	      IF N_elements(menu) gt 0 THEN menu = [menu,menuline] $
	      ELSE			    menu = menuline
	      menu = [menu,'"<-----'+names(i)+'" '+ppp]
	      xpl_array,tag,menu=menu,Size=Size^(1./sz(0)),ppp=ppp
	  END ELSE BEGIN
	      menuline = menuline + '"'	; "
	      IF N_elements(menu) gt 0 THEN menu = [menu,menuline] $
	      ELSE			    menu = menuline
	  END
      END
      
      IF menu(N_elements(menu)-1) NE '}' THEN $
         menu(N_elements(menu)-1) = menu(N_elements(menu)-1)+"  "+ppp
  EndFOR
  
  IF ntags GT ntagsmax THEN menu = [menu,"}"]
     
  IF not menuowner THEN	BEGIN
     menu = [menu,"}"]
     return
  END

SKIP:
  
  IF N_elements(title) eq 0 THEN BEGIN
      title = tag_names(str,/structure_name)
      IF title eq '' THEN title	= 'Anonymous'	$
      ELSE title = 'Structure: '+title
  EndIF
  
  ix = where(strpos(menu,'"') gt -1)		     ; "
  len =	strpos(strmid(menu(ix),1,1000),'"')	   ; "
  maxw = max(len)
;  FOR i=0,N_elements(ix)-1 DO begin
;      menu(ix(i)) = strmid(menu(ix(i)),0,len(i)+1) + $
;		    strmid("                       ",0,maxw-len(i)) + $
;	            strmid(menu(ix(i)),len(i)+1,1000) 
;  endfor  

  IF N_elements(on_base) eq 0 THEN BEGIN
      base = Widget_BASE(title='XPL_STRUCT',/column,event_pro="xpl_catch_event")
      if N_elements(str) eq 1 then menu = [ '"'+title+'" {', menu, '}' ]
      dummy = Widget_BUTTON(base,value='Quit',uvalue='QUIT')
      XPdMenu,menu,base,/column
      Widget_CONTROL,base,/realize
      widget_control,base,set_uvalue=file
      Xmanager,"xpl_struct",base,event_handler="xpl_catch_event"
  END ELSE BEGIN
      localbase=Widget_BASE(on_base,event_pro="xpl_catch_event",/row)
      menu=['"'+title+'"{',menu,'}']
      widget_control,localbase,set_uvalue=file
      XPdMenu,menu,localbase
  END
  
END
