function ssw_uniq_modes,index,taglist,mcount=mcount,info=info, $
   where_mode=where_mode, interactive=interactive, $
   nocount=nocount, multiple=multiple
;
;+      
;   Name:   ssw_uniq_modes
;
;   Purpose: identify uniq "modes" within structure/vector 
;
;   Input Parameters:
;      index - usually ssw structures, but any structure vector ok
;      taglist - list of tags to consider in definition of a "mode"
;
;   Output:
;      There are two possibilites:
;      1. Default: function returns string array of uniq modes
;            i.e., 1 line ascii tag summary for each
;      2. If where_mode is supplied:
;            return subscripts of index&info which match input mode
;         In conjunction with /INTERACTIVE switch, can be used for menu
;         selection of desired mode SS in a single call  
;
;   Kewyword Parameters:
;      mcount (output) - number of matches for each identified mode
;      info (output) - the mode string (via get_infox) vector for all index
;      where_mode - optional input - string of type 'info' - 
;         in that case, this function returns matching subcripts (index/info)
;      nocount - if set and /INTERACTIVE, do not show #matches for each mode
;      multiple - if set and /INTERACTIVE, allow multiple menu selects; def=1&exit
;      
;
;   Calling Examples/Context:
;      1. return uniq combos of specified taglist values
;      IDL> umodes=ssw_uniq_modes(index,'naxis1,naxis2,wavelnth,exptim',$
;                           mcount=mcount, info=info)
;
;      2. return subscripts (of index/info) which match given input mode
;         (in this case, where 'umodes(0)' is from call#1 above)
;      IDL> umss=ssw_uniq_modes(index,where_mode=umodes(0)) ; ss matching mode
;
;      3. /INTERACTIVE - returns SS for desired mode in single call
;         (recursively invokes 1. which is then presented via menu for select)
;      IDL> mss
;

;   History:
;      25-Oct-2006 - S.L.Freeland - ssw-generalization of 'sxi_umodes.pro'
;                    and 'trace_uniq_movies.pro'
;      Circa summer 2007 - made it a little better but forget details 
;
;   Method:
;      use 'get_infox' and tag list to get 1:1 string:structure
;      then 'all_vals' (uniq+sort+subscript) to return uniq 'modes'
;      e.g. trivial
;
;   Restrictions:
;     Would like to add FOV e.g. xcen/ycen -> carrington but not today...
;     Actually, this will work if the 'carrington' tag is added input
;     structures prior to call, so that is a different function. 
;
;

interact=keyword_set(interactive)

ssout=data_chk(where_mode,/string)

if not data_chk(taglist,/string) then $  ; try something but usually user input
        taglist='naxis1,naxis2,wavelnth,exptime'
case 1 of
   interact: begin 
      if not data_chk(index,/struct) then begin 
         box_message,'Need structure vector input ("index")...
         return,-1
      end
      umodes=ssw_uniq_modes(index,taglist,mcount=mcount)
      showmodes=umodes
      if not keyword_set(nocounts) then showmodes=showmodes + $
           '  ('+strtrim(mcount,2)+' matches)'
      ssm=xmenu_sel(showmodes,/one,tit='SELECT DESIRED MODE')
      if ssm(0) eq -1 then begin 
         box_message,'Nothing selected; bailing...
         return,ssm
      endif
      retval=ssw_uniq_modes(index,taglist,mcount=mcount,$
               where_mode=umodes(ssm(0)))
      
   endcase
   ssout: begin
      if not data_chk(info,/string)  then begin ; input?
         if not data_chk(index,/struct) then begin 
            box_message,'For WHERE_MODE use, need input INDEX and/or INFO'
            return,''
         endif else info=get_infox(index,taglist)  
      endif
      if n_elements(umodes) eq 0 then umodes=all_vals(info)
      retval=where(where_mode eq info) 
   endcase
   else: begin 
      if not data_chk(index,/struct) then begin
         box_message,'Need input structure vector...'
         return,''
      endif
         info=get_infox(index,taglist)
         umodes=all_vals(info)
         nmodes=n_elements(umodes)
         mcount=lonarr(nmodes)
         for i=0,nmodes-1 do mcount(i)=n_elements(where(info eq umodes(i)))
         retval=umodes 
      
   endcase
endcase
      

return,retval
end

