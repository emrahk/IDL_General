;+
; Project     : SOHO - CDS
;
; Name        : XSTRUCT
;
; Purpose     : widget display of fields within an arbitrary structure
;
; Explanation :
;               Arranges structures in a matrix format with the tag
;               name in label widget and the tag value in a text widget.
;               If wbase and wtags exist, then widget is just updated
;               with input field values.
;
; Use         : xstruct,stc
;
; Inputs      : STC = structure name
;
; Keywords    :
;               NX = # of columns by which to arrange widgets (def=2)
;               WTAGS = text widget id's for each tag
;               WBASE = parent widget base into which place structure
;               GROUP = event id of widget that calls XSTRUCT
;               JUST_REG = if set, then just register widget
;               TITLE = optional widget title
;               XOFF, YOFF = offset of structure base relative to calling widget
;               EDITABLE = make fields editable
;               ALL = generate events without return key
;               XSIZE= text widget width [def = 10]
;               RECUR = signals that XSTRUCT is being called recursively
;               CENTER = center main base in screen (not relative to parent)
;               NOFF = do not offset main base
;               ACCEPT = name for accept button [def = commit]
;               RETURN = force hitting return key to accept edits
;               C_TAGS = array storing index of changed tags in structure
;
; Restrictions:
;     Input must be a structure.
;     Cannot yet safely handle arrays of structures or nested structures
;
; Category    : Widgets
;
; Written     : Zarro (ARC/GSFC) 20 August 1994
;
; Modified    :
;   28-Jan-2001, Kim Tolbert, fixed bug  (modified line with j=ij(1) to j=ij(1)-1)
;   21-Oct-2002, mimster@stars.gsfc.nasa.gov, String array modification and returns array of
;     index of changed tags
;   05-Aug-2004, Kim Tolbert, Sandhia Bansal, Two modifications:
;                - alphabetize the list of parameter tags
;                - use scroll bars when list is too long to fit the widget
;  Modified, 1-Mar-07, Zarro (ADNET) - cleaned up and removed EXECUTES
;  Modified, 22-Mar-2013, Kim Tolbert.  Changed calls to delvarx for wstruct and out_struct to
;                setting them to -1.  (If struct contains pointers, don't want to destroy them)
;  Modified, 23-Apr-2013, Kim Tolbert. Check for is_struct(wstruct) instead of exist (since now we're initting to -1)              
;-

pro xstruct_event,  event                        ;event driver routine

; added sortedIndx to get the new index of alphabetized list of tags - 08/05/04 - Sandhia Bansal
common xstruct_com,cwtags,wstruct,recur_base,out_struct, changed_tags, orig_tags, sortedIndx   ;added changed_tags

widget_control, event.id, get_uvalue = uservalue

if (n_elements(uservalue) eq 0) then uservalue=''
wtype=widget_info(event.id,/type)

;-- text events

if (wtype eq 3) and exist(cwtags) and is_struct(wstruct) then begin

 clook=where(cwtags eq event.id,cnt)          ;add index number of current event, Li
 clook = sortedIndx[clook]   ; get the new index based on alphabetized list of tags - 08/05/04 - Sandhia Bansal

 eve=where(changed_tags eq fix(clook[0]),cn)
 if (cn eq 0) then changed_tags=[changed_tags, fix(clook[0])]
 sz=size(cwtags)
 if cnt gt 0 then begin
  two_d=0b
  if sz[0] eq 2 then begin
   two_d=1b
   ij=get_ij(clook[0],sz[1])
   i=ij[0] & j=ij[1]              ;modified to subtract one 1/28/01, Kim
   field=wstruct[j].(i)
  endif else begin
   index=clook[0]
   field=wstruct.(index)
  endelse
  widget_control,event.id,get_value=value
  value=strcompress(strtrim(value,2))
  if n_elements(field) eq 1 then value=value[0] else begin  ;modified to allow string array modification, Li
    if is_string(field) then value=str2arr(value[0],delim='||') else value=str2arr(value[0],delim=' ')
  endelse
  if (1-is_struct(field)) then begin
   if two_d then wstruct[j].(i)=value else  wstruct.(index)=value
   catch,error
   if error ne 0 then begin
    print,!err_string
    catch,/cancel
   endif
  endif
 endif
endif

;-- button events

if wtype eq  1 then begin
 bname=strtrim(uservalue,2)
 if (bname eq 'done') or (bname eq 'abort') or (bname eq 'commit') then begin
  if bname eq 'abort' then begin
   changed_tags = [-1]
;   delvarx,out_struct
   out_struct = -1
  endif
  if bname eq 'commit' then begin
   out_struct=wstruct
  endif
  xtext_reset,cwtags
  xkill,recur_base
  xkill,event.top
 endif
endif
return & end

;------------------------------------------------------------------------------

pro xstruct,struct,nx=nx,just_reg=just_reg,group=group,editable=editable,$
            wbase=wbase,wtags=wtags,title=title,xoff=xoff,yoff=yoff,$
            noff=noff,instruct=instruct,_extra=extra,$
            modal=modal,xsize=xsize,recur=recur,all=all,center=center,$
            status=status,accept=accept,return_key=return_key, c_tags=c_tags

common xstruct_com

if (exist(nx)) then begin
 if (nx gt n_tags(struct)) then nx = (n_tags(struct))
endif

orig_tags  = n_elements(struct)

changed_tags = -1                ;modified to set changed_tags to empty, Li
err_mess='input must be a structure'
err=''
if not exist(struct) then err=err_mess
if not have_widgets() then begin
 message,'widgets unavailable',/cont
 return
endif

if (1-is_struct(struct)) then err=err_mess
if err ne '' then begin
 message,err,/cont
 return
endif

tags=tag_names(struct)
sortedIndx = sort(tags)   ;get indices to the alphabetized list of tags - 08/05/04 - Sandhia Bansal

ntags=n_elements(tags)

;-- keywords

editable=keyword_set(editable)
just_reg=keyword_set(just_reg)
recur=keyword_set(recur)
modal=keyword_set(modal)
all=1-keyword_set(return_key)
center=keyword_set(center)

;delvarx,out_struct
out_struct = -1

;if (not just_reg) and (not recur) then delvarx,recur_base,wstruct,cwtags
if (not just_reg) and (not recur) then delvarx,recur_base,cwtags
if (not just_reg) and (not recur) then wstruct = -1
if (editable) and (not just_reg) then wstruct=struct
if (just_reg) and (not exist(wtags)) then xkill,wbase
if n_elements(xoff) ne 0 then xoff_sav=xoff
if n_elements(yoff) ne 0 then yoff_sav=yoff
just_reg_sav=just_reg

nstruct=n_elements(struct)
last=nstruct-1

for i=0,last do begin

;-- JUST_REG all bases (except last) when more that one structure

 if (nstruct gt 1) then begin
  just_reg=0

  update=0 & delvarx,wbase,wtags
  if i eq last then begin
   if n_elements(just_reg_sav) ne 0 then just_reg=just_reg_sav else just_reg=0
  endif else just_reg=1
 endif

 update=min(xalive(wbase)) eq 1
 if update then begin
  if min(xalive(wtags)) eq 1 then begin
   if ntags ne n_elements(wtags) then begin
    xkill,wbase & update=0
   endif
  endif
 endif

 if not update then begin  ;-- make top level base

  if nstruct gt 1 then begin
   wtitle='XSTRUCT_('+strtrim(string(i),2)+')'
  endif else wtitle='XSTRUCT'

  ; To make the widget scrollable,
  ; modified the following statement to exclude the /column keyword.  /column along with
  ; /scroll keyword seems to make the size of the widget very small on unix sytsem.
  ; We now create another column widget just inside this one in xmatrix to create
  ; the buttons and title.  Below it we create another row widget to display the
  ; matrix in.

  wbase=widget_base(title=wtitle,/scroll,group=group)
  if not exist(recur_base) then recur_base=wbase else recur_base=[recur_base,wbase]

 endif

;-- put matrix of tags in second row

 xmatrix,struct[i],wbase,nx=nx,wtags=wtags,title=title,editable=editable,$
                   xsize=xsize,all=all,_extra=extra, $
                   accept=accept,just_reg=just_reg

if (orig_tags le 0) then begin
    print, 'Program cannot handle nested structures.'
    c_tags = -1
;    delvarx,out_struct
    out_struct = -1
    xtext_reset,cwtags
    xkill,recur_base
    status = 0
    return
endif else orig_tags = orig_tags-1
boost_array,cwtags,wtags

;-- realize and manage

 if not update then begin

  if (i eq 0) then begin
   if not keyword_set(noff) then $
    offsets=get_cent_off(wbase,group,valid=valid,wsize=wsize,screen=center,/nomap) else valid=0
   if valid and ((not exist(xoff)) or (not exist(yoff))) then begin
    xoff=offsets[0] & yoff=offsets[1]
   endif
  endif else begin
   if (exist(xoff)) and (exist(yoff)) then begin
    frac=.03
    xoff=xoff+frac*wsize[0]
    yoff=yoff+frac*wsize[1]
   endif
  endelse

  xrealize,wbase,xoff=xoff,yoff=yoff
  widget_control,wbase,event_pro='xstruct_event'
  if not just_reg then xmanager,'xstruct',wbase,just_reg=just_reg,no_block=1-editable,$
           modal=(i eq last)*modal

 endif else xshow,wbase

endfor

;-- restore initial parameters

if exist(xoff_sav) then xoff=xoff_sav
if exist(yoff_sav) then yoff=yoff_sav
if exist(just_reg_sav) then just_reg=just_reg_sav

if ((changed_tags[0] eq -1) and (n_elements(changed_tags) eq 1)) then begin

    c_tags = -1
    if is_struct(out_struct) then status=1 else status=0

endif else if (size(out_struct, /n_elements) le 1) then begin

    if (n_elements(out_struct) eq 1) then begin

       c_tags = changed_tags

       if is_struct(out_struct) then begin
         nelem=n_elements(c_tags)
         if (nelem gt 1) then begin
          for in=1, nelem-1 do begin
              index=changed_tags[in]
              if (same_data(out_struct.(index), struct.(index))) then c_tags=c_tags[rem_elem(c_tags, index)]
          endfor
         endif
         struct=out_struct
         status=1
       endif else begin
         status=0
         c_tags=-1
       endelse
       c_tags=c_tags[sort(c_tags)]
       if (n_elements(c_tags) gt 1) then c_tags = (c_tags[rem_elem(c_tags, -1)]) else c_tags = -1

    endif

endif else if (size(out_struct, /n_dimensions) le 1) then begin

    c_tags = changed_tags

    if is_struct(out_struct) then begin

       nelem=size(out_struct, /n_elements)
       nt=n_tags(out_struct)
       numt=n_elements( c_tags )
       if (numt gt 1) then begin

         if (n_elements(c_tags) gt 1) then c_tags = (c_tags[rem_elem(c_tags, -1)]) else c_tags = -1
         c_tags=c_tags[sort(c_tags)]
         cw = (c_tags/nt)
         cw = [[cw], [c_tags mod nt]]
         ; Same data check
         struc_nele = (n_elements(cw)/2)-1
         struc_in = 0
           while (struc_in le struc_nele) do begin
          if (same_data(out_struct[cw[struc_in,0]].(cw[struc_in,1]), struct[cw[struc_in,0]].(cw[struc_in,1]))) then begin
              if ((struc_in eq 0) and (struc_nele eq 0)) then begin
                 cw=-1
              endif else if (struc_in eq 0) then begin
                 cw=cw[struc_in+1:*,*]
              endif else if (struc_in eq struc_nele) then begin
                 cw=cw[0:struc_in-1,*]
              endif else begin
                 cw=[cw[0:struc_in-1,*],cw[struc_in+1:*,*]]
              endelse
              struc_in=struc_in-1
              struc_nele=struc_nele-1
          endif
          struc_in=struc_in+1
         endwhile
         c_tags=cw
       endif
       struct=out_struct
       status=1

    endif else begin
       status=0
       c_tags=-1
    endelse

endif else begin

    if arg_present(c_tags) then print, 'Keyword: c_tags is not compatiable with data structure.'
    c_tags = -1

end

if exist(recur_base) and (not just_reg) then wbase=recur_base

return & end
