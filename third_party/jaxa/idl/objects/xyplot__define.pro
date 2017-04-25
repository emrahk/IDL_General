;+
; Project     : HESSI
;
; Name        : XYPLOT__DEFINE
;
; Purpose     : Define a general X vs Y plot class
;
; Category    : objects
;
; Syntax      : IDL> new=obj_new('xyplot')
;
; Inputs:
; xdata - array of x data.  Either 1-D or (2,n) for low/high edges
; ydata - array of y data.  (nx,ny)
;
; Keywords:
; any IDL plot keyword
; (Note: here the term channels is used to refer to the second index
; in the ydata array)
; id or title - title of plot
; data_unit or ytitle - units of y dimension (e.g. 'keV')
; xtitle - units of x dimension
; dim1_ids - array of label id's for individual channels
; dim1_use - array of indices of channels to plot
; dim1_vals - array of values for channels (1 or 2-D) (for weighted sum)
;       if dim1 dimension is time, dim1_vals should be ASCII times
; dim1_sum - if set, then sum channels
; dim1_unit - channel units (e.g. 'frequency')
; dim1_colors - array of colors to use for channel plots
; dim1_linestyles - array of linestyles to use for plots
; weighted_sum - if set, compute weighted sum instead of total
; legend_loc - 0/1/2/3/4/5/6 =
;       no legend/ topleft/topright/ bottomleft/bottomright/outside left/ outside right
;       if legend_loc is 5 or 6, plot will be smaller to make room for label
; label - additional info to put in legend
; addplot_name - string name of an additional plotting procedure to run after
;   primary plot is drawn.  Uses addplot_arg.  Set to blank string for none (default).
; addplot_arg - Structure containing argument(s) to addplot_name procedure.  Passed via
;   _extra to addplot_name, so addplot_name should have keyword arguments.
;
; History     : Written 3 April 2001
;               D. Zarro (EIT/GSFC)
;               K. Tolbert (RITSS/GSFC)
;               (Based on LTC__DEFINE)
; Modifications:
;               2-Apr-2001 - Kim Tolbert.
;               Allow 2-D X array input (2,n)
;               where  x(0,*) are low edges, x(1,*) are high edges.
;               13-Apr-2001 - Kim Tolbert.  Added weighted_sum option, get_y method,
;                  and dim1_vals property.  Propagate status and err_msg through all calls.
;               1-May-2001 - Kim Tolbert.  Changed label for summed data to use dim1_vals,
;                  added get_sum_label method.
;               1-Sept-2001 Zarro (EITI/GSFC) - sped up PLOT by extracting
;               sub-region prior to plotting
;               5-Sep-2001, Kim Tolbert.  Added yscale,yoffset
;               13-Dec-2001, Kim.  Previously label size was .7*charsize, now 1*charsize
;               6-Jan-2002, Zarro - fixed YRANGE bug when /YLOG
;               14-Jan-2002, Kim.  If y min equals y max, set yrange to small interval around that value
;               17-Jan-2002, Kim.  Take care of NaN's in the data.
;               18-Feb-2002, Kim.  In get_sum_label, use dim1_vals if only 2 elements
;               10-May-2002, Zarro (L-3Com/GSFC) - added derivative plot property
;               27-May-2002, Kim.  Add 'derivative' to y axis label.  For 2-D
;                  y arrays, take deriv of each channel separately
;               08-Aug-2002, Kim.  In set_colors method, check what background color is
;                  before replacing black with white.  Also change white to black if necessary.
;               20-Aug-2002, Kim.  Added options for placing legend to left or right of plot,
;                  and added get_margin method
;               9-Sep-2002, Zarro (LAC/GSFC)
;                 - added INTEGRAL property/method and centralized use of
;                   FINITE in SET method
;                 - restore initial plot settings when calling ->plot
;                 - added /positive property/keyword.
;               16-Sep-2002, Zarro (LAC/GSFC)
;                 - fixed anytim calls and allowed plotting even when
;                   no data in plot window.
;               17-Oct-2002, Paul Bilodeau, fixed bug -when x array is 2-D but don't
;                 want to plot histogram style, was using wrong x values on zoom
;               16-Nov-2002, Zarro (EER/GSFC) - added GETDATA, HEADER pointer
;               26-Jan-2003, Zarro (EER/GSFC) - removed redundant:
;                add_method,'gen',self (since handled in CHAN__DEFINE)
;               13-Mar-2003, Kim, added getaxis method
;                5-May-2003, Zarro (EER/GSFC) - enhanced to allow channels
;                            with different XDATA axes.
;                23-Jun-2003, Zarro (EER/GSFC)
;                  - fixed bug with plotting over missing data
;                  - added /XLOG
;                  - added /HISTOGRAM
;                  - added ERROR bar plotting
;                17-Jul-2003, Kim. in where_xdata, return ind for finite(x) only
;                29-Jul-2003, Kim.  In get_sum_label, call find_contig_ranges with epsilon
;                30-Jul-2003, Kim.  Store dim1_vals as numbers.  Set dim1_is_time flag if they
;                   were originally strings.  Otherwise takes long time each time it gets converted
;                   which happens in multiple calls.
;                8-Sep-2003, Kim.  Added overlay_obj property.  If overlay_obj is set to an xyplot or utplot
;                   object, then after plotting current plot,  self.overlay_obj->plot,/overlay will be called.
;                21-Oct-03, Zarro (GSI/GSFC) - fixed FILENAME/FILEID conflict
;                23-Jan-04, Zarro (L-3Com/GSFC) - modified so that XDATA/YDATA
;                           could be entered separately
;                26-Feb-2004, Kim.  Make sure psym=10 isn't set when plotting error bars.
;                07-Mar-2004, Kim. Fixed bug in check for 2-d error data, and previously didn't write legend if
;                           label defined, but dim1_ids not set
;                17-Apr-2004, Zarro (L-3Com/GSFC) - replaced WHERE by
;                                                   WHERE2
;                20-Apr-2004,  Csillaghy added possibility of setting
;                               data without resetting the plot
;                               parameters.(NO_DEFAULTS kwd)
;                               Also added a keyword to prevent the
;                               timestamp on plots.
;                22-Apr-2004,  Zarro (L-3Com/GSFC) - modified ->EMPTY
;                1-April-2005, Zarro (L-3Com/GSFC) - use _REF_EXTRA
;                              to pass keyword values back to caller.
;                11-April-2005, Kim.  Added addplot_name and addplot_arg properties and call to
;                              run addplot_name routine after plotting.
;                24-May-2005, Sandhia. Modified set method to reset self.addplot_name when the
;                              incoming addplot_name keyword contains a string or a blank/null
;                              value. This is so that we can toggle overplotting.
;                24-Aug-05, Zarro (L-3Com/GSFC) - added XHOUR
;                21-Nov-2005, Kim.  When calling addplot_name procedure, combine the xyplot
;                              property structure with the addplot_arg structure, so the called
;                              procedure can use the current selections for plotting if needed.
;                17-Jan-2006, Zarro. Made err and err_msg self consistent.
;                15-Sep-2006, Kim. Allow dim1_color = '' to signify b/w plot.
;                             If b/w, set color to ' ' in overlay_obj so linestyles used
;                             In use_colors, only check for blank string, not >1 unique color -
;                             needed in case of single trace, with overlay plot.
;                             In set_colors, added test for blank strings
;                27-Sep-2006, Kim. Add psym to set_plot args, and use
;                to set self.histogram
;                30-Oct-2006, Zarro (ADNET/GSFC)
;                              - removed an EXECUTE call
;                              - removed XHOUR
;                4-Mar-2007, Zarro(ADNET)
;                              - removed ADD_METHOD
;                4-Apr-2007, Kim.  Pass a few keywords from main plot to overlay plot
;                14-Nov-2007, Kim. In get_sum_label, include date in time label
;                5-Dec-2007, Kim.  Pass charthick through to write_legend
;                24-Apr-2008, Kim. Uncommented call to valid_channels in set_channels and in
;                             valid_channels, print message if none of selected channels is valid
;                16-May-2008, Kim. in write_legend scale legend char size by .9
;                05-Dec-2008, Kim. In integral, use temp array with NaNs set to 0., otherwise result is NaN
;                16-Dec-2008, Kim. In integral, use total with /nan instead of 5-Dec fix.
;                09-Jan-2008, Kim. In plot, call struct_subset with /quiet
;                03-Feb-2009, Kim. Added fill_gaps prop.  If set, fill gaps by interpolating.
;                04-Feb-2009, Kim. In fill_xgaps and fill_ygaps, don't use non-finite points
;                26-Apr-2009, Zarro (ADNET) 
;                 - modified GET to return status=0 if property undefined
;                04-Aug-2009, Kim. Added _extra to cleanup and empty and pass through
;                25-Feb-2010, Zarro (ADNET) - added PLOTMAN method
;                3-March-2010, Zarro (ADNET) - added /nodup to plotman call
;                8-Oct-2011, Kim. Call al_legend instead of legend (IDL 8. name conflict). Also, ensure that
;                  dim1_colors is not a long (make byte) because al_legend treats long colors as 24-bit values
;                  that need to be decomposed.
;                23-Jan-2012, Kim. al_legend had problems with Z
;                buffer plots.  Use ssw_legend (renamed from legend)
;                19-Feb-2012, Zarro (ADNET)
;                 - changed message,/cont to message,/info because
;                   /cont was setting !error_state
;                8-Mar-2012, Kim. In use_colors and set_colors, when checking if dim1_color is set by using 
;                  string(), make it non-byte first, since string(0b) is blank, not '0', so black (0) didn't work
;                27-Mar-2012, Kim. Redo fixes of 8-Oct, 8-Mar.  Since not using al_legend, don't make colors
;                  byte, make fixed.  Then both '' meaning color not set and 0 meaning black should work. 
;                01-Apr-2014, Kim. Make yrange double instead of float. 
;                26-Oct-2014, Kim. Added xtitle property, made ytitle synonymous with data_unit, and
;                  title synonymous with id. 
;                  If x or y is log, axis label will be sci. notation (x/ytickformat='tick_label_exp') (DISABLED FOR NOW)
;                01-Mar-2015, Kim. In get_sum_label, use format_intervals, so numbers > 1.e6 get formatted properly (was '****')
;
; Contact     : dzarro@solar.stanford.edu
;-

