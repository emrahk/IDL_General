pro html_formtime, template, start_sel, stop_sel, timerange=timerange, $
   replace=replace, outfile=outfile

;+
;   Name: html_form_addtime
;
;   Purpose: add times to an html form (template)
;
;   Input Parameters:
;      template - input text (html excluding time menus)
;      start_sel - default start time to use
;      stop_sel  - default stop time to use
;   
;   Keyword Parameters:
;      timerange - time range for menus
;      outfile   - if set, output .html document (default is <template>.html
;      replace   - string to replace with time menus (in template)
;                  default is <!** time_range **>
;
;   Calling Sequence:
;      html_form_addtime, template, start_sel [,stop_sel], timerange=timerange
;-
if not data_chk(template,/string) then begin
   message,/info,"Must supply template file..."
   return
endif

if strpos(template,'.') eq -1 then template=template + '.template'

if not file_exist(template) then begin
   message,/info,"Template file: " + template + " does not exist..."
   return
endif   

if not keyword_set(replace) then replace="<!** time_range **>"

text=rd_tfile(template)
ss=where(strpos(text,replace) ne -1,sscnt)

if sscnt eq 0 then begin
   message,/info,"Replacement string: " + replace + " not found..."
   return
endif

case n_params() of
   3: begin
      t0=fmt_tim(start_sel)
      t1=fmt_tim(stop_sel)
   endcase   
   2: begin
      t0=fmt_tim(start_sel)
      t1=fmt_tim(gt_day(timegrid(ut_time(),day=1,/string),/string))
      stop_sel=t1
   endcase
   else: begin
      t0=fmt_tim(gt_day(timegrid(ut_time(),day=(-1),/string),/string))         
      t1=fmt_tim(gt_day(timegrid(ut_time(),day=1,/string),/string))
   endcase
endcase

timeinfo=mk_formt_html(t0,t1,timerange=timerange)

outfile=str_replace(template,'.template','.html')

message,/info,"Updating file: " + outfile(0)

otext=[text(0:ss(0)-1),timeinfo,text(ss(0)+1:*)]
nblank=where(strcompress(otext,/remove) ne '')
otext=otext(nblank)
file_append,outfile,[text(0:ss(0)-1),timeinfo,text(ss(0)+1:*)],/new

return
end
