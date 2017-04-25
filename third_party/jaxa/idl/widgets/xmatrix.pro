;+
; Project     : SOHO - CDS
;
; Name        : XMATRIX
;
; Purpose     : Widget display of fields within an arbitrary structure
;
; Use         : xmatrix,struct,wbase
;
; Inputs      :
;               STRUCT = input structure
;               WBASE = parent widget base into which place matrix
;
; Keywords    :
;               NX = # of columns by which to arrange widgets (def=2)
;               WTAGS = text widget id's for each tag
;               TITLE = optional widget title
;               EDITABLE = make fields editable
;               ALL      = generate events without return key
;               XSIZE = optional width for text widgets
;               LFONT = font for tag labels
;               TFONT = font for tag fields
; Procedure   :
;               Arranges structures in a matrix format with the tag
;               name in label widget and the tag value in a text widget.
;               If wbase and wtags exist, then widget is just updated
;               with input field values. This procedure is called by XSTRUCT
;
; Restrictions:
;               Input must be a structure.
;               WBASE must be a valid parent base
;
; Category    : Widgets
;
; Written     : Zarro (ARC/GSFC) 20 August 1994
;
; Modified    :
;       Version 2, Liyun Wang, GSFC/ARC, October 12, 1994
;          Made the WIDGET_LABEL right justified by using the 'fixed' font
;       Version 3, Zarro, (GSFC/ARC) 8 March, 1994
;          Added nested structure display
;       Version 4, Zarro, (GSFC/SM&A) 22 April 1999
;          Added pointer capability
;       Version 5, mimster@stars.gsfc.nasa.gov, (GSFC) 21 October 2002
;          Added capability to separate string array data members with '||' and modify.
;       Version 6, Sandhia Bansal, Alphabetized the list of parameter tags.
;       14-Dec-2004, Kim Tolbert - fixed problem where byte data
;                                  didn't show up in matrix
;       Modified, 1-Mar-07, Zarro (ADNET) - cleaned up and removed EXECUTES
;       Modified, 18-Nov-2009, Kim Tolbert. Previously aborted if found a nested
;         structure. Now just don't recurse for nested structures.  
;         Also, don't use valid_pointer, get_pointer - unreliable. Use ptr_chk and *. 
;       Modified 22-Mar-2013, Kim Tolbert.  Modified test for pointers.  Can only handle a scalar
;         pointer.  If array of pointers, just write 'multi pointer' in cell. Previously crashed.
;         Also, if string type and value is ..pointer, then make cell insensitive.
;-

   pro xmatrix,struct,wbase,nx=nx,wtags=wtags,title=title,editable=editable,$
               xsize=xsize,all=all,lfont=lfont,tfont=tfont,accept=accept, $
               just_reg=just_reg,_extra=extra


   blank = '                                                              '
   if (n_elements(struct) ne 1) or (1-is_struct(struct)) then $
      message,'input must be a 1-d structure'
   if n_elements(xsize) eq 0 then xsize=22
   tags=tag_names(struct)
   ntags=n_elements(tags)
   just_reg=keyword_set(just_reg)

   ; alphabetize the tags - 08/05/04 - Sandhia Bansal
   sortIndex = sort(tags)
   tags = tags[sortIndex]

   stc_name=tag_names(struct,/structure_name)
   if stc_name eq '' then stc_name=' '
   if n_elements(title) eq 0 then title=stc_name

   ; create a widget just inside the top one.  This was done to make the widget
   ; with correct size on the unix machine.  We use the size of this internal
   ; widget to determine the size for the top window.

   w1=widget_base(wbase,/column)

   ; install the buttons and title in the column widget
   if (not just_reg) then $
    xstruct_buttons, w1, editable=editable, accept=accept, title=title,_extra=extra

   ; create a row widget inside w1 for the matrix.

   w2=widget_base(w1, /row)

   if min(xalive(w2)) eq 0 then message,'define a top level parent base first'

   if n_elements(wtags) eq 0 then wtags=0l
   wtags=long(wtags)
   update=min(xalive(wtags)) ne 0

   if n_elements(nx) eq 0 then nx=2
   nx = nx > 1