function xyplot::init,xdata,ydata,edata,_ref_extra=extra

tmp=self->chan::init()

;-- set defaults

self.nx=1
self.ny=1
self->init_ptr
self->set,xdata=xdata,ydata=ydata,edata=edata,_extra=extra,$
         /stairs,/histogram,yscale=1,yoffset=0,plot_type='xyplot',legend_loc=1

dprint,'% XYPLOT::INIT'

return,1

end

;----------------------------------------------------------------------
pro xyplot::init_ptr

self.header_ptr=ptr_new(/all)
self.xdata_ptr=ptr_new(/all)
self.ydata_ptr=ptr_new(/all)
self.edata_ptr=ptr_new(/all)
self.dim1_ids=ptr_new(/all)
self.dim1_vals=ptr_new(/all)
self.dim1_use=ptr_new(/all)
self.dim1_colors=ptr_new(/all)
self.dim1_linestyles=ptr_new(/all)
self.label=ptr_new(/all)
self.addplot_arg=ptr_new(/all)

return & end

;-----------------------------------------------------------------------
;--destroy object

pro xyplot::cleanup, _extra=extra

dprint,'% XYPLOT::CLEANUP'

self->empty,/deallocate, _extra=extra
self->chan::cleanup, _extra=extra
return
end

;-----------------------------------------------------------------------
;-- empty object pointers of data

pro xyplot::empty,deallocate=deallocate, _extra=extra

self->free_var,no_deallocate=1-keyword_set(deallocate), _extra=extra

self.filename=''
self.id=''

return & end

;-----------------------------------------------------------------------
;-- allow summing

function xyplot::allow_sum

sum=self->get(/dim1_sum)
if ~sum then return,0b

xtype=self->get(/xtype)
if (xtype eq 2) or (xtype eq 3) then begin
 message,'Y-DATA summing is disabled for XTYPE = '+strtrim(xtype,2),/info
 self->set,dim1_enab_sum=0b
 self->set,dim1_sum=0b
 return,0b
endif

return,sum
end

;-----------------------------------------------------------------------
;-- general set method

pro xyplot::set,xdata=xdata,ydata=ydata,edata=edata,overlay_obj=overlay_obj,_ref_extra=extra, $
          no_set_plot=no_set_plot, addplot_name=addplot_name, addplot_arg=addplot_arg

;-- set data properties first

self->set_data,xdata,ydata,edata,_extra=extra

;-- set plot properties

if is_string(extra) and ~keyword_set( no_set_plot ) then begin
 self->set_plot,_extra=extra
 self->chan::set,_extra=extra
endif

if is_class(overlay_obj, 'xyplot', /quiet) then self.overlay_obj=overlay_obj

;if is_string(addplot_name) then self.addplot_name = addplot_name
if (exist(addplot_name)) then $
   if is_string(addplot_name, /blank) then self.addplot_name = addplot_name

if exist (addplot_arg) then *self.addplot_arg = addplot_arg

return

end

;-------------------------------------------------------------------

function xyplot::check_data,err_msg=err_msg

err_msg=''

if ~self->has_xdata() or ~self->has_ydata() then return,0b

self->check_xdata,*self.xdata_ptr,x_nx,x_ny,type=xtype,err_msg=err_msg
if is_string(err_msg) then return,0b

self->check_ydata,*self.ydata_ptr,y_nx,y_ny,err_msg=err_msg
if is_string(err_msg) then return,0b

if (x_nx ne y_nx) or ((x_ny gt 1) and (x_ny ne y_ny)) then begin
 err_msg='# of X and Y data points do not match'
 message,err_msg,/info
 return,0b
endif

return,1b
end

;-------------------------------------------------------------------
;-- set data properties

pro xyplot::set_data,xdata,ydata,edata,id=id,title=title,xtitle=xtitle,$
           dim1_ids=dim1_ids,dim1_vals=dim1_vals,$
           data_unit=data_unit,ytitle=ytitle,dim1_unit=dim1_unit,plot_type=plot_type,$
           status=status,err_msg=err_msg,no_copy=no_copy,filename=filename,$
           yscale=yscale,yoffset=yoffset,header=header,_extra=_extra, $
          no_defaults = no_defaults

status = 1
err_msg=''
no_copy=keyword_set(no_copy)

;-- check & set X/Y data
;-- following XDATA inputs acceptable
;-- x=array(nx)       xtype=0
;-- x=array(2,nx)     xtype=1
;-- x=array(nx,ny)    xtype=2
;-- x=array(2,nx,ny)  xtype=3
;-- if NY > 1 then it must match NY for YDATA

