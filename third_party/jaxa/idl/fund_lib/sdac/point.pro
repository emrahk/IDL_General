
pro point_continue, set=set

common point_common, just_continue

just_continue = fcheck(set, 1)
if just_continue ne 1 then just_continue = 0

end

;+
; Project     : SDAC
;                   
; Name        : POINT
;
; USE         : 
;       POINT,X,Y,[/DEVICE],[/NORMAL],[/DATA] [,npoints=npoints] [,/nocrossbar] $
;       [,newlabel=newlabel] [,/widget],[,/continue] [,/compile] $
;       [buttons=buttons, val_buttons=val_buttons, mess_wedg=mess_widg] $
;       [,xoffset=xoffset] [,yoffset=yoffset], $
;       [drawline=drawline, thick=thick, color=color, linestyle=linestyle]
; EXAMPLES:
;        point, x, npoint=1, newlabel= newlabel, color=color, thick=2, /draw, /linestyle, $
;        xoffset = xoffsets(0), yoffset=yoffsets(0), $
;        continue = (n_elements(iselect)-1) < 1, $
;        buttons = ['Continue by Selecting from Plot Window','DONE'], val_but=['X','F']
;
; INPUTS:
;       none.
; OUTPUTS:
;       X & Y - x and y values of points selected by cursor.
;
; PROCEDURE   :
; Call up CURSOR. When operator presses a key, over plot a cross bar 
; and print x and y data values on the screen.  User should hold down
; cursor until they receive feedback using crossbar or draw options.
;
; CALLS:
; FCHECK, F_USE_WIDGET, GETUT, GRAPHICS_PAGE, ANYTIM, ATIME, CRANGE, RESPOND_WIDG 
; 
; KEYWORD INPUTS:
;       /DATA is the default mode or /NORMAL or /DEVICE, usual graphics meaning.
;       npoints - return after selecting n points
;       /nocrossbar - don't plot the cross bar
;       newlabel - supply dialogue for the screen
;       /widget - throw up widget buttons to control x type and exit
;       /continue - with widget option only, don't show widget controls
;                   until user moves cursor outside of graphics window
;       /drawline - draw lines from top to bottom of plot window on marked points
;       keywords supporting drawline:
;               thick, color, linestyle
;       xoffset - pixel offset for respond_widg base
;       yoffset - 
;       /compile- code is compiled, but no action taken
;       /help   - Helpful information sent to normal output.
;       mess_widg - message on control widget
;       buttons - button labels for widget controls
;       val_buttons - meaning attacted to buttons 
;                     'X' - print as x and continue
;                     'T' - print as time and continue
;                     'F' - done                      
;               must be the same number of val_buttons as buttons!
; COMMON BLOCKS:
;       POINT_COMMON
; restrictions:
;       if the return command is given before selecting any points,
;       then x and y are returned as the strings 'null'
;       widgets only enabled for x windows graphics
;
;       widget interface uses f_use_widget.pro and respond_widg.pro
; modified by Richard Schwartz, March 21, 1991
; modified by AKT 11/26/91 to handle X or Tektronix graphics.
; mod, RAS, 3 Oct 1993, npoints, newlabel, and nocrossbar added.
;       allows return without any points selected, ras, 4 Oct. 93
; ras, 8-jun-94, added widget controls
; ras, 10-jul-94, improvements to widget controls
; ras, 30-aug-94, made exit more reliable if only one point is needed
; Version 8, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
; Version 9, 5-june-1998 richard.schwartz@gsfc.nasa.gov
;		 support all windowing OS.
; Version 10, 19-aug-1998, establish xdisplay from xdevice as you enter, otherwise a bizarre
;	error mode ensues which I haven't diagnosed, but this stops it. richard.schwartz
;
;**********************************************************************
;-
;
pro point,x,y,device=device,normal=normal,data=data, npoints=npoints, $
    nocrossbar=nocrossbar, newlabel=newlabel, widget=widget, $
    buttons=buttons, val_buttons=val_buttons, mess_widg=mess_widg,$
    xoffset = xoffset, yoffset=yoffset, help=help, $
    drawline=drawline,continue=continue, compile=compile, $
    thick=thick, color=color, linestyle=linestyle ;to support drawline

if keyword_set(compile) then return

