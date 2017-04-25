; Time-stamp: <Mon Nov 20 2006 17:48:48 csillag auriga.ethz.ch>

pro spectro_test

;goto, gaga
time_axis = anytim( '2002/02/04 11:02:45' ) + findgen(100)
spectro_plot, dist(100), time_axis
spectro_plot, dist(100), time_axis, xs = 3, xrange = time_axis[0] + [10,20]

restore, 'spg.dat'
spectro_plot, spg

loadct, 5

img = dist(100)
x = anytim( '2004/01/01' ) + dindgen(100)
y = dindgen(100)
spectro_plot, img, x,y 

spectro_plot, img, x, y, /no_ut
wait, 3
spectro_plot, img, x+10, y, /no_ut, /xlog
wait, 3

    
;f = file_search( '*fit.gz' )
f = '20020820081500i.fit.gz'
; problem with interp_image:
radio_spectro_fits_read, f, z, x, y
spectro_plot, z,x,y, yrange = [10000, 0]

spectro_plot, z,x,y, yrange = [4000, 3900]
wait, 3
spectro_plot, z,x,y, yrange = [4000, 3894]
wait, 3
spectro_plot, z,x,y, yrange = [4000, 3893]
wait, 3
spectro_plot, z,x,y, yrange = [4000, 3892]
wait, 3
spectro_plot, z,x,y, yrange = [3970, 3892]
wait, 3

; this does not work yet
;spectro_plot, z,x,y, yrange = [3970, 3892], /ylog, /
;wait, 3

; test the title
spectro_plot, z,x,y, title = 'test', /ylog, /zlog

; test if interpolate works
spectro_plot, z,x,y, title = 'test', /ylog, /zlog, /interpolate

wait, 3
spectro_plot, z,x,y, timerange = '2002/08/20 ' + ['8:00', '9:00']
wait, 3
spectro_plot, z,x,y, timerange = '2002/08/20 ' + ['8:00', '9:00'], yrange=[10000,0]
wait, 3
print, 'test styles: '
for i=1, 8 do begin
    for j = 1, 8 do begin
        print, 'xstyle, ystyle = ', i, j
        spectro_plot, z,x,y, xstyle = i, ystyle =j
        wait, 1
    endfor
endfor

spectro_plot, z,x,y, timerange = '2002/08/20 ' + ['8:00', '9:00'], yrange=[10000,0]

spectro_plot, z,x,y, timerange = '2002/08/20 ' + ['8:00', '9:00'], yrange=[10000,0]

;spectro_plot, z, timerange = '18-feb-03 ' + ['08:36', '8:40' ], /no_yut
;spectro_plot, z, timerange = '18-feb-03 ' + ['08:36', '8:40' ]
;spectro_plot, z[*,0:2],x,y, timerange = '18-feb-03 ' + ['08:36', '8:40' ]
;spectro_plot, z[*,0:2],x,y, timerange = '18-feb-03 ' + ['08:36', '8:40' ], /NO_UT

gaga:

; now lets try two of them
restore,  'tplot_test_data.sav'

spectro_plot, gg, hh, ylog=[1,1], /zlog

wait, 3

f = '20020820081500i.fit.gz'

radio_spectro_fits_read, f, pp, /struct
spectro_plot, pp, hh, zlog=[0,1], yrange=[[500, 100], [0, 0]], /no_int, $
    title=['phoenix', 'rhessi'], ytitle=['frequency mhz', 'energy kev' ], $
    yintegr=[0, 1], psym=10
wait, 3


spectro_plot, pp,  hh
wait, 3

spectro_plot, pp, ( hh ), zlog=[0,1]
wait, 3
spectro_plot, pp, ( hh ), zlog=[0,1], xrange='2002-08-20 ' + ['8:24', '8:26']
wait, 3
spectro_plot, pp, ( hh ), zlog=[0,1], xrange='2002-08-20 ' + ['8:24', '8:26'], no_int= [0,1]
wait, 3
spectro_plot, pp, ( hh ), zlog=[0, 1], xrange='2002-08-20 ' + ['8:24', '8:26'], $
    no_int=[0, 1], yrange=[[500, 100], [0, 0]]
wait, 3
spectro_plot, pp, ( hh ), zlog=[0, 1], $
    xrange='2002-08-20 ' + ['8:24', '8:26'], no_int=[0, 1], yrange=[[500, 100], [0, 0]], yintegr=[0, 1], psym=10
wait, 3
spectro_plot, pp, ( gg ), (ww), ( hh ), zlog=[0,0,0,1], psym=10, $
    xrange='2002-08-20 ' + ['8:24', '8:26'], no_int=[0, 1,0,0], $
    yrange=[[500, 100], [0, 0], [0, 0], [0, 0]], yintegr=[0, 0, 0, 1]
wait, 3
spectro_plot, pp, ( ww ), ( hh ), zlog=[0,0,1], $
    xrange='2002-08-20 ' + ['8:24', '8:28'], no_int=[1, 0, 0], $
    yrange=[[500, 100], [1.1e7, 2e7], [0, 0]]
wait, 3
spectro_plot, pp, ( ww ), ( hh ), zlog=[0,0,1], $
    xrange='2002-08-20 ' + ['8:24', '8:28'], no_int=[1, 0, 0], $
    yrange=[[500, 100], [1.1e7, 2e7], [0, 0]], /post

;return
;print, 'pgrigis application:'

;restore
;spectro_plot, spg, /zlog, yrange = [3,10], /no_interp, ystyle = 1;
;
;spectro_plot, spg.spectrogram, spg.x, spg.y, $
;    phspg2.spectrogram, phspg2.x, phspg2.y, /zlog, $
;    xrange=anytim( '24-apr-2003 ' + ['12:15', '13:15']), $
;    xstyle= 1, ystyle=1, /no_interp, $
;    yrange=[[3,10],[200,120]], ylog= [1,0], $
;    ytitle=['keV', 'MHz'], xtitle='ciao', title=['RHESSI', 'PHOENIX II']

;return

f = file_search( '*gz' )
radio_spectro_fits_read, f[0], pp, /struct
restore, 'tplot_test_data.sav'
spectro_plot, pp, ( hh )
loadct, 5

;add_path, '/global/hercules/data1/ssw/radio/ethz/idl/atest/
;add_path, './kim'

;spectro =  obj_new( 'specplot' )
;spectro->set, data =  pp.y, freq=pp.v, time=pp.x
;o =  plotman( input=spectro )
;obj_destroy, o
;o =  plotman( input=spectro, /multi )
;o->new_panel, desc =  'phoenix'
;spec2 =  obj_new( 'specplot' )
;spec2->set, data =  hh.y, freq=hh.v, time=(hh.x)
;o->set, input = spec2
;o->new_panel, desc =  'hessi'

end
