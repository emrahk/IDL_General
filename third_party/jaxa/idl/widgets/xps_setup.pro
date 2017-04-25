;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       XPS_SETUP
;
; PURPOSE:
;       Widget interface to PS
;
; CATEGORY:
;       Utitlity, widget
;
; EXPLANATION:
;
; SYNTAX:
;       xps_setup,ps_setup
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       PS_SETUP - PS parameter structure for setting up the PS device. If it
;                is not defined when the routine is called, it will 
;                be defined by the routine. It may be modified upon exiting
;                from the program. It should have the following tags:
;
;                FILENAME     - Name of PS file. Default: idl.ps
;                PORTRAIT     - 1 for portrait, 0 for landscape
;                COLOR        - 0/1 indicating if color plot is needed
;                ENCAPSULATED - 0/1 indicating if EPS file is needed
;                COPY         - 0/1 indicating whether to copy the current
;                               color table to the PostScript device
;                INTERPOLATE  - 0/1 indicating whether to interpolate the
;                               current color table to the PostScript device
;
;                Note: COPY and INTERPOLATE are only meaningful when
;                      COLOR is set. Both cannot be set.
;
; OUTPUTS:
;       PS_SETUP - PS parameter structure
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       INITIAL - Create the PS_SETUP structure without popping up the
;                 widget if set
;       GROUP   - ID of the widget who serves as a group leader
;       FONT    - optional font for labels
;       STATUS - 0/1 for Cancel/Accept option
; COMMON:
;       XPS_SETUP: contains most recent setup structure
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, October 6, 1995, Liyun Wang, GSFC/ARC. Written
;       Version 2, November 13, 1996, Liyun Wang, NASA/GSFC
;          Modified such that copied color table is the default
;             selection when choosing to print in COLOR
;       Version 3, July 17, 1999, Zarro (SM&A/GSFC)
;          Added call to PS_FORM to configure DEVICE
;       Version 4, Oct 17, 1999, Zarro (SM&A/GSFC)
;          Made IDL versions 4 and 5 compatible
;       Modified, 1 March 2007, Zarro (ADNET) 
;          - moved group and modal to main widget_base
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
;---------------------------------------------------------------------------
;  Event handler
;---------------------------------------------------------------------------
pro xps_setup_event, event

   child=widget_info(event.top,/child)
   widget_control,child, get_uvalue = unseen
   info=get_pointer(unseen,/no_copy)
   if datatype(info) ne 'STC' then return 
   widget_control, event.id, get_uvalue = uvalue
   quit_flag=0

