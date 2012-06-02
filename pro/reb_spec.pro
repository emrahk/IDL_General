tmp_ps = [pspec(0), rebin(pspec(1:64),8)]
tmp_f = [f(0), rebin(f(1:64), 8)]
tmp_sg = tmp_ps/sqrt(8.)/sqrt(88.)
rbpspec = tmp_ps
rbf = tmp_f
rbsg = tmp_sg
;
tmp_ps = rebin(pspec(65:192),8)
tmp_f = rebin(f(65:192), 8)
tmp_sg = tmp_ps/sqrt(16.)/sqrt(88.)
rbpspec = [rbpspec,tmp_ps]
rbf = [rbf,tmp_f]
rbsg = [rbsg,tmp_sg]
;
tmp_ps = rebin(pspec(193:448),8)
tmp_f = rebin(f(193:448), 8)
tmp_sg = tmp_ps/sqrt(32.)/sqrt(88.)
;
rbpspec = [rbpspec,tmp_ps]
rbf = [rbf,tmp_f]
rbsg = [rbsg,tmp_sg]
;
tmp_ps = rebin(pspec(449:960),8)
tmp_f = rebin(f(449:960), 8)
tmp_sg = tmp_ps/sqrt(64.)/sqrt(88.)
rbpspec = [rbpspec,tmp_ps]
rbf = [rbf,tmp_f]
rbsg = [rbsg,tmp_sg]
;
tmp_ps = rebin(pspec(961:1984),4)
tmp_f = rebin(f(961:1984), 4)
tmp_sg = tmp_ps/sqrt(256.)/sqrt(88.)
rbpspec = [rbpspec,tmp_ps]
rbf = [rbf,tmp_f]
rbsg = [rbsg,tmp_sg]
;
tmp_ps = rebin(pspec(1985:4032),4)
tmp_f = rebin(f(1985:4032), 4)
tmp_sg = tmp_ps/sqrt(512.)/sqrt(88.)
rbpspec = [rbpspec,tmp_ps]
rbf = [rbf,tmp_f]
rbsg = [rbsg,tmp_sg]
;

END