;-- get tag definitions

   temp = ntags/nx
   if (nx*fix(temp) eq ntags) then ny = temp else ny=1+temp
   if ntags eq 1 then nx = 1

;-- make label and text widgets

   if (not update) then begin
      wtags=lonarr(ntags)
      row=widget_base(w2,/row,space=0)
      i = -1
      offset = 0
      for k=0,nx-1 do begin
         col=widget_base(row,/column,/frame, space=0)
         if (offset+ny) lt ntags then begin
            tail = (offset+ny)
            real_ny = ny
         endif else begin
            tail = ntags
            real_ny = ntags-offset
         endelse
         c_tags = tags[offset:(tail-1) < (ntags-1)]
         tag_len = strlen(c_tags)
         max_len = max(tag_len)
         for j=0, real_ny-1 do begin
            i=i+1
            if i ge ntags then break
            temp=widget_base(col,/row,space=0)
            c_tags[j] = c_tags[j]+':'+strmid(blank,0,max_len-tag_len[j])
            label=widget_label(temp,value=c_tags[j],font=lfont)
            wtags[i]=widget_text(temp,value=' ',editable=editable,$
                                all=all,xsize=xsize,font=tfont)
         endfor
         offset = offset+real_ny
         if (offset ge ntags) then break 
     endfor
   endif

;-- populate text widgets

made:
   if n_elements(wtags) ne ntags then begin
      message,'incompatibility between input structure tags and '+$
         'wbase widget base',/continue
      return
   endif

   i=-1
   for k=0,nx-1 do begin
      for j=0,ny-1 do begin
         i=i+1
         if i ge ntags then goto,done
         ;chk=valid_pointer(struct.(i),type)
         chk=ptr_chk(struct.(sortIndex[i]));,type)   ;use sortIndex to reference the correct
                                                         ; value in the alphabetized list - 08/05/04 -
                                                         ; Sandhia Bansal
         if chk[0] then begin
          ;field=get_pointer(struct.(sortIndex[i]),undef=undef)
          if ptr_exist(struct.(sortIndex[i])) then begin
            if n_elements(struct.(sortIndex[i])) gt 1 then field = 'multi pointer' else field = *struct.(sortIndex[i])
          endif else field='null pointer'
          ;if undef then field=struct.(sortIndex[i])
         ;endif else field=struct.(i)
         endif else field=struct.(sortIndex[i])

         ; modified to manage OBJECT data types.  For this type, the program will
         ; make the field un-editable and write a string "object" in the value field.
         case 1 of
            is_struct(field): begin
               widget_control,wtags[i],set_value='structure',sensitive=0
               message,'Skipping nested structure tag ' + tags[i] + '.  XSTRUCT can not handle nested structures.',/cont
;               xstruct,field,nx=nx,/just_reg,editable=editable,/recur,_extra=extra
            end
            (size(field))[0] gt 1 : begin
               widget_control,wtags[i],set_value='   >1d array  ',sensitive=0
            end

            else: begin
               case datatype(field) of
                   ; modified to add '||' between string array data members
                   'BYT' : widget_control,wtags[i],set_value=string(fix(field))
                   'STR' : begin
                     sensitive = ~(field[0] eq 'null pointer' or field[0] eq 'multi pointer')
                     widget_control,wtags[i],set_value=arr2str(field, '||'), sensitive=sensitive
                     end
                   'OBJ' : widget_control,wtags[i],set_value='   object  ',sensitive=0
                   'PTR' : widget_control,wtags[i],set_value='   pointer  ',sensitive=0
                    ELSE : widget_control,wtags[i],set_value=string(field)
               endcase
             end
         endcase
      endfor
   endfor
done:   wtitle=widget_info(w2,/child)

wtype=widget_info(wtitle,/type)
if wtype eq 5 then widget_control,wtitle,set_value=title

; resize the widget
device, get_screen_size=scrsize
max_xsize = .9*scrsize[0]
max_ysize = .9*scrsize[1]
wgeom = widget_info(wbase,/geom)
w1geom = widget_info(w1,/geom)
widget_control, wbase, ysize=(w1geom.ysize<max_ysize), xsize=(w1geom.xsize<max_xsize)


return & end