if exist(xdata) then begin
 self->check_xdata,xdata,x_nx,x_ny,type=xtype,err_msg=err_msg
 if is_string(err_msg) then begin
  status=0
  return
 endif
 dprint,'% XTYPE ',xtype
 self.nx=x_nx
 self.xtype=xtype
 if no_copy then *self.xdata_ptr=temporary(xdata) else *self.xdata_ptr=xdata
 self->set_xrange
endif

if exist(ydata) then begin
 self->check_ydata,ydata,y_nx,y_ny,err_msg=err_msg
 if is_string(err_msg) then begin
  status=0
  return
 endif

;-- convert from integer to float to avoid overflows

 self.ny=y_ny
 ytype=size(ydata,/type)
 if ytype eq 2 then begin
  if no_copy then *self.ydata_ptr=temporary(float(ydata)) else *self.ydata_ptr=float(ydata)
 endif else begin
  if no_copy then *self.ydata_ptr=temporary(ydata) else *self.ydata_ptr=ydata
 endelse

;-- plotting defaults

if ~keyword_set( no_defaults ) then begin
    self->set_channels
    self->set_linestyles
    self->set_colors
    self->set_chan_ids
    self->set_yrange
endif

endif

;-- data errors

if exist(edata) then begin
 if no_copy then *self.edata_ptr=temporary(edata) else *self.edata_ptr=edata
endif

;-- channel values

if exist(dim1_vals) then self->set_dim1_vals, dim1_vals, status=status,err_msg=err_msg,no_copy=no_copy

;-- channel ID's

if exist(dim1_ids) then self->set_chan_ids,dim1_ids

;-- plot type

if is_string(plot_type) then self.plot_type=plot_type

;-- plot labels

if is_string(id,/blank) then self.id=id
if is_string(title,/blank) then self.id=title
if is_string(xtitle,/blank) then self.xtitle=xtitle eq '' ? ' ' : xtitle
if is_string(dim1_unit,/blank) then self.dim1_unit=dim1_unit
if is_string(data_unit,/blank) then self.data_unit=data_unit
if is_string(ytitle, /blank) then self.data_unit=ytitle

if exist(yscale) then self.yscale=yscale
if exist(yoffset) then self.yoffset=yoffset

;-- source filename

if is_string(filename) then self.filename=strtrim(filename,2)

;-- file header

if is_string(header) then *self.header_ptr=header

return
end

;-----------------------------------------------------------------------
;-- set dim1 vals

pro xyplot::set_dim1_vals, dim1_vals, status=status,err_msg=err_msg,no_copy=no_copy

 if size(dim1_vals, /n_dimen) eq 2 then begin
  if data_chk(dim1_vals, /nx) ne 2 then begin
   err_msg = 'X array must be dimensioned n or (2,n)'
   message, err_msg, /info
   status=0
   return
  endif
  ndim1= data_chk(dim1_vals,/ny)
 endif else begin
  if self.ny eq 1 and n_elements(dim1_vals) eq 2 then ndim1=1 else $
   ndim1=data_chk(dim1_vals,/nx)
 endelse

; if ndim1 ne self.ny then begin
;  msg = 'Warning - number of dim1 vals not equal to number of Y channels.'
;  message,msg, /info
; endif

 ; store dim1_vals as numbers.  If they came in as strings, must be times, so set flag.  ;kim 7/30/03

 self.dim1_is_time = size(dim1_vals, /tname) eq 'STRING'

 if self.dim1_is_time then begin
  if no_copy then *self.dim1_vals=temporary(anytim(dim1_vals)) else *self.dim1_vals=anytim(dim1_vals)
 endif else begin
  if no_copy then *self.dim1_vals=temporary(dim1_vals) else *self.dim1_vals=dim1_vals
 endelse

end

;-----------------------------------------------------------------------
;-- set channel ids

pro xyplot::set_chan_ids,dim1_ids

ny=self->get(/ny)
if ~exist(dim1_ids) then dim1_ids=strarr(ny)

*self.dim1_ids=dim1_ids

return & end

;-----------------------------------------------------------------------
;-- set plot properties

pro xyplot::set_plot,ylog=ylog,all=all,dim1_enab_sum=dim1_enab_sum,$
             weighted_sum=weighted_sum, derivative=derivative,$
             integral=integral,positive=positive,$
             dim1_sum=dim1_sum,xrange=xrange,yrange=yrange,$
             nsum=nsum,legend_loc=legend_loc, label=label,stairs=stairs,$
             dim1_colors=dim1_colors, dim1_linestyles=dim1_linestyles,$
             charsize=charsize,dim1_use=dim1_use,xlog=xlog,histogram=histogram, $
             fill_gaps=fill_gaps, psym=psym

if is_number(all) then self.all= 0 > all < 1 else begin
 if exist(dim1_use) then if n_elements(dim1_use) ne self->get(/ny) then self.all=0
endelse

if is_number(derivative) then begin
 self.derivative= 0b > derivative < 1b
 if self.derivative then self.integral=0b
endif
if is_number(integral) then begin
 self.integral= 0b > integral < 1b
 if self.integral then self.derivative=0b
endif

if is_number(psym) then self.histogram = psym eq 10
if is_number(histogram) then self.histogram =0b > histogram < 1b
if is_number(stairs) then self.stairs =0b > stairs < 1b
if is_number(ylog) then self.ylog= 0b > ylog < 1b
if is_number(xlog) then self.xlog= 0b > xlog < 1b
if is_number(positive) then self.positive= 0b > positive < 1b
if is_number(dim1_enab_sum) then self.dim1_enab_sum= 0b > dim1_enab_sum < 1b
if is_number(weighted_sum) then self.weighted_sum= 0b > weighted_sum < 1b
if is_number(dim1_sum) then self.dim1_sum= 0b > dim1_sum < 1b
if is_number(nsum) then self.nsum=nsum > 0
if is_number(legend_loc) then self.legend_loc = 0 > legend_loc < 6
if datatype(label) eq 'STR' then  *self.label =trim(label)

if exist(dim1_colors) then self->set_colors,dim1_colors
if exist(dim1_linestyles) then self->set_linestyles,dim1_linestyles
if exist(dim1_use) then self->set_channels,dim1_use
if exist(xrange) then self->set_xrange,xrange
if exist(yrange) then self->set_yrange,yrange

if is_number(fill_gaps) then self.fill_gaps =   0b > fill_gaps < 1b

return & end

;---------------------------------------------------------------------------

pro xyplot::set_yrange,yrange

if ~exist(yrange) then self.yrange=[0.,0.] else $
 if valid_range(yrange,/allow_zeros) then self.yrange=double(yrange)

return & end

;---------------------------------------------------------------------------

pro xyplot::set_xrange,xrange

if ~exist(xrange) then self.xrange=[0.d,0.d] else $
 if valid_range(xrange,/allow_zeros) then self.xrange=double(xrange)

return & end

;---------------------------------------------------------------------------
;-- get default XDATA range

function xyplot::get_def_xrange,err_msg=err_msg

err_msg=''

if ~self->has_xdata() then begin
 err_msg='Warning - no X-DATA to plot'
 message,err_msg,/info
 return,[0.,0]
endif

