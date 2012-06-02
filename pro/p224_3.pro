;pro p224_3


u=dindgen(61)-30.


t1=200.
t2=80.
t3=120
t_icm=4000.

tau1=0.11*exp(-u^2/50.)
tau2=0.18*exp(-(u-5)^2/18.)
tau3=0.18*exp(-(u+10)^2/32.)
tau_icm=0.002*exp(-u^2/450.)

Tb=t1*(1.-exp(-tau1))+t_icm*(1-exp(-tau_icm))*exp(-tau1)*$
(1+exp(-tau_icm-tau2))+t2*(1-exp(-tau2))*exp(-tau1-tau_icm)+$
t3*(1-exp(-tau3))*exp(-tau1-2*tau_icm-tau2)

;difference spectrum:

Tc=10^5
Ts=Tb/(1-exp(-tau1-tau2-tau3-2*tau_icm))
dt_t=(Ts/Tc-1)*(1-exp(-tau1-tau2-tau3-2*tau_icm))


!p.multi=[0,1,2]
plot,u,Tb,title='emission spectrum',ytitle='Tb_off',xrange=[-32,32],/xstyle
plot,u,dt_t,title='absorption spectrum',xtitle='velocity dispersion (km/s)',$
ytitle='  Tb/Tc',xrange=[-32,32],/xstyle
end
