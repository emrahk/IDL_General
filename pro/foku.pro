pro foku,fn,tm,ra,t0
fxbopen,unit,fn,1,h
fxbread,unit,time_lc,1
fxbread,unit,ra,2
fxbclose,unit
tm = time_lc-double(min(time_lc))
t0=double(min(time_lc))
end