xlog=self->get(/xlog)
if xlog then begin
 good=where(*self.xdata_ptr gt 0,count)
 if count gt 0 then xmax=max((*self.xdata_ptr)[good],min=xmin,/nan) else $
  xmax=max(*self.xdata_ptr,min=xmin,/nan)
endif else xmax=max(*self.xdata_ptr,min=xmin,/nan)

return,[xmin,xmax]
end

;---------------------------------------------------------------------------
;-- get default YDATA range

function xyplot::get_def_yrange,err_msg=err_msg

dprint,'% calling GET_DEF_YRANGE...'
err_msg=''
dmin=1. & dmax=1.

if ~self->has_ydata() then begin
 err_msg='Warning - no Y-data to plot'
 message,err_msg,/info
 goto,done
endif

channels=self->get_channels()
nchans=n_elements(channels)
sum=self->allow_sum()
nx=self->get(/nx)
ylog=self->get(/ylog)

nan=!values.d_nan
ymin=replicate(nan,nchans)
ymax=ymin
ydata=replicate(nan,nx)

for i=0,nchans-1 do begin
 k=channels[i] & ncount=0
 xindex=self->where_xdata(k,count=count,complement=complement,$
                          ncomplement=ncount)
 if count gt 0 then begin
  ydata=self->get_ydata(k,err_msg=err_msg)
  if is_string(err_msg) then continue
  if sum then begin
   if ncount gt 0 then ydata[complement]=nan
   break
  endif else begin
   if count eq nx then ymax[i]=max(ydata,min=temp,/nan) else $
    ymax[i]=max(ydata[xindex],min=temp,/nan)
   ymin[i]=temp
  endelse
 endif
endfor

;-- filter out plot-worthy data

if sum then begin
 dmax=max(ydata,/nan,min=dmin)
endif else begin
 dmax=max(ymax,/nan)
 dmin=min(ymin,/nan)
endelse

if finite(dmin,/nan) or finite(dmax,/nan) then begin
 dmin=1. & dmax=1.
endif

done:

if dmin eq dmax then begin
 if ylog then begin
  dmin = dmin / 10.
  dmax = dmax * 10.
 endif else begin
  dmin = dmin - 1.
  dmax = dmax + 1.
 endelse
endif

return,[dmin,dmax]
end

;------------------------------------------------------------------------
;-- general GETDATA

function xyplot::getdata,_ref_extra=extra

return,self->get(/data_array,/all_chans,_extra=extra)

end

;--------------------------------------------------------------------------
;-- get data properties

function xyplot::get,xdata=xdata,data_array=data_array,$
             _ref_extra=extra,all_chans=all_chans, $
                     title = title,ytitle=ytitle,status=status

status=1b
if keyword_set(xdata) and self->has_xdata() then return,*self.xdata_ptr

if keyword_set(data_array) and self->has_ydata() then begin
 if keyword_set(all_chans) then return,reform(*self.ydata_ptr) else begin
  channels=self->get_channels()
  return,reform((*self.ydata_ptr)[*,channels])
 endelse
endif

if keyword_set( title ) then return, self->getprop( /id )
if keyword_set( ytitle ) then return, self->getprop( /data_unit)

if is_string(extra) then return,self->getprop(_extra=extra,status=status)

status=0b
return,''

end

;---------------------------------------------------------------------------
;-- return axis info

function xyplot::getaxis, xaxis=xaxis, yaxis=yaxis, _extra=_extra
if keyword_set(xaxis) then return,get_edge_products(self->get(/xdata), _extra=_extra)
if keyword_set(yaxis) then return,get_edge_products(self->get(/ydata), _extra=_extra)
return, -1
end

;-------------------------------------------------------------------
;-- plot command

pro xyplot::plot_cmd,x,y,overlay=overlay,_extra=extra

overlay=keyword_set(overlay)
if overlay then begin
plot_cmd='oplot'
if abs(!p.psym) eq 10 then begin
  psym_save=!p.psym
  !p.psym=0
  endif
endif else plot_cmd='plot'

call_procedure,plot_cmd,x,y,_extra=extra

if exist(psym_save) then !p.psym=psym_save

return & end

;-------------------------------------------------------------------
;-- histogram plot command

pro xyplot::plot_hist_cmd,x,y,overlay=overlay,_extra=extra

; If x array is 2-D and we want a histogram style plot, use datplot
; command to handle unequally sized x bins.

;-- can't have psym=10 when calling DATPLOT

if have_tag(extra,'psy',/start,index) then begin
 if abs(extra.(index)) eq 10 then extra=rem_tag(extra,index)
endif
if abs(!p.psym) eq 10 then begin
 psym_save=!p.psym
 !p.psym=0
endif

stairs=self->get(/stairs)
datplot,d1,d2,y,xs=x,stairs=stairs,_extra=extra,noeras=overlay

if exist(psym_save) then !p.psym=psym_save

return & end

;----------------------------------------------------------------------------
;-- plotter

pro xyplot::plot,overlay=overlay,err_msg=err_msg,status=status,$
                _extra=extra

if ~self->check_data(err_msg=err_msg) then return

cancel=0b
if ~self->has_ydata() then self->options,cancel=cancel,title='Filename: '+self->get(/filename)
if cancel then return

;-- sometimes you just have to protect users from themselves

if !p.psym lt -8 then !p.psym=0
if have_tag(extra,'psy',/start,index) then begin
 if extra.(index) lt -8 then extra.(index)=0
endif

;-- temporary structure to save initial state

;xhour
;state='temp={'+obj_class(self)+'}'
;s=execute(state)

temp=obj_struct(obj_class(self))
struct_assign,self,temp

status = 1
err_msg = ''

;-- check if initial overlay

ioverlay=keyword_set(overlay)

if ~self->has_ydata() then begin
 err_msg = 'Warning - no Y-data to plot'
 message, err_msg, /info
 self->empty_plot
 status=0
 return
endif

;-- set command line parameters

if is_struct(extra) then self->set,_extra=extra

;-- get working values

histogram=self->get(/histogram)
ylog=self->get(/ylog)
xlog=self->get(/xlog)
positive=self->get(/positive)
nx=self->get(/nx)
channels=self->get_channels()
nchans=n_elements(channels)
linestyles=self->get(/dim1_linestyles)
colors=self->get(/dim1_colors)
use_colors=self->use_colors()
sum=self->allow_sum()
data_unit=self->get(/data_unit)
if data_unit ne '' then begin
  data_unit = self->get(/derivative) ? data_unit + ' derivative' : data_unit
  data_unit = self->get(/integral) ? data_unit + ' integral' : data_unit
endif
id=self->get(/id)
xtitle=self->get(/xtitle)

;-- check XRANGE

xrange=self->get(/xrange)
if valid_range(xrange) then begin
 if xlog then begin
  xmin=min(xrange,max=xmax)
  if (xmin le 0) or (xmax le 0) then begin
   drange=self->get_def_xrange()
   if xrange[0] le 0 then xrange[0]=drange[0]
   if xrange[1] le 0 then xrange[1]=drange[1]
   self->set,xrange=xrange
  endif
 endif
endif

if ~valid_range(xrange) then begin
 xrange=self->get_def_xrange()
 self->set,xrange=xrange
endif

;-- if YRANGE=[0,0], then YRANGE is based upon min/max of plotted channels