;-- force widget to foreground

   if (uvalue eq 'PUSH') then begin
    xshow,event.top
    widget_control,event.top,timer = 1
   endif

   case (uvalue) OF

      'DONE': begin
         info.status = 1
         widget_control, info.fname, get_value=str
         fname=trim(str(0))
         widget_control,info.fname, set_value=fname
         if fname eq '' then pfile=concat_dir(getenv('HOME'),'idl.ps') else $
          pfile=fname
         break_file,pfile,dsk,direc,name
         path=dsk+direc
         if trim(path) eq '' then cd,curr=path
         chk=test_open(path,err=err,/quiet,/write)
         if chk eq 0 then begin
          xack,['No priviledge writing postscript file to specified directory: '+path,$
                'Please change output file location.'],group=event.top,/icon
         endif else begin
          info.ps_stc.filename = pfile
          if info.ps_stc.hard then info.ps_stc.encapsulated = 0
          quit_flag=1
         endelse
      end

      'CONFIG': begin
        temp=info.ps_stc
        rem_tags=['portrait','copy','interpolate','hard','printer','delete']
        temp=rem_tag(temp,rem_tags)
        extra=ps_form(_extra=temp,parent=event.top,/no_file)
        if datatype(extra) eq 'STC' then begin
         temp=info.ps_stc
         copy_struct,extra,temp
         info.ps_stc=temp
         info.ps_stc.portrait=1-info.ps_stc.landscape
         info.ps_stc.xoffset=extra.xoff
         info.ps_stc.yoffset=extra.yoff
         widget_control,info.cbt(0),set_button=extra.color
         widget_control,info.ccbase,sensitive=extra.color
        endif
       end

      'QUIT': begin
         info.status = 0
         quit_flag=1
      end

      'TO_FILE': begin
         info.ps_stc.hard = 0
         widget_control, info.dbase,sensitive=0
         widget_control, info.hbase,sensitive=0
      end

      'PRINTER': begin
         info.ps_stc.hard = 1
         widget_control, info.dbase,sensitive=1
         widget_control, info.hbase,sensitive=1
      end

      'PFILE': begin
        title='Select Output Postscript Filename'
        tfile=info.ps_stc.filename
        break_file,tfile,dsk,direc,name,ext
        path=dsk+direc
        if strtrim(path,2) eq '' then cd,curr=path
        fname=name+ext
        if trim(fname) eq '' then fname='idl.ps'
        fname=concat_dir(path,fname)
        xinput,fname,'Enter output postscript filename:  ',$
         group=event.top
        info.ps_stc.filename=fname
        widget_control,info.fname,set_value=fname
       end

      'FNAME': begin
         widget_control, info.fname, get_value=str
         info.ps_stc.filename = str(0)
       end

      'PSELECT': begin
        xsel_printer,que,status=status,group=event.top,def=info.ps_stc.printer
        IF status then begin
         info.ps_stc.printer = que
         widget_control, info.pname, set_value=que
        endif 
      end

      'DFILE': info.ps_stc.delete=event.select
      'PORT': info.ps_stc.portrait = event.select
      'LAND': info.ps_stc.portrait = 1-event.select
      'COLOR': begin
        info.ps_stc.color = event.select
        widget_control,info.ccbase,sensitive=event.select
       end
      'ENCAP': info.ps_stc.encapsulated = event.select
      'COPY': begin
        info.ps_stc.copy = event.select
        if event.select then begin
         info.ps_stc.interpolate =0
         widget_control,info.pbt(1),set_button=0
        endif
       end
      'INTER': begin
        info.ps_stc.interpolate = event.select
        if event.select then begin
         info.ps_stc.copy =0
         widget_control,info.pbt(0),set_button=0
        endif
       end
      else:
   endcase

   if quit_flag then begin
    xtext_reset,info
    xkill,event.top
   endif
   set_pointer,unseen,info,/no_copy

   return & end

;---------------------------------------------------------------------------
;  Main Program
;---------------------------------------------------------------------------

pro xps_setup, ps_setup, group=group, initial=initial,font=font,$
               status=status

   common xps_setup,ps_setup_com
   common xsel_printer,last_choice

;-- initialize

   status=0
   cd,curr=curr
   ok=test_open(curr,/write,/quiet)
   if not ok then curr=getenv('HOME')
   def_file=concat_dir(curr,'idl.ps')
   if os_family() eq 'vms' then def_prn='SYS$PRINT' else def_prn='lpr'

   ps_setup_def= {filename:def_file, portrait:0, color:0, encapsulated:0,$
                copy:1, interpolate:0, hard:1, printer:def_prn,delete:0,$
                landscape:1,xsize:7.,ysize:5.,inches:1,bits_per_pixel:8,$
                xoffset:1.,yoffset:3.}

   if keyword_set(initial) then begin
     ps_setup=ps_setup_def & return
   endif

   xkill,'xps_setup'

   if datatype(ps_setup_com) ne 'STC' then ps_setup_com=ps_setup_def
   get_from_com=0
   if (datatype(ps_setup) eq 'STC') then begin
    if not match_struct(ps_setup,ps_setup_def,/tag) then get_from_com=1
   endif else get_from_com=1
   if get_from_com then ps_stc=ps_setup_com else ps_stc=ps_setup
   if not match_struct(ps_stc,ps_setup_def,/tag) then ps_stc=ps_setup_def
   ps_stc.landscape=1-ps_stc.portrait