;--------------------------------------------------------------------
;The use of the point widget controls can be controlled globally through
;the call, res=f_USE_WIDGET(0, /USE) or res=f_USE_WIDGET(0, /NOUSE)
widget= fcheck( widget, 0) or f_use_widget(/continue)
if widget then widget=f_use_widget(/test,/continue)	;are widgets available?  
;--------------------------------------------------------------------
;
;Point can be set to the CONTINUE =1 state globally by calling POINT_CONTINUE, SET=1
common  point_common, just_continue
continue = fcheck( continue, 0) or fcheck(just_continue, 0)

checkvar, nocrossbar, 0
checkvar, newlabel, ''
xdisplay = xdevice()

if widget then begin
    buttons_set =fcheck(buttons ,['Show X value for cursor select.','Show X as time for cursor select',$
    'CONTINUE in graphics window','DONE'])
    buttons = ['CONTINUE & disable this widget on initial entry.',buttons_set]
    widg_mess= fcheck(mess_widg,['Select one widget button below.','Panel will disappear.',$
    'Then select points in graphics window using any mouse button.',$
    'To Restore Control Panel, ',$
    'MOVE Cursor OUTSIDE of Graphics Window.',' ',newlabel])
    title='CURSOR CONTROLS'
    choices_set = fcheck(val_buttons, ['X','T','X','F'])
    choices = ['DISABLE', choices_set]
    if fcheck(just_continue) then begin
        buttons = buttons_set
        choices = choices_set
        endif
    if n_elements(choices) ne n_elements(buttons) then begin
        print,'Error in consistency between Button labels and values!'
        goto, getout
        endif
    endif

if !d.name eq 'REGIS' then begin
    print,'Point command not available for REGIS graphics.'
    goto, getout
    endif

; Get x and y window limits.
;
l = !x.window(0)
r = !x.window(1)
b = !y.window(0)
t = !y.window(1)
;
;
!err = 0
case !d.name of 
    'TEK': begin
        if newlabel(0) eq '' then text = $
        'Press ''F'' to exit, ''T'' to get time of x value, or A-Z to get x and y values.' $
        else text = newlabel
        xyouts,l+.02, t-.06,arr2str( text,delim='!c'), /normal 
        graphics_page
        device,gin_char=6 
        end
    xdisplay: begin
        if not widget then begin
            if newlabel(0) eq '' then text = $
            'Press MB1 to get x and y values, MB2 to get time and y value.!cPRESS MB3 TO EXIT.' $
            else text = newlabel
            xyouts,l+.02, t-.06,arr2str( text,delim='!c'), /normal 
            endif else begin
            text ='Move Cursor Outside of graphics window to bring up widget controls.'
            xyouts,l+.02, t-.06, text, /normal 
            
            if keyword_set(continue) then in_plot_next=0 $
            else begin
                choice =choices( respond_widg( mess=widg_mess, buttons=buttons, title=title, /column, $
                xoffset=xoffset, yoffset=yoffset) )
                if choice eq 'DISABLE' then begin
                    point_continue,/set
                    choice= 'X'
                    buttons = buttons_set
                    choices = choices_set
                    endif
                in_plot_next=1	;next cursor input only sensitive in graphics window
                endelse
            endelse
        end
    else: return
    endcase
X=0 & Y=0
checkvar,choice,'X'

if keyword_set(help) then begin
    print, text
    if !d.name eq xdisplay and (keyword_set(drawline) or not keyword_set(nocrossbar) ) $
    then print, 'Hold Cursor Down Until Symbol is Displayed on Screen.'
    endif