yrange=self->get(/yrange)
if valid_range(yrange) then begin
 if ylog or positive then begin
  ymin=min(yrange,max=ymax)
  if (ymin le 0) or (ymax le 0) then begin
   drange=self->get_def_yrange()
   if yrange[0] le 0 then yrange[0]=drange[0]
   if yrange[1] le 0 then yrange[1]=drange[1]
   self->set,yrange=yrange
  endif
 endif
endif

if ~valid_range(yrange) then begin
 yrange=self->get_def_yrange()
 self->set,yrange=yrange
endif

dprint,'% XRANGE: ', xrange
dprint,'% YRANGE: ', yrange

;-- construct plot keywords

plot_keywords={xlog:xlog,ylog:ylog,ytitle:data_unit,title:id}
;if xlog then plot_keywords = add_tag(plot_keywords, 'tick_label_exp', 'xtickformat')
;if ylog then plot_keywords = add_tag(plot_keywords, 'tick_label_exp', 'ytickformat')
if xtitle ne '' then plot_keywords=add_tag(plot_keywords,xtitle,'xtitle')
plot_keywords=join_struct(extra,plot_keywords)

;-- override xmargin, xrange, yrange

margins = self-> get_margin()
if margins[0] ne -1 then $
 plot_keywords = rep_tag_value(plot_keywords,margins,'xmargin')
plot_keywords = rep_tag_value(plot_keywords,xrange,'xrange')
plot_keywords = rep_tag_value(plot_keywords,yrange,'yrange')

;-- check if histogram plotting

xtype=self->get(/xtype)
dohist = ((xtype eq 1) or (xtype eq 3)) and histogram

; If X-DATA is 1-D, then use regular plot command
; If X-DATA is 2-D and we want a histogram style plot, create datplot command
; to handle unequally sized x bins.

pcount=0
for i=0,nchans-1 do begin
 k=channels[i]
 textra=plot_keywords

;-- if sum then don't bother with internal colors and linestyles
;-- if different colors are set, then don't bother with different linestyles

 if ~sum then begin
  lcolor=colors[k]
  lstyle=linestyles[k]
;  if nchans eq 1 then begin
;   lcolor=colors[0]
;   lstyle=linestyles[0]
;  endif
  if use_colors then $
   textra=add_tag(textra,lcolor,'color',/quiet) else $
    textra=add_tag(textra,lstyle,'linestyle',/quiet)
 endif

 xdata=self->get_xdata(k,midpoint=1-dohist)
 keep=self->where_xdata(k,count=count,/keep_log)
 ydata=self->get_ydata(k,edata=edata,err_msg=err_msg)
 if is_string(err_msg) then continue

 if count gt 0 then begin
  status=1b
  if count lt nx then begin
   ydata=ydata[keep]
   if exist(edata) then edata=edata[keep]
   if dohist then xdata=xdata[*,keep] else xdata=xdata[keep]
  endif
  pcount=pcount+1

;-- plot axis first without data

  if (pcount eq 1) and ~ioverlay then begin
   nextra=rem_tag(textra,'color')
   self->plot_cmd,xdata,ydata,_extra=nextra,/nodata
  endif

  if dohist then $
   self->plot_hist_cmd,xdata,ydata,_extra=textra,/overlay else $
    self->plot_cmd,xdata,ydata,_extra=textra,/overlay

 endif

;-- plot errors if available

 if exist(edata) then begin
  self->plot_err,xdata,ydata,edata,_extra=textra
 endif

 if sum then break
endfor

wshow2
if (pcount eq 0) and ~ioverlay then $
 self->plot_cmd,xdata,replicate(0,nx),_extra=textra

self->write_legend,_extra=extra

if obj_isa(self.overlay_obj, 'xyplot') then begin
	if ~use_colors then begin
		save_colors = self.overlay_obj->get(/dim1_colors)
		temp_colors = ' '
	endif
	; share the following params with the overlay plot, kim 4-apr-07
	o_extra = struct_subset(extra, ['charsize','thick', 'psym', 'nsum'], /quiet, status=status)
	if ~status then o_extra={dummy:0}
	self.overlay_obj->plot,/overlay, /no_timestamp, dim1_colors=temp_colors, _extra=o_extra
	if ~use_colors then self.overlay_obj -> set, dim1_colors=save_colors
endif

if is_string(self.addplot_name) then $
 call_procedure, self.addplot_name, _extra=join_struct(*self.addplot_arg, self->get(/all_props))

;-- restore initial state

error=0
catch,error
if error ne 0 then begin
 message,err_state(),/info
 catch,/cancel
endif

struct_assign,temp,self,/nozero

return & end


;----------------------------------------------------------------------------
;-- oplot error bars

pro xyplot::plot_err,xdata,ydata,edata,_extra=extra

if ~exist(edata) then return

xlog=self->get(/xlog)
xd2=size(xdata,/n_dim) eq 2
if xd2 then begin
if xlog then xa=sqrt(xdata[0,*]*xdata[1,*]) else xa=total(xdata,1)/2
endif else xa=xdata

if have_tag(extra,'col',index,/start) then errcolor=extra.(index[0])

oploterr,xa,ydata,edata,errcolor=errcolor,_extra=extra,/noconnect

return & end

;----------------------------------------------------------------------------
;-- plot an empty plot (for zero data case)

pro xyplot::empty_plot,_extra=extra

plot,[0,1],[0,1],_extra=extra,/nodata

return & end

;-------------------------------------------------------------------
;-- if legend is outside plot, figure an appropriate margin to make room for legend

function xyplot::get_margin

loc = self->get(/legend_loc)
if loc gt 4 then begin
  ; first create legend but don't write it, just to get size
  self->write_legend, /nowrite, legend_size=legend_size
  xchar_norm = !d.x_ch_size/float(!d.x_size)
  if loc eq 5 then return, [legend_size[0] / xchar_norm, !x.margin[1]]
  if loc eq 6 then return, [!x.margin[0], legend_size[0] / xchar_norm]
endif else return, -1
end

;-------------------------------------------------------------------
;-- check if colors are to be used

function xyplot::use_colors
colors=self->get(/dim1_colors)
if is_blank(string(colors)) then return,0b
return,1
;ucolors=get_uniq(colors)
;ncolors=n_elements(ucolors)
;use_colors=(ncolors gt 1)
;if ncolors eq 1 then $
; use_colors=(ucolors gt 0) and (ucolors lt (!d.table_size-1))
;return,use_colors
end

;--------------------------------------------------------------------------
;-- check if object has X-Y-data

function xyplot::has_data

return, (self->has_xdata() and self->has_ydata())

end


;--------------------------------------------------------------------------
;-- check if object has Y-data

function xyplot::has_ydata

if ~ptr_valid(self.ydata_ptr) then return,0b
return,exist(*self.ydata_ptr)

end

;--------------------------------------------------------------------------
;-- check if object has error data

function xyplot::has_edata

if ~ptr_valid(self.edata_ptr) then return,0b
return,exist(*self.edata_ptr)

end

;--------------------------------------------------------------------------
;-- check if object has X-DATA

function xyplot::has_xdata

if ~ptr_valid(self.xdata_ptr) then return,0b
if exist(*self.xdata_ptr) then begin
 chk=where(*self.xdata_ptr ne 0,count)
 return,count gt 0
endif else return, 0b

end

;---------------------------------------------------------------------------
;-- show xyplot properties

pro xyplot::show

