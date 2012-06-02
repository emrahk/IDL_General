pro lowe

a1 = [6.68,6.75,6.31,5.48]
a2 = [6.42,6.55,6.35,3.28]

e1 = [.08,.09,.08,.09]
e2 = [.12,.17,.17,.17]

x=[1,2,3,10]
y=a2/a1
err = y*sqrt((e1/a1)^2+(e2/a2)^2)
plot,x,y,xrange=[0,12],yrange=[0,1.2],ytitle='6 kev / 14 kev',title='c1d4'
erplt,x,x,x,y,err,1

return
end