WHILE choice ne 'F' DO BEGIN ;check for 'F' or 'f' to return
    !err = 0
    TRYAGAIN:
    case widget of
        0: CURSOR,XDAT,YDAT,device=device,normal=normal,data=data, /down
        1: begin
            if fcheck(in_plot_next,1) then begin
                CURSOR,XDAT,YDAT,device=device,normal=normal,data=data, /down
                in_plot_next = 0	;cursor could be inside or outside
                endif else begin
                cursor,xdat,ydat, device=device, normal=normal, data=data, /nowait
                xdev = (convert_coord(xdat,ydat, device=device, normal=normal, data=data, /to_dev))(0) 
                ;Put the program into a loop, looking for a 1 button down, or movement outside of the graphics window.
                while !err lt 1 and xdev gt 0 do begin
                    ;	wait, .01
                    cursor,xdat,ydat, device=device, normal=normal, data=data, /nowait
                    xdev= (convert_coord(xdat,ydat, device=device, normal=normal, data=data, /to_dev))(0) 
                    ;print,!err,xdev
                    endwhile
                if xdev lt 0 then begin
                    choice = choices( respond_widg( mess=widg_mess, buttons=buttons, title=title, /column,$
                    xoffset=xoffset, yoffset=yoffset ))
                    if choice eq 'DISABLE' then begin
                        point_continue,/set
                        choice= 'X'
                        buttons = buttons_set
                        choices = choices_set
                        endif
                    if choice eq 'F' then goto, F_in_buffer ;exit proc
                    in_plot_next=1	;next cursor input only sensitive in graphics window
                    goto, TRYAGAIN
                    endif  
                endelse
            end
        endcase
    case !d.name of
        xdisplay : begin
            if not widget then begin
                case !err of
                    1: choice = 'X'
                    2: choice = 'T'
                    4: choice = 'F'
                    else: goto,tryagain
                    endcase
                endif
            end
        'TEK': begin
            case 1 of 
                (!err lt 65) or (!err gt 122): goto,tryagain
                strupcase (byte(!err)) eq 'F': choice = 'F'
                strupcase (byte(!err)) eq 'T': choice = 'T'
                else: choice = 'X'
                endcase
            end
        endcase
    ;
    if choice eq 'F' then goto, F_in_buffer ;exit proc
    ;
    ;  Compute values in all 3 coord. systems for xdat and ydat
    ;  xall, yall (0,1,2) contain (data, normal, device coords.)
    ;   coord_conv, xdat, ydat, normal=normal, data=data, device=device, xall, yall
    rdat_data = convert_coord( xdat, ydat, normal=normal, data=data, device=device, /to_data)
    rdat_norm = convert_coord( xdat, ydat, normal=normal, data=data, device=device, /to_norm)
    rdat_devi = convert_coord( xdat, ydat, normal=normal, data=data, device=device, /to_devi)
    xall = [rdat_data(0),rdat_norm(0),rdat_devi(0)]
    yall = [rdat_data(1),rdat_norm(1),rdat_devi(1)]
    
    ;   
    X=[X,XDAT] & Y=[Y,YDAT] ;save data points in vectors
    
    ;Prepare to exit if NPOINTS  have been selected and enabled
    if n_elements(npoints) eq 1 then $
    if (n_elements(x)-1) eq npoints then choice ='F'
    
    if nocrossbar ne 1 then begin
        ;
        ; Determine if x and y values should be printed to the left or right of the
        ; cross bar.
        ; use normalized screen coordinates
        offs = .02
        if xall(1) gt .7 then offs = -.23
        nxo = xall(1) + offs
        ;
        ; If operator pressed 'T' key, print time of x position instead of x value.
        ;
        if choice eq 'T'then begin
            getut,utbase=sec_base
            x_sec = sec_base + xall(0)
            cx = strmid(atime(x_sec), 10, 11)
            if xall(1) gt .67 then offs = -.28
            nxo = xall(1) + offs
            endif else begin
            cx = strtrim(xall(0),2)
            endelse
        ;
        cy = strtrim(yall(0),2)
        ; OPLOT doesn't recognize /NORM, so must use data coordinates
        
        if not keyword_set(drawline) then begin
            oplot,xall(0)+fltarr(1),yall(0)+fltarr(1),psym=1,syms=4,/noclip, $
            color=fcheck(color,!p.color)
            xyouts,nxo,yall(1),'( '+cx+', '+cy+')',/norm,/noclip
            endif else begin
            oplot,[xall(0),xall(0)],crange('y'),thick=fcheck(thick,1), $
            color=fcheck(color,!p.color), linestyle=fcheck(linestyle,0), noclip=0
            endelse
        endif
    ;
    ;The dummy variables are to force the system to wait for the up transition before the next point
    ;If only one point is asked for and we are here, then no need to wait, just get out
    if fcheck(npoints,0) ne 1 then  $
    cursor,xdat_dummy,ydat_dummy, device=device, normal=normal, data=data, /up $
    else choice = 'F'
    
    endwhile
;
F_in_buffer:
;User typed 'F', Eliminate initial zero in x and y arrays.
if n_elements(x) gt 1 then begin
    x=x(1:*)
    y=y(1:*)
    endif else begin
    x='null'
    y='null'
    endelse
;
getout:
end