;-- retrieve last printer

   get_def_printer,last_printer
   if last_printer ne '' then ps_stc.printer=last_printer

   if datatype(font) eq 'STR' then lfont=font
   mk_dfont,bfont=bfont,lfont=lfont,tfont=tfont

   base = widget_mbase(title='XPS_SETUP', /column,uvalue='PUSH',group=group,/modal)

   temp = widget_base(base, /row, /frame)
   tmp = widget_button(temp, value='Accept', font=bfont, uvalue='DONE',/no_rel)
   tmp = widget_button(temp, value='Cancel', font=bfont, uvalue='QUIT',/no_rel)

;-- print options

   temp = widget_base(base, /row, /frame)
   xmenu2, ['Save to file', 'Send to printer'], temp, /exclusive, $
      button=hbt, font=bfont, uvalue=['TO_FILE','PRINTER'], /no_release
   IF ps_stc.hard then $
      widget_control, hbt(1), /set_button $
   else $
      widget_control, hbt(0), /set_button

   temp = widget_base(base,/column,/frame)

   fbase = widget_base(temp, /row)
   tmp1 = widget_button(fbase, value='Filename:',font=bfont,uvalue='PFILE',/no_rel)
   fname = widget_text(fbase, value=ps_stc.filename, xsize=30, font=tfont,$
                      /edit, uvalue='FNAME')

   hbase = widget_base(temp, /row)
   tmp1 = widget_button(hbase, value='Printer: ', font=bfont,uvalue='PSELECT',/no_rel)
   pname = widget_text(hbase, value=ps_stc.printer, xsize=30, font=tfont)
   widget_control,hbase,sensitive=ps_stc.hard
                                        
   dbase= widget_base(temp,/row)
   xmenu2,['Delete file after print'],dbase,/row,/nonexclusive,font=bfont,$
      uvalue='DFILE',buttons=dbt
   widget_control, dbase, sensitive=ps_stc.hard
   widget_control,dbt(0),set_button=ps_stc.delete
                                        
;-- color options

   cbase=widget_base(base,/column,/frame)
   temp=widget_base(cbase,/row)
   cbutt=widget_button(temp,value='Configure Output',font=bfont,$
                       uvalue='CONFIG')

   xmenu2,['Color Plot'],temp,/row,/nonexclusive,font=bfont,$
      uvalue='COLOR',buttons=cbt
                             
   ccbase=widget_base(cbase,/row)           
   xmenu2, ['Copy','Interpolated'], ccbase, /exclusive, font=bfont, button=pbt,$
    uvalue=['COPY','INTER'],/row,title='Color Table:'
   widget_control, pbt(0), set_button=ps_stc.copy
   widget_control, pbt(1), set_button=ps_stc.interpolate

   widget_control, ccbase, sensitive=ps_stc.color
   widget_control,cbt(0),set_button=ps_stc.color


;-- center base

   xrealize,base,group=group,/center

   info = {ps_stc:ps_stc, hbase:hbase, cbase:cbase, pname:pname, $
           fname:fname, status:0 ,dbase:dbase,pbt:pbt,cbt:cbt,ccbase:ccbase}

   make_pointer,unseen
   set_pointer,unseen,info,/no_copy
   child=widget_info(base,/child)
   widget_control,child, set_uvalue = unseen

;-- start timer event for pushing main widget to foreground

   if timer_version() then widget_control,base, timer=1

   xmanager, 'xps_setup', base
   
   info=get_pointer(unseen,/no_copy)
   free_pointer,unseen
   xshow,group

   if datatype(info) eq 'STC' then status= info.status else status=0
   if status then begin
    ps_setup_com=info.ps_stc
    ps_setup=info.ps_stc
    dsave=!d.name
    set_plot,'ps'
    rem_tags=['copy','interpolate','hard','printer','delete']
    ds_setup=rem_tag(ps_setup,rem_tags)
    device,_extra=ds_setup
    set_plot,dsave    
   endif
   return
   end