print,''
print,'xyplot properties:'
print,'---------------'
print,'% DATA ID: ',self->get(/id)
print,'% # DATA POINTS: ',self->get(/nx)
print,'% # CHANNELS: ',self->get(/ny)
print,'% CHANNELS SELECTED: ',self->get_channels()
print,'% PLOT_TYPE: ',self->get(/plot_type)
print,'% XRANGE: ',self->get(/xrange)
print,'% YRANGE: ',self->get(/yrange)
print,'% YLOG: ',self->get(/ylog)
print,'% XLOG: ',self->get(/xlog)
print,'% ALL/SUM/ENAB_SUM/WEIGHTED SUM: ',self->get(/all),self->allow_sum(),$
self->get(/dim1_enab_sum), self->get(/weighted_sum)
print,'% NSUM: ',self->get(/nsum)
print,'% DERIVATIVE: ',self->get(/derivative)
print,'% INTEGRAL: ',self->get(/integral)
print,'% HISTOGRAM: ',self->get(/histogram)
print,'% STAIRS: ',self->get(/stairs)
print,''

return & end

;-----------------------------------------------------------------------------
;--- set channels to plot

pro xyplot::set_channels, dim1_use

ny=self->get(/ny)
def_chans=indgen(ny)

if ~exist(dim1_use) then dim1_use=def_chans

dim1_use=self->valid_channels(dim1_use)
if self->get(/all) then dim1_use=def_chans

*self.dim1_use=dim1_use

return
end

;-----------------------------------------------------------------------------
;--- get plotted channels

function xyplot::get_channels

ny=self->get(/ny)
def_chans=indgen(ny)
if self->get(/all) then return,def_chans
return,self->get(/dim1_use)
end

;--------------------------------------------------------------------------
;-- validate input channels

function xyplot::valid_channels,channels

if ~exist(channels) then valid=0 else valid=channels
ny=self->get(/ny)
if ny gt 0 then begin
 ok=where( (valid lt ny) and (valid gt -1),count)
 if count gt 0 then valid=valid[ok] else begin
  valid=0
  message,'Choice of channels to plot is invalid.  Plotting channel 0.', /infoinue
 endelse
 if count eq 1 then valid=valid[0]
endif

return,get_uniq(valid) & end

;-----------------------------------------------------------------------------
;--- set colors. if user didn't set enough colors, then keep appending

pro xyplot::set_colors,dim1_colors

ny=self->get(/ny)
if exist(dim1_colors) then dim1_colors = dim1_colors
if ~exist(dim1_colors) or is_string(dim1_colors, /blank) then begin
 *self.dim1_colors=replicate('',ny)
 return
endif

white=!d.table_size-1
black=0

cc = black > dim1_colors < white
while n_elements(cc) lt ny do cc = append_arr (cc, dim1_colors)
cc = cc[0:ny-1]

if !p.background eq black then begin
 iblack=where(cc eq black,count)
 if count gt 0 then cc[iblack]=white
endif else begin
 iwhite=where(cc eq white,count)
 if count gt 0 then cc[iwhite]=black
endelse

if n_elements(cc) eq 1 then cc=cc[0]

*self.dim1_colors=(!d.table_size le 256) ? fix(cc) : cc

return
end

;-----------------------------------------------------------------------------
;--- set linestyles.  if user didn't set enough linestyles, then keep appending

pro xyplot::set_linestyles, dim1_linestyles

if ~exist(dim1_linestyles) then dim1_linestyles=indgen(6)

ny=self->get(/ny)
ll = dim1_linestyles
while n_elements(ll) lt ny do ll = append_arr (ll, dim1_linestyles)
ll =  ll[0:ny-1]
*self.dim1_linestyles=ll

return & end

;------------------------------------------------------------------------------

pro xyplot::write_legend,charsize=charsize, nowrite=nowrite, legend_size=legend_size, $
          no_timestamp = no_timestamp, charthick=charthick

; write legend if requested: legend_loc = 0/1/2/3/4/5/6 = none, topleft, topright,
; bottomleft, bottomright, outside plot on left, outside plot on right
; scale character size for legend and xdatatamp to size of window or requested
; size of plot labels.

label_size = ch_scale(.9, /xy)
time_size = ch_scale(.6, /xy)
if exist(charsize) then begin
 label_size = ch_scale(charsize*.9, /xy)
 time_size = ch_scale(charsize * .6, /xy)
endif

loc = self->get(/legend_loc)
sum= self->allow_sum()
channels=self->get_channels()
ids=(self->get(/dim1_ids))[channels]
;nplots=n_elements(channels)
; only write legend for smaller of dim1_ids and channels in case don't want to label all lines
; e.g. can use same color for multiple lines, and only label it once.
nplots=n_elements(self->get(/dim1_ids)) < n_elements(channels)	;kim 10-Feb-2004


if loc ne 0 then begin

 cmd = 'ssw_legend, text, box=0, charthick=charthick'

 if loc gt 4 then begin
   if loc eq 5 then loc_cmd = ',position=[0.,.98], /left, /norm'
   if loc eq 6 then loc_cmd = ',position=[1.,1.], /right, /norm'
 endif else begin
   top = loc lt 3
   bottom = loc ge 3
   right = (loc mod 2) eq 0
   left = loc mod 2
   loc_cmd = ',top_legend=top, bottom_legend=bottom, right_legend=right, left_legend=left'
 endelse

 text = ''
 nlabel = 0

;-- label might contain additional lines to put in legend.  If so, be sure to
;   prepend colors and linestyles arrays with extra values for these lines.

 text=self->get(/label)
 if size(text, /tname) eq 'STRING' then nlabel=n_elements(text)

 if is_string(ids) then begin
  if sum then begin
   text2 = self -> get_sum_label(channels)
   text = [text, text2]
  endif else begin
   nlast = (nplots-1) < 9
   colors=(self->get(/dim1_colors))[channels]
   linestyles=(self->get(/dim1_linestyles))[channels]
   if nlabel gt 0 then text = [text, ids[0:nlast]] else text=ids[0:nlast]

;-- linestyle -99 means don't draw line or indent

   more_cmd=',linestyle=linestyles'

   if self->use_colors() then begin
    linestyles=intarr(nplots)
    if nlabel gt 0 then begin
     colors =[replicate(0,nlabel), colors[0:nlast]]
     linestyles=[replicate(-99,nlabel), linestyles[0:nlast]]
    endif
    more_cmd=more_cmd+',color=colors, pspacing=1'
   endif else begin
    if nlabel gt 0 then linestyles = [replicate(-99, nlabel), linestyles[0:nlast]]
   endelse
    if nlast lt (nplots-1) then begin
     text = [text, 'More...']
     linestyles = [linestyles, -99]
    colors = [colors, 0]
   endif
   cmd = cmd + more_cmd
  endelse
 endif
 save_psym = !p.psym
 !p.psym = 0
 if ~(n_elements(text) eq 1 and text[0] eq '') then begin
  ; if nowrite, then write label outside plot so it won't show, just to get size of legend
  if keyword_set(nowrite) then begin
    ok = execute (cmd + ', charsize=label_size, pos=[1.,1.], /left, /norm, corners=corners' )
    legend_size = [corners[2]-corners[0], corners[3]-corners[1]]
  endif else ok = execute (cmd + loc_cmd + ', charsize=label_size')
 endif
 !p.psym = save_psym
endif

;-- write little time stamp on bottom of plot

if ~keyword_set( no_timestamp ) then begin
 timestamp, /bottom, charsize=time_size
endif

