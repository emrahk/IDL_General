PRO vis_fwdfit_plotfit, visin, srcstr, mapcenter, rchisq, $
   MAP_RESID=map_resid, EBPLOT=ebplot, TIME=time,$
   PLOT=plot, vf_vis_window=vf_vis_window, _EXTRA=extra
;
; Generates comparison plot between input visibility data and model visibilities
;
; visin is an array of visibility structures
; srcstr is an array of source component structures
; /MAP_RESID also generates back projection map of residuals.
;
; 10-Nov-05 	Initial working version, broken out from hsi_vis_fwdfit. (ghurford@ssl.berkeley.edu)
; 13-Nov-05 gh	Adapt to revised definition of srcstr.xyoffset
; 14-Nov-05 gh	Add MAP_RESID keyword
;  9-Dec-05 gh	Minor changes.
; 21-Dec-05 gh	Add EBPLOT keyword to optionally plot error bars in blue.
; 22-dec-05 gh	Suppress amplitude and residual points for which sigamp > amplitude
; 26-Jan-06 ejs Added optional rchisq variable (reduced chi^2)
; 01-mar-06 ejs Added plot command (default=1) to prevent plotting (plot=0)
; 07-mar-06 ejs Added time keyword to put time on map; added _EXTRA keyword
; 28-Mar-06 gh  Reimplement fit plot colors with thicker lines
; 30-Apr-09 kim Change to linear, change title and add legend,
;               save/restore user's plot settings, use linecolors
;  4-May-09 kim Use vf_vis_window to plot in.  If not avail, create it and pass it out.
; 26-Nov-2011 kim. Call al_legend instead of legend (IDL V8 conflict)
; 30-Oct-13 A.M.Massone   Removed hsi dependencies

DEFAULT, plot, 1
DEFAULT, ebplot, 1
DEFAULT, vf_vis_window, -1

TWOPI       =  2. * !PI

if keyword_set(PLOT) then begin
  !p.multi 	= 0
  tvlct, /get, rsave, gsave, bsave
  linecolors
  window_save = !d.window
  if vf_vis_window eq -1 or (is_wopen(vf_vis_window) eq 0) then begin
    vf_vis_window = next_window(/user)
    window, vf_vis_window, title='VIS FWDFIT VISIBILITIES'
  endif
endif 
 
nvis    	= N_ELEMENTS(visin)
npt     	= 2*nvis
jdum 		= FINDGEN(npt)                    		     ; dummy 'x' values used in fitting routine
srcparm   	= vis_fwdfit_structure2array(srcstr, mapcenter)
ampobs 		= ABS(visin.obsvis)
;
IF KEYWORD_SET(nophase) EQ 0 THEN BEGIN			; normal
    visx    = FLOAT(visin.obsvis)
    visy    = IMAGINARY(visin.obsvis)
ENDIF ELSE BEGIN                        		; Set phase to zero if /NOPHASE is set
    visx    = ABS(visin.obsvis)
    visy    = FLTARR(nvis)
ENDELSE
;

;;;;;;;;;;; paout computed directly here without calling the hsi_vis_select routine
paout          = ((ATAN(visin.v, visin.u) + TWOPI) MOD TWOPI) * !RADEG
scpa        = visin.isc+1 + (paout/180. MOD 1) 		       		; (sc# + pa/180) is used as abscissa for plots
i 			= SORT(scpa)
j 			= WHERE(ampobs GT visin.sigamp, nok)				; cases where amplitude > its error
;
; Default option is to generate fit plots.
IF keyword_set(PLOT) then begin
    IF nok LE 1 THEN j = i											; Use j to just plot good amplitudes
    PLOT,  scpa[j], ampobs[j], XTITLE='SC + PA/180.',      XRANGE=[1,10], XSTYLE=1, $
                     YTITLE='ph / cm2 / sec',  PSYM=7,  SYMSIZE=0.6, THICK=2, $
                      TITLE="Visibilities - Observed, Fitted (VIS_FWDFIT), and Differences"

;    ylim = 1.02*10.^!Y.CRANGE[0]			; a minimum value that will just fit on plot
;
; Calculate 'fitted' amplitudes from source model
    visxyfit    = vis_fwdfit_func(jdum,srcparm)
    ampfit      = SQRT(visxyfit[0:nvis-1]^2 + visxyfit[nvis:*]^2)
;
; Calculate amplitude of difference between fitted and observed visibilities
    visdiff     = SQRT((visx-visxyfit[0:nvis-1])^2 + (visy-visxyfit[nvis:*])^2)
    
    IF KEYWORD_SET(ebplot) NE 0 then begin
      ERRPLOT, scpa[i], (ampobs[i]-visin[i].sigamp > !y.crange[0]), ampobs[i]+visin[i].sigamp < !y.crange[1], width=0, COLOR=10
      OPLOT, scpa[i], ampfit[i], PSYM=10,THICK=2,COLOR=2
      OPLOT, scpa[j], visdiff[j], PSYM=5, SYMSIZE=0.4, THICK=2, COLOR=7
      text = ['Observed', 'Error on Observed', 'Fitted', 'Difference Amplitudes']
      sym = [7, -3, -3, 5]
      color = [255, 10, 2, 7]
      al_legend, text, psym=sym, color=color, box=0
    ENDIF
ENDIF
;
IF N_ELEMENTS(RCHISQ) NE 0 THEN rchisq=total((visdiff/visin.sigamp)^2)/(npt-8) ; reduced chi^2
;
; Optionally plot residual map
IF KEYWORD_SET(map_resid) EQ 0 THEN RETURN
	visdiff 		= visin
	visfit 			= COMPLEX(visxyfit[0:nvis-1], visxyfit[nvis:*])
	visdiff.obsvis 	= visin.obsvis - visfit
	vis_bpmap, visdiff,time=time,_EXTRA=extra
	
if keyword_set(plot) then begin
  tvlct, rsave,gsave,bsave
  wset,window_save
endif

RETURN
END