return & end

;----------------------------------------------------------------------------
;-- Construct legend for summed data
;   Construct strings with contiguous ranges of dim1 that are summed

function xyplot::get_sum_label, channels

text2 = ''

dim1_vals = self->get(/dim1_vals)
if n_elements(dim1_vals) eq 2 or size(dim1_vals, /n_dimen) eq 2 then begin

 epsilon = self.dim1_is_time ? .0015 : 0.
 ranges=find_contig_ranges(dim1_vals[*,channels], epsilon=epsilon)

 if ranges[0] ne -1 then begin
  if self.dim1_is_time then text2 = format_intervals(ranges, /ut) else $
   text2 = format_intervals(ranges, format='(f9.1)') + ' ' + self->get(/dim1_unit)  
 endif
endif
return, text2
end

;------------------------------------------------------------------------------
;-- get widths for dim1_vals

function xyplot::dim1_widths

dim1_vals = self -> get(/dim1_vals)

if (size(dim1_vals, /n_dimen) ne 2) or (data_chk(dim1_vals,/nx) ne 2) then $
 return, -1 else $
  return, reform( dim1_vals[1,*] - dim1_vals[0,*])

end

;------------------------------------------------------------------------------
;-- useful utility for deriving sub-ranges in data

function xyplot::where_data,data,range,count=count

count=0
if ~valid_range(range) then return,-1
if ~exist(data) then return,-1

ok=where( (data le max(range)) and (data ge min(range)), count)

return,ok & end


;------------------------------------------------------------------------------
;-- general Y-DATA operation function (currently derivative & integral only)

function xyplot::operation,xdata,ydata,err_msg=err_msg

err_msg=''
if self->get(/derivative) then begin
 if n_elements(ydata) lt 4 then begin
  err_msg='Need at least 3 points for derivative'
  message,err_msg,/info
  return,-1
 endif
 xd2=size(xdata,/n_dim) eq 2
 if xd2 then $
  return,deriv(total(xdata,1)/2.,ydata) else $
   return,deriv(xdata,ydata)
endif

if self->get(/integral) then begin
 dx=self->get_dx(xdata)
 return,self->integral(ydata,dx)
endif

return,ydata

end

;------------------------------------------------------------------------------
;-- derivative method

function xyplot::derivative,x,y

return,deriv(x,y)

end

;------------------------------------------------------------------------------
;-- integral method

function xyplot::integral,y,dx

return,total(y*dx,/cum,/nan)

end

;----------------------------------------------------------------------------------------------------------------------
;-- check XDATA dimensions

pro xyplot::check_xdata,xdata,n1,n2,type=type,err_msg=err_msg

err_msg=''
n1=0 & n2=0
type=-1
sz=size(xdata)

;-- XDATA = array(nx)

if sz[0] eq 1 then begin
 n1=sz[1] & n2=1
 type=0
endif

;-- XDATA = array(2,nx) or array(nx,ny)

if sz[0] eq 2 then begin
 if sz[1] eq 2 then begin
  n1=sz[2] & n2=1
  type=1
 endif else begin
  n1=sz[1] & n2=sz[2]
  type=2
 endelse
endif

;-- XDATA = array(2,nx,ny)

if sz[0] eq 3 then begin
 if sz[1] eq 2 then begin
  n1=sz[2] & n2=sz[3]
  type=3
 endif
endif

if type eq -1 then begin
 err_msg='Unsupported XDATA input '
 help,xdata
 message,err_msg,/info
endif


return & end

;------------------------------------------------------------------------------
;-- check YDATA dimensions

pro xyplot::check_ydata,ydata,n1,n2,err_msg=err_msg

n1=0 & n2=0
err_msg=''

sz=size(ydata)
if sz[0] eq 1 then begin
 n1=sz[1] & n2=1
endif

if sz[0] eq 2 then begin
 n1=sz[1] & n2=sz[2]
endif

if (n1 eq 0) or (n2 eq 0) then begin
 err_msg='Unsupported YDATA input'
 message,err_msg,/info
endif

return & end

;----------------------------------------------------------------------------
;-- return X-DATA indicies for fast plotting

function xyplot::where_xdata,chan,count=count,_ref_extra=extra,$
                            err_msg=err_msg,keep_log=keep_log

count=0
err_msg=''
xdata=self->get_xdata(chan,err_msg=err_msg,/midpoint)
if is_string(err_msg) then return,-1

xrange=self->get(/xrange)
ylog=self->get(/ylog)
pos=self->get(/positive)

;-- flag points outside xrange

nan=min(*self.xdata_ptr,/nan)-100.

if valid_range(xrange) then begin
 bad=where( (xdata lt min(xrange)) or (xdata gt max(xrange)),bcount)
 if bcount gt 0 then xdata[bad]=nan
endif

;-- flag non-positive data

take_log=1-keyword_set(keep_log)
ydata=self->get_ydata(chan)
if (ylog and take_log) or pos then begin
 bad=where( (ydata le 0.),bcount)
 if bcount gt 0 then xdata[bad]=nan
endif

;-- return indicies of plot-worthy data

return,where2( xdata ne nan,count,_extra=extra)

end


;----------------------------------------------------------------------------
;-- return summed Y-data

function xyplot::get_sum_ydata

chans=self->get_channels()
nchans=n_elements(chans)
ny=self->get(/ny)
if nchans eq 1 then return,(*self.ydata_ptr)[*,chans]

;-- check if weighted sum

weighted_sum=self->get(/weighted_sum)
if weighted_sum then begin
 widths=self->dim1_widths()
 weighted_sum=widths[0] ne -1
endif

;-- if not weighted sum, then return regular sum

if ~weighted_sum then begin
 if ny eq nchans then return,total(*self.ydata_ptr,2)
 return,total( (*self.ydata_ptr)[*,chans],2)
endif

;-- else do weighted sum

return,(*self.ydata_ptr)[*,chans]#widths[chans]/total(widths[chans])

end

;----------------------------------------------------------------------------
;-- check if rescaling Y-data

function xyplot::rescale

return, (self->get(/yscale) ne 1.) or (self->get(/yoffset) ne 0.)

end

;----------------------------------------------------------------------------
;-- fill in data gaps
 
function xyplot::fill_ygaps, ydata, chan, edata=edata

xdata = self->get_xdata(chan, /midpoint, yes_gap=yes_gap)
if yes_gap then begin
  xdata_all = self -> get_xdata(chan, /midpoint, /nofill)
  q = where(finite(xdata_all), nq)
  if nq gt 0 then begin
    if exist(edata) then edata = interpol(edata[q], xdata_all[q], xdata)
    return, interpol(ydata[q], xdata_all[q], xdata)
  endif
endif

return, ydata
end

;----------------------------------------------------------------------------
;-- check if integrating/differentiating Y-DATA

function xyplot::operate

return,self->get(/derivative) or self->get(/integral)

end

;-----------------------------------------------------------------------------
;-- rescale Y-DATA

function xyplot::yscale,ydata

return,temporary(ydata)*self->get(/yscale) + self->get(/yoffset)

end

;----------------------------------------------------------------------------
;-- return Y-DATA for given channel

function xyplot::get_ydata,chan,edata=edata,err_msg=err_msg

err_msg=''
delvarx,edata

sum=self->allow_sum()
if ~sum then begin
 if ~self->valid_chan(chan,err_msg=err_msg) then return,-1
endif

if sum then ydata=self->get_sum_ydata() else $
 ydata=reform((*self.ydata_ptr)[*,chan])

if (self->has_edata()) and ~sum then begin
 e2d=size(*self.edata_ptr,/n_dim) eq 2
 if e2d then edata=reform((*self.edata_ptr)[*,chan]) else edata=*self.edata_ptr
endif

if self->get(/fill_gaps) then ydata = self -> fill_ygaps(ydata, chan, edata=edata)

;-- rescaling Y-DATA?

if self->rescale() then begin
 ydata=self->yscale(ydata)
 if exist(edata) then edata=self->yscale(edata)
endif

;-- differentiating or integrating?

if self->operate() then begin
 xdata=self->get_xdata(chan)
 ydata=self->operation(xdata,ydata,err_msg=err_msg)
endif

return,ydata

end

;-----------------------------------------------------------------------------
;-- return X-data "width" for integration

function xyplot::get_dx,xdata

if size(xdata,/n_dimen) eq 2 then begin
 dx = xdata[1,*]-xdata[0,*]
endif else begin
 mid=(xdata+xdata[1:*])/2.
 dx=mid[1:*]-mid
 np=n_elements(dx)
 dx=[dx[0],dx,dx[np-1]]
endelse

return,dx

end

;------------------------------------------------------------------------------
;-- return X-DATA for given channel

function xyplot::get_xdata,chan,err_msg=err_msg,midpoint=midpoint, nofill=nofill, yes_gap=yes_gap

yes_gap = 0
err_msg=''
if ~self->valid_chan(chan,err_msg=err_msg) then return,-1
midpoint=keyword_set(midpoint)
fill_gaps = self -> get(/fill_gaps) and ~keyword_set(nofill)

xtype=self->get(/xtype)
case xtype of
 0: return,*self.xdata_ptr
 1: begin
   if fill_gaps then begin
     xdata = self->fill_xgaps(0, yes_gap)
     if midpoint then return,total(xdata,1)/2. else return,xdata
   endif else if midpoint then return,total(*self.xdata_ptr,1)/2. else return,*self.xdata_ptr
   end
 2: return,reform((*self.xdata_ptr)[*,chan])
 3: begin
   if fill_gaps then begin
     xdata = self->fill_xgaps(chan, yes_gap)
     if midpoint then return,reform(total(xdata,1)/2.) else return,reform( xdata )
   endif else if midpoint then return,reform(total((*self.xdata_ptr)[*,*,chan],1)/2.) else $
     return,reform( (*self.xdata_ptr)[*,*,chan] )
   end
 else: begin
    err_msg='Unrecognized XDATA type - '+strtrim(type,2)
    message,err_msg,/info
    end
endcase
return,-1
end

;----------------------------------------------------------------------------
; fill in gaps in x data
function xyplot::fill_xgaps, chan, yes_gap

test = 1
q = where (finite((*self.xdata_ptr)[0,*,chan]), nq)
if nq gt 0 then mk_contiguous, (*self.xdata_ptr)[*,q,chan], newx, epsilon=1.e-3, test=test
yes_gap = test eq 0
return, yes_gap? newx : (*self.xdata_ptr)[*,*,chan]
end

;----------------------------------------------------------------------------
;--- validate channel

function xyplot::valid_chan,chan,err_msg=err_msg

err_msg=''
if ~is_number(chan) then chan=0
ny=self->get(/ny)
if (chan lt 0) or (chan ge ny) then begin
 err_msg='Out of range channel - '+strtrim(chan,2)
 message,err_msg,/info
 return,0b
endif

return,1b
end

;----------------------------------------------------------------------------
;-- PLOTMAN method

pro xyplot::plotman,plotman_obj=plotman_obj, _extra=extra

valid_plotman = is_class(plotman_obj,'plotman', /quiet) ? plotman_obj->valid() : 0
if valid_plotman then error=0 else plotman_obj = obj_new('plotman', error=error)
if error then begin
 message,'Error creating PLOTMAN widget.', /infoinue
 return
endif

desc = self->getprop(/id)
plot_type=self->getprop(/plot_type)
plotman_obj -> new_panel, input=self, plot_type=plot_type, desc=desc, _extra=extra,/nodup

return & end

;------------------------------------------------------------------------------
;-- xyplot properties definition

pro xyplot__define

temp={xyplot,            $     ;
     id:'',              $     ;-- data identifier
     filename:'',        $     ;-- data source filename (optional)
     header_ptr:ptr_new(),$    ;-- file header (optional)
     xdata_ptr:ptr_new(),$     ;-- pointer for XAXIS array (1 or 2-D)
     ydata_ptr:ptr_new(),$     ;-- pointer for YAXIS array (NX x NY)
     edata_ptr:ptr_new(),$     ;-- pointer for YAXIS errors (NX x NY)
     dim1_ids:ptr_new(), $     ;-- label ID (individual channels, e.g. 300 GHz)
     dim1_vals:ptr_new(),$     ;-- values for channels (1 or 2-D)
     dim1_is_time: 0b,   $     ;-- internal flag for whether dim1 dimension is time
     dim1_unit:'',       $     ;-- channel unit (e.g. frequency)
     data_unit:'',       $     ;-- data unit (e.g. SFU)
     xtitle:'',          $     ;-- x title
     nx:0l,              $     ;-- # of X points
     ny:0l,              $     ;-- # of Y channels
     plot_type:'',       $     ;-- plot type
     yrange:[0.d,0.d],     $     ;-- data yrange
     xrange:[0.d,0.d],     $     ;-- data xrange
     ylog:0b,            $     ;-- plot YAXIS as log
     xlog:0b,            $     ;-- plot XAXIS as log
     histogram:0b,       $     ;-- plot as histogram for XTYPE=1,3
     positive:0b,        $     ;-- only plot positive data
     derivative:0b,      $     ;-- plot as derivative
     integral:0b,        $     ;-- plot as integral
     stairs:0b,          $     ;-- plot HISTOGRAM with STAIRS option
     all:0b,             $     ;-- plot all channels
     dim1_enab_sum: 0b,  $     ;-- allow sum channels option
     weighted_sum: 0b,   $     ;-- 0/1 = total or weighted sum when summing
     nsum:0l,            $     ;-- sum in X domain
     legend_loc: 0b,     $     ;-- location for legend 0/1/2/3/4 = no legend/ topleft/topright/ bottomleft/bottomright
     label: ptr_new(),   $     ;-- additional info to put in legend
     dim1_sum:0b,        $     ;-- sum channels
     dim1_use:ptr_new(), $     ;-- array of channels to plot
     dim1_colors: ptr_new(), $ ;-- array of colors to use for plots
     dim1_linestyles: ptr_new(), $   ;-- array of linestyles to use for plots
     yscale: 0., $             ;-- scale factor for y data
     yoffset: 0., $            ;-- offset for y data
     xtype:0,$                 ;-- 0: XDATA= array(NX), 1: array(2,NX), 2: array(NX,NY), 3: array(2, NX,NY)
     overlay_obj: obj_new(), $ ;-- an xy or ut plot object to plot on top of plot from this object
     addplot_name: '', $       ;-- name of an additional plot procedure to call
     addplot_arg: ptr_new(), $ ;-- structure containing arguments to addplot_name procedure
     fill_gaps: 0b, $           ;-- 0/1, 1 means fill in gaps by interpolating
     inherits chan, inherits free_var}

return
end
